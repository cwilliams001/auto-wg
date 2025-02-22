# Specify the required provider and its version
terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.15.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# Configure the Vultr provider with the API key
provider "vultr" {
  api_key = var.vultr_api_key
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Define a Vultr instance
resource "vultr_instance" "auto-wg" {
  plan        = "vc2-1c-1gb"
  region      = "ewr"
  os_id       = "1743"
  label       = "auto-wg"
  ssh_key_ids = [var.ssh_key_id]
}


resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/inventory/inventory.ini.tpl", {
    wireguard_ip = vultr_instance.auto-wg.main_ip
    auth_key     = var.wireguard_auth_key
  })
  filename = "${path.module}/../ansible/inventory/hosts"
}

# Resource to wait for the instance to be fully ready after creation
resource "time_sleep" "wait_60_seconds" {
  depends_on      = [vultr_instance.auto-wg]
  create_duration = "60s"
}

# Null resource to run the Ansible playbook for server setup
resource "null_resource" "ansible_provisioner" {
  depends_on = [
    time_sleep.wait_60_seconds,
    local_file.ansible_inventory,
  ]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/inventory/hosts ../ansible/site.yml"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }

  triggers = {
    instance_ip = vultr_instance.auto-wg.main_ip
  }
}

# Resource to create the client setup script locally
resource "local_file" "client_setup_script" {
  depends_on = [null_resource.ansible_provisioner]

  content = templatefile("${path.module}/../ansible/roles/wg_service/templates/client_setup.py.j2", {
    wireguard_server_url = "https://${var.domain_name}/generate_config",
    auth_key             = var.wireguard_auth_key
  })

  filename = "${path.module}/../client/client_setup.py"
}
