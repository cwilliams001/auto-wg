# Auto-WireGuard (auto-wg)

A self-hosted WireGuard VPN management system that automates server deployment and client configuration. Inspired by Tailscale, this project simplifies VPN setup through infrastructure as code and automated client onboarding.

> **⚠️ NOTE:** This project is experimental and not production-ready. Use at your own risk.

## 📑 Table of Contents
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Detailed Setup](#-detailed-setup)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Security](#-security)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

## ✨ Features
- **One-Command Deployment**: Fully automated server provisioning using Terraform
- **Zero-Config Client Setup**: Simple client onboarding script
- **Centralized Management**: REST API for configuration and client management
- **Secure by Default**: HTTPS and authentication-based access control
- **Multi-Platform Support**: Works on Linux-based systems
- **Automated SSL**: Automatic HTTPS certificates via Caddy
- **DNS Management**: Automated DNS configuration with Cloudflare

## 🔧 Prerequisites

### Server Requirements
- Vultr account with API key
- Cloudflare account with API token
- Domain name managed by Cloudflare
- Ubuntu 22.04 or later
- Python 3.10+

### Local Development Requirements
- Terraform 1.0+
- Ansible 2.9+
- Python 3.10+
- Git

### Client Requirements
- Linux-based OS
- Python 3.10+
- Root/sudo access

## 🚀 Quick Start

1. Clone and prepare:
```bash
git clone https://github.com/cwilliams001/auto-wg.git
cd auto-wg
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

2. Configure credentials:
```bash
# Edit terraform/terraform.tfvars with your:
vultr_api_key         = "your-vultr-api-key"
ssh_key_id           = "your-ssh-key-id"
wireguard_auth_key   = "your-generated-auth-key"
cloudflare_api_token = "your-cloudflare-api-token"
cloudflare_zone_id   = "your-cloudflare-zone-id"
domain_name          = "wg.yourdomain.com"
```

3. Configure Ansible variables:
```bash
# Edit ansible/vars/main.yml with:
wireguard_network: "10.0.0.0/24"
wireguard_address: "10.0.0.1/24"
wireguard_port: 51820
wg_service_port: 5000
domain_name: "wg.yourdomain.com"
ssl_email: "your-email@example.com"
```

4. Deploy:
```bash
cd terraform
terraform init
terraform apply
```

5. Set up a client:
```bash
sudo python3 client/client_setup.py
```

## 📖 Detailed Setup

### Server Deployment

1. **Generate Authentication Key**:
```bash
openssl rand -base64 32
```

2. **Run the following command to get the ssh key id**: 
```bash
curl -H 'Authorization: Bearer Vultr_API_KEY' https://api.vultr.com/v2/ssh-keys
```

3. **Get Cloudflare Zone ID**:
```bash
curl -X GET "https://api.cloudflare.com/client/v4/zones" \
     -H "Authorization: Bearer YOUR_API_TOKEN" \
     -H "Content-Type: application/json"
```

4. **Configure Variables**:
- Add the generated key to `terraform/terraform.tfvars`
- Set your Vultr API key and SSH key ID
- Configure Cloudflare credentials
- Set your domain name

5. **Deploy Infrastructure**:
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Client Configuration

The client setup script handles:
- WireGuard package installation
- Configuration retrieval via HTTPS
- Interface setup
- Service activation

Run on each client device:
```bash
sudo python3 client_setup.py
```

## ⚙️ Configuration

### Server Settings
Edit `ansible/vars/main.yml`:
```yaml
wireguard_network: "10.0.0.0/24"
wireguard_address: "10.0.0.1/24"
wireguard_port: 51820
wg_service_port: 5000
domain_name: "wg.yourdomain.com"
ssl_email: "your-email@example.com"
```

### Network Configuration
- Default subnet: 10.0.0.0/24
- Server IP: 10.0.0.1
- Client IPs: 10.0.0.2 - 10.0.0.254

## 🎮 Usage

### Managing Clients

**List Connected Clients**:
```bash
curl -H "Authorization: your-auth-key" https://wg.yourdomain.com/list_clients
```

**Check Server Health**:
```bash
curl https://wg.yourdomain.com/health
```

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/generate_config` | POST | Generate client configuration |
| `/list_clients` | GET | List connected clients |
| `/health` | GET | Check server status |

## 🔒 Security

### Best Practices
1. Use strong authentication keys
2. Keep `terraform.tfvars` secure
3. Enable UFW firewall
4. Regularly update system packages
5. Monitor server logs
6. Use HTTPS for API communication
7. Keep Cloudflare API tokens secure

### Firewall Configuration
The following ports must be open:
- 51820/udp (WireGuard)
- 80/tcp (HTTP - Caddy ACME challenges)
- 443/tcp (HTTPS - API endpoint)

## 🔍 Troubleshooting

### Common Issues

1. **Connection Failures**
```bash
# Check WireGuard status
sudo wg show
sudo systemctl status wg-quick@wg0

# Check Caddy status
sudo systemctl status caddy
sudo journalctl -u caddy

# View WireGuard service logs
journalctl -u wg_service
```

2. **Configuration Problems**
- Verify authentication key
- Check IP assignments
- Ensure ports are open
- Verify DNS resolution
- Check Cloudflare SSL/TLS settings (should be set to "Full")

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- [WireGuard](https://www.wireguard.com/)
- [Tailscale](https://tailscale.com/)
- [Flask](https://flask.palletsprojects.com/)
- [Terraform](https://www.terraform.io/)
- [Ansible](https://www.ansible.com/)
- [Caddy](https://caddyserver.com/)
- [Cloudflare](https://www.cloudflare.com/)