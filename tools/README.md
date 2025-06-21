# Auto-WG Tools

This directory contains command-line tools to help manage your Auto-WG deployment.

## 🔧 wg-admin - CLI Management Tool

A powerful command-line interface for managing WireGuard clients.

### Installation

1. Copy `wg-admin` to your PATH:
```bash
sudo cp tools/wg-admin /usr/local/bin/
sudo chmod +x /usr/local/bin/wg-admin
```

2. Set up configuration:
```bash
wg-admin setup
```

### Usage

```bash
# Interactive setup
wg-admin setup

# List all clients
wg-admin list

# Add new client
wg-admin add laptop-home

# Check server health
wg-admin health

# Show detailed status
wg-admin status
```

### Configuration

The tool stores configuration in `~/.autowg/config`:

```ini
[server]
url = https://wg.yourdomain.com
auth_key = your-secret-auth-key
```

### Examples

**Setup from command line:**
```bash
wg-admin setup --server-url https://wg.example.com --auth-key your-key
```

**Add multiple clients:**
```bash
wg-admin add laptop
wg-admin add phone
wg-admin add tablet
```

**Check everything is working:**
```bash
wg-admin health && wg-admin status
```

## 🔒 security-audit - Security Assessment Tool

Comprehensive security audit tool that checks your deployed server for common security issues.

### Usage

```bash
# Use saved configuration
security-audit

# Specify server manually
security-audit --url https://wg.example.com --auth-key your-key

# Just connectivity check
security-audit --url https://wg.example.com
```

### What It Checks

- ✅ **Server Connectivity** - Can reach your server
- 🔒 **SSL/TLS Configuration** - HTTPS and security headers
- 🔑 **Authentication** - Proper auth key validation
- 🚦 **Rate Limiting** - Protection against abuse
- 🌐 **Exposed Endpoints** - No sensitive paths accessible
- 🔍 **Information Disclosure** - No debug info leaked

### Example Output

```
🔐 Auto-WG Security Audit
==================================================
🔍 Checking server connectivity...
✅ GOOD: Server is responding to health checks

🔒 Checking SSL/TLS configuration...
✅ GOOD: HTTPS connection successful
⚠️  WARNING: Missing security header: Strict-Transport-Security

📊 SECURITY AUDIT SUMMARY
==================================================
✅ Good practices: 8
⚠️  Warnings: 2
❌ Issues: 0

👍 GOOD! No critical issues, but some improvements possible.
```

## 🚀 Quick Start

1. **Deploy your server** using the deployment script:
   ```bash
   ./deploy.sh
   ```

2. **Install the CLI tool**:
   ```bash
   sudo cp tools/wg-admin /usr/local/bin/
   ```

3. **Set up the CLI** with your server details:
   ```bash
   wg-admin setup
   ```

4. **Add your first client**:
   ```bash
   wg-admin add my-laptop
   ```

5. **Use the generated config** on your client device by saving it to `/etc/wireguard/wg0.conf`

## 📋 Tips

- **Use descriptive client names**: `laptop-home`, `phone-work`, `server-backup`
- **Check health regularly**: `wg-admin health`
- **List clients to see what's connected**: `wg-admin list`
- **Keep your auth key secure** - it's stored in the config file with 600 permissions

## 🔒 Security Notes

- The auth key is stored securely with 600 permissions
- All communications use HTTPS
- Client names are validated to prevent injection attacks
- Rate limiting protects against abuse

## 🆘 Troubleshooting

**Connection errors:**
```bash
# Test basic connectivity
curl -k https://your-server.com/health

# Check your config
cat ~/.autowg/config
```

**Authentication errors:**
- Verify your auth key matches the server
- Check the server URL is correct
- Ensure HTTPS is working

**Permission errors:**
- Make sure the tool is executable: `chmod +x /usr/local/bin/wg-admin`
- Config file should have 600 permissions automatically