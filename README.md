# Auto-WireGuard (auto-wg)

A streamlined, self-hosted WireGuard VPN configuration and management system. Inspired by Tailscale, `auto-wg` simplifies VPN setup by automating server provisioning, configuration, and client onboarding.

---

## 🗂 Overview

`auto-wg` consists of:

1. **Terraform**: Automates VPS provisioning on Vultr.
2. **Ansible**: Configures the server with WireGuard and supporting services.
3. **WireGuard Configuration Service**: A Python-based Flask API for managing VPN configurations.
4. **Client Setup Script**: Automatically configures client devices to connect to the server.

This system enables clients to request WireGuard configurations from a central server using secure authentication keys.

---

## 🛠 Requirements

### Server
- **OS**: Ubuntu 22.04 or later
- **Python**: 3.10 or later
- Installed packages:
  - WireGuard
  - Flask

### Client
- **Python**: 3.10 or later

### Local Development
- Terraform
- Ansible
- Python 3.10 or later

---

## 🚀 Deployment Steps

### 1. Server Deployment

1. Clone the repository:
   ```bash
   git clone https://github.com/cwilliams001/auto-wg.git
   cd auto-wg
   ```

2. Configure Terraform:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your provider credentials and configuration
   ```

3. Deploy the infrastructure:
   ```bash
   terraform init
   terraform apply
   ```

### 2. Provision the Server with Ansible

Ansible handles the server configuration, including installing WireGuard and deploying the Flask service. The server will be ready to issue WireGuard configurations to clients.

---

## 🔑 Configuration

### Server Configuration

The server configuration can be customized in `ansible/vars/main.yml`. Below are the key parameters:

```yaml
wireguard_config_path: /etc/wireguard/wg0.conf
wireguard_network: "10.0.0.0/24"
wireguard_address: "10.0.0.1/24"
wireguard_port: 51820
wireguard_dns_servers:
  - "8.8.8.8"
  - "8.8.4.4"
wg_service_dir: /opt/wg_service
wg_service_port: 5000
auth_keys:
  - "your-secure-key-here"
```

1. **Generate a Secure Authentication Key**: 
   ```bash
   openssl rand -base64 32
   ```
2. Replace `your-secure-key-here` with this key in the `auth_keys` section above.

---

### Client Setup

The client script uses:
- Server's IP address
- Authentication key
- Automatically determined client hostname

Modify the script parameters in `client/client_setup.py` if necessary.

---

## 💡 Usage

### Adding a New Client

1. Run the client setup script **on the client device**:
   ```bash
   sudo python3 client_setup.py
   ```
2. The script will:
   - Install required packages.
   - Automatically retrieve WireGuard configuration from the server.
   - Configure the WireGuard interface and enable the connection.

---

### Managing Clients

#### - **List Connected Clients**:
   ```bash
   curl -H "Authorization: your-auth-key" http://<SERVER_IP>:5000/list_clients
   ```

#### - **Check Server Health**:
   ```bash
   curl http://<SERVER_IP>:5000/health
   ```

---

## 🌐 API Endpoints

### 1. Generate Client Configuration
- **Endpoint**: `POST /generate_config`
- **Authorization**: Required
- **Body (JSON)**:
  ```json
  {
    "client_name": "device-name"
  }
  ```
- **Response**: WireGuard configuration and assigned IP.

### 2. List Clients
- **Endpoint**: `GET /list_clients`
- **Authorization**: Required
- **Response**: List of connected client names and IPs.

### 3. Server Health Check
- **Endpoint**: `GET /health`
- **Response**: Server health status.

---

## 🔐 Security Considerations

1. Always use strong authentication keys.
2. Safeguard the server's private key.
3. Regularly update packages and dependencies.
4. Use firewalls (e.g., UFW) to restrict access to WireGuard ports.
5. Monitor server logs for abnormal activity.
6. Enable HTTPS for secure API communication (recommended for production).
7. Implement rate limiting to prevent abuse.

---

## 📂 Project Structure

```plaintext
auto-wg/
├── ansible/              # Server provisioning and configuration
│   ├── inventory/
│   ├── roles/
│   │   ├── common/
│   │   ├── wireguard/
│   │   └── wg_service/
│   ├── vars/
│   └── site.yml
├── terraform/            # Infrastructure as Code for server provisioning
│   ├── variables.tf
│   ├── outputs.tf
│   └── vultr.tf
├── client/               # Client-side setup script
│   └── client_setup.py
```

---

## ⚠️ Troubleshooting

1. **Connection Issues**:
   - Ensure the server's firewall allows WireGuard port traffic (default: 51820).
   - Check the status of the WireGuard service on the server:
     ```bash
     sudo systemctl status wg-quick@wg0
     ```
   - Verify the client configuration.

2. **Configuration Errors**:
   - Ensure the authentication key matches on both the server and client.
   - Check the server logs for detailed error messages:
     ```bash
     journalctl -u wg_service
     ```
   - Validate IP address assignments to avoid conflicts.

---

## 🤝 Contributing

Contributions are welcome! Follow these steps:

1. Fork the repository.
2. Create a feature branch.
3. Commit your changes.
4. Push to the branch.
5. Create a pull request.

---

## 📖 Acknowledgements
- [WireGuard](https://www.wireguard.com/): The underlying VPN technology.
- [Tailscale](https://tailscale.com/): Inspiration for this project.
- [Flask](https://flask.palletsprojects.com/): The Python framework powering the service.
