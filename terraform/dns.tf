# terraform/dns.tf
resource "cloudflare_record" "wireguard" {
  zone_id = var.cloudflare_zone_id
  name    = "wg"
  content = vultr_instance.auto-wg.main_ip
  type    = "A"
  proxied = false # Don't proxy through Cloudflare since this is a VPN service
}
# Zone settings override removed - requires Zone:Edit permissions
# You can manually set SSL to "Full" in Cloudflare dashboard if needed:
# Dashboard → SSL/TLS → Overview → Set to "Full"