# Specify the required provider and its version
terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.15.1"
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

# Define a Vultr instance
resource "vultr_instance" "test_wireguard" {
  plan        = "vc2-1c-1gb"
  region      = "ewr"
  os_id       = "1743"
  label       = "test_wireguard"
  ssh_key_ids = [var.ssh_key_id]
}



resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/inventory/inventory.ini.tpl", { wireguard_ip = vultr_instance.test_wireguard.main_ip})
  filename = "${path.module}/../ansible/inventory/hosts"
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [vultr_instance.test_wireguard]
  create_duration = "30s"
}
resource "null_resource" "ansible_provisioner" {
  depends_on = [time_sleep.wait_30_seconds, local_file.ansible_inventory]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/inventory/hosts ../ansible/site.yml"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }

  triggers = {
    instance_ip = vultr_instance.test_wireguard.main_ip
  }
}
