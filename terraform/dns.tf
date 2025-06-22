# terraform/dns.tf
resource "cloudflare_record" "wireguard" {
  zone_id = var.cloudflare_zone_id
  name    = "wg"
  content = vultr_instance.auto-wg.main_ip
  type    = "A"
  proxied = false # Don't proxy through Cloudflare since this is a VPN service
}
# Optional zone settings override - requires Zone:Edit permissions
# Enable by setting enable_zone_settings = true in terraform.tfvars
resource "cloudflare_zone_settings_override" "auto_wg_zone" {
  count   = var.enable_zone_settings ? 1 : 0
  zone_id = var.cloudflare_zone_id
  settings {
    ssl = "full"
    tls_1_3 = "on"
  }
}