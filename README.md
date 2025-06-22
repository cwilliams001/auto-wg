# Auto-WireGuard (auto-wg)

🚀 **Deploy your own WireGuard VPN server in 5 minutes!**

Auto-WG is a complete WireGuard VPN management solution that automatically:
- Deploys a VPN server on Vultr cloud hosting
- Sets up SSL certificates and DNS
- Provides a web interface for managing clients  
- Generates client configurations with one click

**Perfect for**: Remote work, secure browsing, accessing home networks, or anyone wanting a private VPN without monthly subscriptions.

## 🎯 What You Get

- 🖥️ **Your own VPN server** hosted on Vultr ($6/month)
- 🌐 **Web management interface** at your custom domain
- 📱 **Easy client setup** - one script to connect any device
- 🔒 **Enterprise-grade security** with automatic SSL certificates
- 📊 **Real-time monitoring** of connected devices

![Auto-WG Dashboard](https://via.placeholder.com/800x400/2c3e50/ffffff?text=Auto-WG%20Dashboard%20Screenshot)

> **💡 Status:** Battle-tested by the community. Perfect for personal and small business use.

## 🤔 Why Auto-WG?

**vs. Commercial VPNs (NordVPN, ExpressVPN):**
- ✅ **Your own server** - no shared IPs, no logs, complete control
- ✅ **$6/month** vs $10-15/month for commercial VPNs  
- ✅ **No bandwidth limits** - it's your server!
- ✅ **Any location** - deploy wherever Vultr has servers

**vs. Manual WireGuard Setup:**
- ✅ **5 minutes** vs hours of configuration
- ✅ **Web interface** vs command-line only
- ✅ **Automatic SSL** vs manual certificate management
- ✅ **Client management** vs editing config files

**vs. Tailscale/Similar:**
- ✅ **Self-hosted** - no third-party control
- ✅ **Unlimited devices** - no artificial limits
- ✅ **Open source** - audit the code yourself

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

### 🚀 **Easy Deployment**
- **One-Command Setup**: Fully automated deployment with `./deploy.sh`
- **Interactive Configuration**: Guided setup with automatic API key validation
- **Zero-Config Client Setup**: Simple client onboarding script with enhanced error handling

### 🌐 **Web Management**
- **Modern Web Interface**: Full-featured dashboard for client management
- **Real-time Status**: Live client connection monitoring
- **Easy Client Addition**: Add/revoke clients through web UI
- **Configuration Display**: Copy-paste ready WireGuard configs

### 🔒 **Security First**
- **Production Hardened**: Disabled debug mode, secure file permissions
- **VPS Hardening**: SSH hardening, fail2ban, UFW firewall
- **Rate Limited**: API protection against abuse
- **Input Validation**: Prevents injection attacks
- **Audit Logging**: Security event tracking
- **Auto Updates**: Automatic security patching
- **HTTPS Enforced**: Automatic SSL certificates via Caddy

### 🛠️ **Management Tools**
- **CLI Tool**: `wg-admin` for command-line management
- **REST API**: Programmatic client management
- **Client Revocation**: Remove access instantly
- **Subnet Routing**: Configure clients as subnet routers
- **Infrastructure Destruction**: Complete teardown script
- **Health Monitoring**: Service status checking

### 🏗️ **Infrastructure**
- **Automated DNS**: Cloudflare integration
- **Multi-Platform**: Linux client support
- **Scalable**: Supports up to 253 clients
- **Monitored**: Built-in health checking

## 📋 What You Need

### Before You Start (5 minutes to set up)

1. **💳 Vultr Account** - Sign up at [vultr.com](https://vultr.com) (they offer $100 credit for new users)
2. **🌐 Domain Name** - Any domain you own (e.g., GoDaddy, Namecheap) 
3. **☁️ Cloudflare Account** - Free at [cloudflare.com](https://cloudflare.com) (for SSL certificates)

### Your Computer Needs
- **Linux or macOS** (Windows users: use WSL)
- **Basic tools**: Git, Python 3.10+, Terraform, Ansible
  
  ```bash
  # Install on Ubuntu/Debian:
  sudo apt update && sudo apt install git python3 python3-pip
  
  # Install Terraform & Ansible:
  # (The deployment script will check and guide you)
  ```

### 💰 Costs
- **Vultr VPS**: ~$6/month (1GB RAM, plenty for a VPN)
- **Domain**: ~$10-15/year (if you don't have one)
- **Cloudflare**: Free
- **Total**: Less than $10/month for your own private VPN!

## 🚀 5-Minute Setup

### Step 1: Get Your API Keys Ready

<details>
<summary>🔑 Click here for detailed API key setup (2 minutes)</summary>

**Vultr API Key:**
1. Go to [Vultr Account](https://my.vultr.com/settings/#settingsapi)
2. Create new API key, copy it

**Cloudflare API Token:**
1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Create token with "Zone:Edit" permissions for your domain

**Add your domain to Cloudflare:**
1. Add your domain to Cloudflare (free account)
2. Update your domain's nameservers to Cloudflare's
3. Wait for DNS to propagate (usually 5-10 minutes)

</details>

### Step 2: Deploy Your VPN (3 minutes)

```bash
# Clone and run - that's it!
git clone https://github.com/cwilliams001/auto-wg.git
cd auto-wg
./deploy.sh
```

The script will:
- ✅ Check all dependencies
- 🔐 Securely collect your API keys  
- 🚀 Deploy your VPN server
- 🌐 Set up your web interface
- 📱 Generate client connection scripts

### Step 3: Connect Your Devices

1. **Open your VPN dashboard**: `https://your-domain.com`
2. **Add a device**: Click "Add Client", enter device name (e.g., "laptop")
3. **Copy the config**: Copy the generated configuration
4. **On your device**: Save as `/etc/wireguard/wg0.conf` and run `wg-quick up wg0`

**Or use the auto-setup script:**
```bash
# On any Linux device:
sudo python3 client_setup.py
```

🎉 **Done!** Your device is now connected to your private VPN!

## 🗑️ **Complete Infrastructure Removal**

When you're done with your VPN or want to start fresh:

```bash
# This will completely destroy everything and stop all billing
./destroy.sh
```

The destroy script will:
- 💰 **Destroy Vultr server** (stops billing immediately)
- 🌐 **Remove Cloudflare DNS records** via Terraform
- 🗑️ **Clean up all local files** (configs, keys, state)
- ✅ **Verify removal** with dashboard links

**Important**: This action cannot be undone! The script will ask for confirmation and show you exactly what will be removed.

### Manual Setup (Advanced)

<details>
<summary>Click to expand manual setup instructions</summary>

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

</details>

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

### Web Interface (Recommended)

Visit `https://your-domain.com` to access the management dashboard:

- **📊 Dashboard**: View client statistics and server status
- **➕ Add Clients**: Generate new client configurations instantly
- **👥 Manage Clients**: View, monitor, and revoke client access
- **🔧 Server Actions**: Restart services and view logs
- **📋 Copy Configs**: Ready-to-use WireGuard configurations

### CLI Management

Install and use the CLI tools:

```bash
# Install CLI tools
sudo cp tools/wg-admin /usr/local/bin/
sudo cp tools/security-audit /usr/local/bin/
wg-admin setup

# Common operations
wg-admin list                     # List all clients
wg-admin add laptop-home          # Add new client
wg-admin revoke laptop-home       # Revoke client access
wg-admin health                   # Check server health
wg-admin status                   # Basic status
wg-admin detailed-status          # Detailed client status with connections

# Subnet routing (advanced)
wg-admin add-route laptop-home 192.168.1.0/24    # Configure subnet routing
wg-admin remove-route laptop-home 192.168.1.0/24 # Remove subnet route
wg-admin list-routes              # Show all routes
wg-admin list-routes laptop-home  # Show routes for specific client

# Security audit
security-audit                    # Run security assessment
```

### API Endpoints

| Endpoint | Method | Description | Rate Limit |
|----------|--------|-------------|------------|
| `/` | GET | Web dashboard | - |
| `/generate_config` | POST | Generate client configuration | 5/min |
| `/list_clients` | GET | List connected clients | 10/min |
| `/revoke_client` | POST | Revoke client access | 5/min |
| `/client_status` | GET | Detailed client status with routes | 10/min |
| `/add_route` | POST | Add subnet route for client | 5/min |
| `/remove_route` | POST | Remove subnet route for client | 5/min |
| `/list_routes` | GET | List all subnet routes | 10/min |
| `/health` | GET | Check server status | 30/min |

**Example API Usage**:
```bash
# List clients
curl -H "Authorization: your-auth-key" https://wg.yourdomain.com/list_clients

# Add client
curl -X POST -H "Authorization: your-auth-key" \
     -H "Content-Type: application/json" \
     -d '{"client_name": "laptop"}' \
     https://wg.yourdomain.com/generate_config

# Revoke client
curl -X POST -H "Authorization: your-auth-key" \
     -H "Content-Type: application/json" \
     -d '{"client_name": "laptop"}' \
     https://wg.yourdomain.com/revoke_client

# Add subnet route
curl -X POST -H "Authorization: your-auth-key" \
     -H "Content-Type: application/json" \
     -d '{"client_name": "router", "subnet": "192.168.1.0/24"}' \
     https://wg.yourdomain.com/add_route

# Check health
curl https://wg.yourdomain.com/health
```

## 🔒 Security

### Security Features (Automatically Configured)
1. **SSH Hardening**: Key-only authentication, secure ciphers
2. **Firewall Protection**: UFW configured with minimal open ports
3. **Intrusion Prevention**: Fail2ban blocks malicious IPs
4. **Automatic Updates**: Security patches applied automatically
5. **System Monitoring**: Daily security checks and logging
6. **Strong Authentication**: Secure API keys and rate limiting
7. **Encrypted Communication**: HTTPS enforced everywhere

### Firewall Configuration
The following ports must be open:
- 51820/udp (WireGuard)
- 80/tcp (HTTP - Caddy ACME challenges)
- 443/tcp (HTTPS - API endpoint)

## 🆘 Troubleshooting

### 🔧 Quick Fixes

**🚫 "Can't connect to VPN"**
```bash
# Check if WireGuard is running
sudo systemctl status wg-quick@wg0

# Restart if needed
sudo systemctl restart wg-quick@wg0

# Check server health from your computer
curl https://your-domain.com/health
```

**🌐 "Web interface won't load"**
- Wait 5-10 minutes after deployment for SSL certificates to be issued
- Check Cloudflare SSL setting: Dashboard → SSL/TLS → Overview → Set to "Full"
- Try `https://your-domain.com/health` first

**🔒 "SSL/TLS Certificate Errors"**
```bash
# Check certificate status on server
ssh root@your-server-ip
sudo journalctl -u caddy --since "10 minutes ago"

# Common fixes:
# 1. Wait 5-10 minutes for certificate issuance
# 2. Verify DNS is pointing to correct server IP
# 3. Check Cloudflare proxy status (should be orange cloud)
```

**🔑 "Authentication failed"**
- Check your auth key in the deployment script output
- Verify you're using the correct domain name

**🛠️ "wg-admin SSL errors"**
The `wg-admin` tool handles SSL certificate issues gracefully:
- It will detect SSL certificate problems automatically
- Offers option to retry without SSL verification during setup
- Provides clear guidance on waiting for certificate issuance
- Use `wg-admin setup` to reconfigure if needed

**📱 "Client won't connect"**
1. Make sure you copied the **full config** (starts with `[Interface]`)
2. Check the client setup script ran without errors
3. Verify the client name doesn't already exist

### 📞 Getting Help

**Check server logs:**
```bash
# SSH to your server
ssh root@your-server-ip

# Check service status
sudo systemctl status wg_service
sudo journalctl -u wg_service --since "1 hour ago"
```

**Test from command line:**
```bash
# Test API (replace with your details)
curl -H "Authorization: your-auth-key" https://your-domain.com/list_clients
```

**Common Solutions:**
- **Firewall blocking**: Check UFW settings on server
- **DNS issues**: Wait 10-15 minutes for DNS propagation  
- **SSL problems**: Ensure Cloudflare proxy is enabled (orange cloud)

### 💬 Community Support

- 🐛 **Report bugs**: [GitHub Issues](https://github.com/cwilliams001/auto-wg/issues)
- 💡 **Questions**: [GitHub Discussions](https://github.com/cwilliams001/auto-wg/discussions)
- 📖 **Wiki**: Check the [project wiki](https://github.com/cwilliams001/auto-wg/wiki) for guides

## 🎯 Real-World Examples

### 🏠 **Home Lab Access**
```bash
# Add your devices
wg-admin add laptop-work
wg-admin add phone  
wg-admin add tablet

# Now access your home network from anywhere!
```

### 💼 **Small Business VPN**
```bash
# Team members
wg-admin add alice-laptop
wg-admin add bob-phone
wg-admin add charlie-desktop

# Contractors (easy to revoke later)
wg-admin add contractor-temp
```

### 🌍 **Travel Security**
- Connect to your VPN from coffee shops, hotels, airports
- Your traffic routes through your server, not public WiFi
- Access region-locked content from your server's location

## 🚀 What's Next?

After you get Auto-WG running:

1. **📱 Install on all devices** - phones, laptops, tablets
2. **🔧 Explore the CLI tools** - `wg-admin` for power users  
3. **📊 Monitor usage** - check the web dashboard regularly
4. **🛡️ Security hardening** - consider additional firewall rules
5. **📈 Scale up** - deploy in multiple regions if needed

## 💡 Pro Tips

- **Use descriptive client names**: `alice-iphone`, `office-laptop`, `travel-tablet`
- **Regular maintenance**: Check the dashboard weekly, update when needed
- **Backup your config**: Keep your `deploy.config` file safe
- **Monitor costs**: Vultr usage rarely exceeds $6/month for normal use

## 🤝 Contributing

Love Auto-WG? Here's how to help:

- ⭐ **Star the repo** if it saved you time
- 🐛 **Report bugs** - help make it better for everyone  
- 💡 **Suggest features** - what would make your life easier?
- 📖 **Improve docs** - spotted something confusing?
- 🔧 **Submit PRs** - code contributions welcome!

## 📜 License

MIT License - use it, modify it, share it! See [LICENSE](LICENSE) for details.

## 🙏 Built With Love Using

- [WireGuard](https://www.wireguard.com/) - Fast, secure VPN protocol
- [Terraform](https://www.terraform.io/) - Infrastructure as code
- [Ansible](https://www.ansible.com/) - Configuration management  
- [Flask](https://flask.palletsprojects.com/) - Web framework
- [Caddy](https://caddyserver.com/) - Automatic HTTPS
- [Cloudflare](https://www.cloudflare.com/) - DNS and SSL
- [Vultr](https://vultr.com) - Cloud hosting

---

⭐ **Found this useful?** Give it a star on GitHub and help others discover Auto-WG!