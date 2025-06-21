#!/bin/bash

# Auto-WG One-Command Deployment Script
# This script automates the entire deployment process

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONFIG_FILE="deploy.config"
TFVARS_FILE="terraform/terraform.tfvars"
ANSIBLE_VARS_FILE="ansible/vars/main.yml"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing_deps=()
    
    command -v terraform >/dev/null 2>&1 || missing_deps+=("terraform")
    command -v ansible >/dev/null 2>&1 || missing_deps+=("ansible")
    command -v python3 >/dev/null 2>&1 || missing_deps+=("python3")
    command -v git >/dev/null 2>&1 || missing_deps+=("git")
    command -v curl >/dev/null 2>&1 || missing_deps+=("curl")
    command -v openssl >/dev/null 2>&1 || missing_deps+=("openssl")
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Please install the missing dependencies and run this script again."
        exit 1
    fi
    
    log_success "All dependencies found"
}

# Generate secure authentication key
generate_auth_key() {
    openssl rand -base64 32
}

# Interactive configuration
configure_deployment() {
    log_info "Setting up deployment configuration..."
    
    # Check if config file exists
    if [[ -f "$CONFIG_FILE" ]]; then
        log_info "Found existing configuration. Loading..."
        source "$CONFIG_FILE"
        
        echo -e "\nCurrent configuration:"
        echo "Domain: ${DOMAIN_NAME:-Not set}"
        echo "Vultr API Key: ${VULTR_API_KEY:0:10}... (hidden)"
        echo "Cloudflare API Token: ${CLOUDFLARE_API_TOKEN:0:10}... (hidden)"
        echo ""
        
        read -p "Use existing configuration? (y/n): " use_existing
        if [[ $use_existing =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    echo -e "\n${BLUE}Auto-WG Deployment Configuration${NC}"
    echo "Please provide the following information:"
    echo ""
    
    # Domain name
    while [[ -z "$DOMAIN_NAME" ]]; do
        read -p "Domain name for WireGuard service (e.g., wg.yourdomain.com): " DOMAIN_NAME
        if [[ ! "$DOMAIN_NAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]+[a-zA-Z0-9]$ ]]; then
            log_warning "Invalid domain name format"
            DOMAIN_NAME=""
        fi
    done
    
    # Email for SSL certificates
    while [[ -z "$SSL_EMAIL" ]]; do
        read -p "Email address for SSL certificates: " SSL_EMAIL
        if [[ ! "$SSL_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            log_warning "Invalid email format"
            SSL_EMAIL=""
        fi
    done
    
    # Vultr API key
    while [[ -z "$VULTR_API_KEY" ]]; do
        read -s -p "Vultr API Key: " VULTR_API_KEY
        echo ""
        if [[ ${#VULTR_API_KEY} -lt 20 ]]; then
            log_warning "API key seems too short"
            VULTR_API_KEY=""
        fi
    done
    
    # Cloudflare API token
    while [[ -z "$CLOUDFLARE_API_TOKEN" ]]; do
        read -s -p "Cloudflare API Token: " CLOUDFLARE_API_TOKEN
        echo ""
        if [[ ${#CLOUDFLARE_API_TOKEN} -lt 20 ]]; then
            log_warning "API token seems too short"
            CLOUDFLARE_API_TOKEN=""
        fi
    done
    
    # Get Cloudflare Zone ID automatically
    log_info "Fetching Cloudflare Zone ID..."
    CLOUDFLARE_ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" | \
        python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if data['success']:
        domain_parts = '$DOMAIN_NAME'.split('.')
        root_domain = '.'.join(domain_parts[-2:])
        for zone in data['result']:
            if zone['name'] == root_domain:
                print(zone['id'])
                break
    else:
        print('ERROR: ' + str(data['errors']))
except:
    print('ERROR: Failed to parse response')
")
    
    if [[ "$CLOUDFLARE_ZONE_ID" == ERROR* ]]; then
        log_error "Failed to get Cloudflare Zone ID: $CLOUDFLARE_ZONE_ID"
        exit 1
    elif [[ -z "$CLOUDFLARE_ZONE_ID" ]]; then
        log_error "Could not find zone for domain $DOMAIN_NAME"
        exit 1
    fi
    
    log_success "Found Cloudflare Zone ID: $CLOUDFLARE_ZONE_ID"
    
    # Get SSH key ID
    log_info "Fetching Vultr SSH keys..."
    echo ""
    echo "Available SSH keys:"
    curl -s -H "Authorization: Bearer $VULTR_API_KEY" https://api.vultr.com/v2/ssh-keys | \
        python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for i, key in enumerate(data['ssh_keys']):
        print(f\"{i+1}. {key['name']} ({key['id'][:8]}...)\")
except:
    print('ERROR: Failed to fetch SSH keys')
    sys.exit(1)
"
    
    echo ""
    read -p "Enter the number of the SSH key to use: " ssh_key_num
    SSH_KEY_ID=$(curl -s -H "Authorization: Bearer $VULTR_API_KEY" https://api.vultr.com/v2/ssh-keys | \
        python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    keys = data['ssh_keys']
    if 1 <= $ssh_key_num <= len(keys):
        print(keys[$ssh_key_num-1]['id'])
    else:
        print('ERROR: Invalid selection')
except:
    print('ERROR: Failed to parse SSH keys')
")
    
    if [[ "$SSH_KEY_ID" == ERROR* ]]; then
        log_error "Failed to get SSH key: $SSH_KEY_ID"
        exit 1
    fi
    
    # Generate auth key
    WIREGUARD_AUTH_KEY=$(generate_auth_key)
    
    # Save configuration
    cat > "$CONFIG_FILE" << EOF
# Auto-WG Deployment Configuration
DOMAIN_NAME="$DOMAIN_NAME"
SSL_EMAIL="$SSL_EMAIL"
VULTR_API_KEY="$VULTR_API_KEY"
CLOUDFLARE_API_TOKEN="$CLOUDFLARE_API_TOKEN"
CLOUDFLARE_ZONE_ID="$CLOUDFLARE_ZONE_ID"
SSH_KEY_ID="$SSH_KEY_ID"
WIREGUARD_AUTH_KEY="$WIREGUARD_AUTH_KEY"
EOF
    
    chmod 600 "$CONFIG_FILE"
    log_success "Configuration saved to $CONFIG_FILE"
}

# Create Terraform variables file
create_terraform_vars() {
    log_info "Creating Terraform variables file..."
    
    cat > "$TFVARS_FILE" << EOF
vultr_api_key         = "$VULTR_API_KEY"
ssh_key_id           = "$SSH_KEY_ID"
wireguard_auth_key   = "$WIREGUARD_AUTH_KEY"
cloudflare_api_token = "$CLOUDFLARE_API_TOKEN"
cloudflare_zone_id   = "$CLOUDFLARE_ZONE_ID"
domain_name          = "$DOMAIN_NAME"
EOF
    
    chmod 600 "$TFVARS_FILE"
    log_success "Terraform variables file created"
}

# Create Ansible variables file
create_ansible_vars() {
    log_info "Creating Ansible variables file..."
    
    cat > "$ANSIBLE_VARS_FILE" << EOF
---
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
  - "$WIREGUARD_AUTH_KEY"

domain_name: "$DOMAIN_NAME"
ssl_email: "$SSL_EMAIL"
EOF
    
    log_success "Ansible variables file created"
}

# Deploy infrastructure
deploy_infrastructure() {
    log_info "Deploying infrastructure with Terraform..."
    
    cd terraform
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    terraform init
    
    # Plan deployment
    log_info "Planning deployment..."
    terraform plan -var-file="terraform.tfvars"
    
    # Ask for confirmation
    echo ""
    read -p "Proceed with deployment? (y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        log_warning "Deployment cancelled"
        exit 1
    fi
    
    # Apply changes
    log_info "Applying changes..."
    terraform apply -var-file="terraform.tfvars" -auto-approve
    
    cd ..
    log_success "Infrastructure deployed successfully"
}

# Get server information
get_server_info() {
    log_info "Getting server information..."
    
    cd terraform
    SERVER_IP=$(terraform output -raw server_ip 2>/dev/null || echo "")
    cd ..
    
    if [[ -z "$SERVER_IP" ]]; then
        log_error "Could not get server IP address"
        exit 1
    fi
    
    log_success "Server IP: $SERVER_IP"
}

# Wait for server to be ready
wait_for_server() {
    log_info "Waiting for server to be ready..."
    
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@$SERVER_IP "echo 'Server ready'" >/dev/null 2>&1; then
            log_success "Server is ready"
            return
        fi
        
        log_info "Attempt $attempt/$max_attempts - waiting for server..."
        sleep 10
        ((attempt++))
    done
    
    log_error "Server did not become ready in time"
    exit 1
}

# Create client setup script
create_client_script() {
    log_info "Creating client setup script..."
    
    if [[ ! -f "client/client_setup.py" ]]; then
        log_warning "Client setup script not found. It should be created by Terraform."
        return
    fi
    
    chmod +x client/client_setup.py
    log_success "Client setup script is ready at client/client_setup.py"
}

# Display completion information
show_completion_info() {
    echo ""
    echo -e "${GREEN}🎉 Auto-WG Deployment Complete! 🎉${NC}"
    echo ""
    echo -e "${BLUE}Server Information:${NC}"
    echo "  IP Address: $SERVER_IP"
    echo "  Web UI: https://$DOMAIN_NAME"
    echo "  API Endpoint: https://$DOMAIN_NAME/generate_config"
    echo ""
    echo -e "${BLUE}Management:${NC}"
    echo "  • Visit https://$DOMAIN_NAME to manage clients via web interface"
    echo "  • API endpoints are available for programmatic access"
    echo "  • Client setup: Run client/client_setup.py on client devices"
    echo ""
    echo -e "${BLUE}Authentication:${NC}"
    echo "  Auth Key: $WIREGUARD_AUTH_KEY"
    echo "  (Keep this secure - it's needed for API access)"
    echo ""
    echo -e "${BLUE}Security Features:${NC}"
    echo "  • SSH hardened with key-only authentication"
    echo "  • UFW firewall configured and active"
    echo "  • Fail2ban protecting against brute force attacks"
    echo "  • Automatic security updates enabled"
    echo "  • System monitoring and logging configured"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "  1. Wait 2-3 minutes for services to fully start"
    echo "  2. Visit https://$DOMAIN_NAME to verify the web interface"
    echo "  3. Add your first client using the web interface"
    echo "  4. Copy client/client_setup.py to client devices"
    echo ""
    echo -e "${YELLOW}Configuration saved to: $CONFIG_FILE${NC}"
    echo -e "${YELLOW}Keep this file secure for future deployments!${NC}"
}

# Cleanup function
cleanup() {
    if [[ $? -ne 0 ]]; then
        log_error "Deployment failed!"
        log_info "Check the logs above for details"
        log_info "You can re-run this script to retry the deployment"
    fi
}

# Main deployment function
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                     Auto-WG Deployer                        ║"
    echo "║              One-Command WireGuard VPN Setup                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Set up cleanup trap
    trap cleanup EXIT
    
    # Pre-flight checks
    check_root
    check_dependencies
    
    # Configuration
    configure_deployment
    source "$CONFIG_FILE"
    
    # Create configuration files
    create_terraform_vars
    create_ansible_vars
    
    # Deploy
    deploy_infrastructure
    get_server_info
    wait_for_server
    create_client_script
    
    # Success
    show_completion_info
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi