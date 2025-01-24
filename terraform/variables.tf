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

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for yourdomain.com"
  type        = string
}

variable "domain_name" {
  description = "Domain name for WireGuard service"
  type        = string
  default     = "wg.yourdomain.com"
}