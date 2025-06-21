# 🚀 Getting Started with Auto-WG

**New to VPNs or self-hosting?** This guide will walk you through everything step-by-step.

## 🤔 What is Auto-WG?

Auto-WG creates your own private VPN server that you control completely. Think of it like having your own private tunnel through the internet that:

- **Protects your privacy** when using public WiFi
- **Secures your internet traffic** from prying eyes
- **Lets you access your home network** from anywhere
- **Costs less than commercial VPNs** (~$6/month vs $10-15/month)

## 🎯 What You'll Have When Done

- Your own VPN server running in the cloud
- A web dashboard to manage connected devices  
- The ability to connect phones, laptops, tablets securely
- Complete control - no third parties logging your data

## 📋 Step-by-Step Setup Guide

### Step 1: Get Your Accounts Ready (10 minutes)

#### 1.1 Sign up for Vultr (Your VPN Server Host)
- Go to [vultr.com](https://vultr.com)
- Sign up for an account
- Add a payment method
- **💡 Tip**: New users often get $100 credit!

#### 1.2 Sign up for Cloudflare (Free SSL Certificates)
- Go to [cloudflare.com](https://cloudflare.com) 
- Sign up for a free account
- We'll use this later for SSL certificates

#### 1.3 Get a Domain Name (If You Don't Have One)
You need a domain name like `yourdomain.com`. You can:
- Buy one from [Namecheap](https://namecheap.com), [GoDaddy](https://godaddy.com), etc. (~$10-15/year)
- Use a free subdomain service (less reliable)

### Step 2: Set Up Your Domain with Cloudflare (5 minutes)

1. **Add your domain to Cloudflare:**
   - In Cloudflare dashboard, click "Add a Site"
   - Enter your domain name
   - Choose the Free plan

2. **Update your domain's nameservers:**
   - Cloudflare will show you 2 nameservers (like `ns1.cloudflare.com`)
   - Go to your domain registrar (Namecheap, GoDaddy, etc.)
   - Update the nameservers to use Cloudflare's
   - **⏰ Wait 10-30 minutes** for this to take effect

### Step 3: Get Your API Keys (5 minutes)

#### 3.1 Vultr API Key
1. Go to [Vultr Account Settings](https://my.vultr.com/settings/#settingsapi)
2. Click "Generate API Key"
3. Copy the key somewhere safe

#### 3.2 Cloudflare API Token  
1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Click "Create Token"
3. Use "Custom token":
   - **Token name**: Auto-WG
   - **Permissions**: Zone:Edit, Zone:Read
   - **Zone Resources**: Include all zones
4. Click "Continue to summary" → "Create Token"
5. Copy the token somewhere safe

### Step 4: Deploy Your VPN Server (5 minutes)

Now the fun part! 

1. **Open your terminal** (Command Prompt on Windows, Terminal on Mac/Linux)

2. **Install Git** if you don't have it:
   ```bash
   # On Ubuntu/Debian:
   sudo apt update && sudo apt install git
   
   # On macOS (install Homebrew first from brew.sh):
   brew install git
   
   # On Windows: Download from git-scm.com
   ```

3. **Download and run Auto-WG**:
   ```bash
   git clone https://github.com/cwilliams001/auto-wg.git
   cd auto-wg
   chmod +x deploy.sh
   ./deploy.sh
   ```

4. **Follow the prompts**:
   - The script will check if you have the right tools
   - It will ask for your domain name (e.g., `vpn.yourdomain.com`)
   - It will ask for your email (for SSL certificates)
   - It will ask for your Vultr API key
   - It will ask for your Cloudflare API token
   - Then it will automatically deploy everything!

### Step 5: Access Your VPN Dashboard (2 minutes)

1. **Wait for the script to finish** (usually 3-5 minutes)
2. **Open your browser** and go to `https://yourdomain.com`
3. **You should see your Auto-WG dashboard!**

If it doesn't load immediately:
- Wait 2-3 more minutes for SSL certificates to activate
- Try `https://yourdomain.com/health` first

### Step 6: Connect Your First Device (3 minutes)

1. **In the web dashboard**, click "Add New Client"
2. **Enter a name** for your device (e.g., "my-laptop")
3. **Copy the configuration** that appears
4. **On your device**:
   
   **Linux/macOS:**
   ```bash
   # Install WireGuard
   sudo apt install wireguard  # Ubuntu/Debian
   brew install wireguard-tools # macOS
   
   # Save the config
   sudo nano /etc/wireguard/wg0.conf
   # Paste the configuration you copied
   
   # Connect!
   sudo wg-quick up wg0
   ```
   
   **Windows:**
   - Download [WireGuard for Windows](https://www.wireguard.com/install/)
   - Click "Add Tunnel" → "Add empty tunnel"
   - Paste your configuration
   - Click "Activate"

### Step 7: Test Your Connection

1. **Check your IP address**:
   - Before VPN: Go to [whatismyip.com](https://whatismyip.com)
   - After VPN: Go to [whatismyip.com](https://whatismyip.com) again
   - The IP should be different (your VPN server's IP)

2. **Test the connection**:
   ```bash
   # Should show your VPN interface
   sudo wg show
   ```

## 🎉 You're Done!

Congratulations! You now have:
- ✅ Your own private VPN server
- ✅ A web dashboard to manage it
- ✅ Your first device connected securely

## 🔄 Adding More Devices

For each new device (phone, tablet, another laptop):
1. Go to your web dashboard
2. Click "Add New Client"  
3. Give it a unique name
4. Copy the config to that device
5. Connect!

## ❓ Common Questions

**Q: How much does this cost?**
A: About $6/month for the Vultr server + domain costs (~$10-15/year)

**Q: Is this secure?**  
A: Yes! You control the server, WireGuard is military-grade encryption, and everything uses HTTPS.

**Q: Can I add my phone?**
A: Absolutely! Install the WireGuard app and scan the QR code (if your dashboard supports it) or copy the config.

**Q: What if something breaks?**
A: Check the [troubleshooting section](README.md#troubleshooting) in the main README.

**Q: Can I use this for my business?**
A: Yes! Add team members as clients and manage them through the web interface.

## 🆘 Need Help?

- 📖 **Full documentation**: [README.md](README.md)
- 🐛 **Report issues**: [GitHub Issues](https://github.com/cwilliams001/auto-wg/issues)
- 💬 **Ask questions**: [GitHub Discussions](https://github.com/cwilliams001/auto-wg/discussions)

Welcome to the world of self-hosted VPNs! 🎊