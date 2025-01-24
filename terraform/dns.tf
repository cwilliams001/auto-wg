# terraform/dns.tf
resource "cloudflare_record" "wireguard" {
  zone_id = var.cloudflare_zone_id
  name    = "wg"
  content = vultr_instance.test_wireguard.main_ip
  type    = "A"
  proxied = false # Don't proxy through Cloudflare since this is a VPN service
}
# terraform/dns.tf
# resource "cloudflare_zone_settings_override" "echo1_dev" {
#   zone_id = var.cloudflare_zone_id
#   settings {
#     ssl = "full"
#     tls_1_3 = "on"
#   }
# }