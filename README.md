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
- **Secure by Default**: Authentication-based access control
- **Multi-Platform Support**: Works on Linux-based systems

## 🔧 Prerequisites

### Server Requirements
- Vultr account with API key
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
# - Vultr API key
# - SSH key ID
# - WireGuard authentication key
```

3. Deploy:
```bash
cd terraform
terraform init
terraform apply
```

4. Set up a client:
```bash
sudo python3 client/client_setup.py
```

## 📖 Detailed Setup

### Server Deployment

1. **Generate Authentication Key**:
```bash
openssl rand -base64 32
```

2. **Configure Variables**:
   - Add the generated key to `terraform/terraform.tfvars`
   - Set your Vultr API key and SSH key ID

3. **Deploy Infrastructure**:
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Client Configuration

The client setup script handles:
- WireGuard package installation
- Configuration retrieval
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
wireguard_port: 51820
wg_service_port: 5000
```

### Network Configuration
- Default subnet: 10.0.0.0/24
- Server IP: 10.0.0.1
- Client IPs: 10.0.0.2 - 10.0.0.254

## 🎮 Usage

### Managing Clients

**List Connected Clients**:
```bash
curl -H "Authorization: your-auth-key" http://<SERVER_IP>:5000/list_clients
```

**Check Server Health**:
```bash
curl http://<SERVER_IP>:5000/health
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

### Firewall Configuration
The following ports must be open:
- 51820/udp (WireGuard)
- 5000/tcp (Management API)

## 🔍 Troubleshooting

### Common Issues

1. **Connection Failures**
```bash
# Check WireGuard status
sudo wg show
sudo systemctl status wg-quick@wg0

# View service logs
journalctl -u wg_service
```

2. **Configuration Problems**
- Verify authentication key
- Check IP assignments
- Ensure ports are open

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
```
