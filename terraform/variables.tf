variable "vultr_api_key" {
  description = "Vultr API Key"
  type        = string
  sensitive   = true
}

variable "ssh_key_id" {
  description = "SSH Key ID"
  type        = string
  sensitive   = true
}

variable "wireguard_auth_key" {
  description = "Authentication key for WireGuard clients"
  type        = string
  sensitive   = true
}