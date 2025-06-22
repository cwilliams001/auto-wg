#!/bin/bash

# Auto-WG Destruction Script
# This script safely tears down all infrastructure and cleans up local files

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONFIG_FILE="deploy.config"
TERRAFORM_DIR="terraform"
ANSIBLE_DIR="ansible"

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
    command -v ansible-playbook >/dev/null 2>&1 || missing_deps+=("ansible")
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
    
    log_success "All dependencies found"
}

# Display current infrastructure
show_current_infrastructure() {
    log_info "Checking current infrastructure..."
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_warning "No deployment config found"
    else
        source "$CONFIG_FILE" 2>/dev/null || true
        echo ""
        echo -e "${BLUE}Current Configuration:${NC}"
        echo "  Domain: ${DOMAIN_NAME:-Not set}"
    fi
    
    # Check Terraform state
    if [[ -f "$TERRAFORM_DIR/terraform.tfstate" ]]; then
        echo ""
        echo -e "${BLUE}Active Cloud Resources:${NC}"
        cd "$TERRAFORM_DIR"
        
        # Show current resources
        if command -v jq >/dev/null 2>&1; then
            terraform show -json 2>/dev/null | jq -r '
                .values.root_module.resources[]? | 
                select(.type == "vultr_instance") | 
                "  💰 Vultr Instance: " + .values.label + " (" + .values.main_ip + ") - " + .values.plan
            ' 2>/dev/null || echo "  💰 Vultr resources detected in state"
            
            terraform show -json 2>/dev/null | jq -r '
                .values.root_module.resources[]? | 
                select(.type == "cloudflare_record") | 
                "  🌐 Cloudflare DNS: " + .values.name + " -> " + .values.value
            ' 2>/dev/null || echo "  🌐 Cloudflare resources detected in state"
        else
            echo "  💰 Terraform state contains active resources"
            terraform show 2>/dev/null | grep -E "(vultr_instance|cloudflare_)" | head -5 || true
        fi
        
        cd ..
    else
        echo "  ✅ No Terraform state found - no cloud resources"
    fi
    
    echo ""
}

# Confirm destruction
confirm_destruction() {
    log_warning "⚠️  DESTRUCTIVE OPERATION ⚠️"
    echo ""
    echo "This will:"
    echo "  💰 Destroy Vultr server instance (stops billing)"
    echo "  🌐 Remove Cloudflare DNS records" 
    echo "  🗑️  Delete all Terraform state files"
    echo "  📁 Remove local configuration and client files"
    echo ""
    echo "This action cannot be undone!"
    echo ""
    
    read -p "Type 'DESTROY' to confirm complete infrastructure destruction: " confirm
    
    if [[ "$confirm" != "DESTROY" ]]; then
        log_info "Destruction cancelled"
        exit 0
    fi
}

# Destroy cloud infrastructure with Terraform
destroy_terraform_infrastructure() {
    log_info "Destroying cloud infrastructure with Terraform..."
    
    if [[ ! -d "$TERRAFORM_DIR" ]]; then
        log_warning "Terraform directory not found"
        return
    fi
    
    cd "$TERRAFORM_DIR"
    
    # Check if terraform.tfvars exists
    if [[ ! -f "terraform.tfvars" ]]; then
        log_warning "terraform.tfvars not found - may need manual cleanup"
        if [[ -f "../$CONFIG_FILE" ]]; then
            log_info "Attempting to recreate terraform.tfvars from deploy config..."
            source "../$CONFIG_FILE"
            
            cat > "terraform.tfvars" << EOF
vultr_api_key         = "$VULTR_API_KEY"
ssh_key_id           = "$SSH_KEY_ID"
wireguard_auth_key   = "$WIREGUARD_AUTH_KEY"
cloudflare_api_token = "$CLOUDFLARE_API_TOKEN"
cloudflare_zone_id   = "$CLOUDFLARE_ZONE_ID"
domain_name          = "$DOMAIN_NAME"
enable_zone_settings = false
EOF
            log_success "Recreated terraform.tfvars from config"
        fi
    fi
    
    # Initialize Terraform if needed
    if [[ ! -f ".terraform.lock.hcl" ]]; then
        log_info "Initializing Terraform..."
        terraform init
    fi
    
    # Show what will be destroyed
    log_info "Planning destruction..."
    if terraform plan -destroy -var-file="terraform.tfvars" -out=destroy.tfplan; then
        echo ""
        log_warning "Review the destruction plan above"
        read -p "Proceed with destroying cloud resources? (y/N): " proceed
        
        if [[ ! $proceed =~ ^[Yy]$ ]]; then
            log_info "Terraform destruction cancelled"
            cd ..
            return
        fi
        
        # Execute destruction
        log_info "Executing Terraform destroy..."
        terraform apply destroy.tfplan
        
        # Clean up plan file
        rm -f destroy.tfplan
        
        log_success "Cloud infrastructure destroyed successfully"
    else
        log_error "Terraform plan failed"
        log_info "You may need to manually clean up resources in:"
        log_info "  • Vultr dashboard: https://my.vultr.com/"
        log_info "  • Cloudflare dashboard: https://dash.cloudflare.com/"
    fi
    
    cd ..
}

# Clean up local files and state
cleanup_local_files() {
    log_info "Cleaning up local files and state..."
    
    # Remove Terraform files
    if [[ -d "$TERRAFORM_DIR" ]]; then
        cd "$TERRAFORM_DIR"
        rm -rf .terraform .terraform.lock.hcl terraform.tfstate* terraform.tfvars *.tfplan 2>/dev/null || true
        cd ..
        echo "  ✓ Removed Terraform state and configuration"
    fi
    
    # Remove configuration files
    [[ -f "$CONFIG_FILE" ]] && rm -f "$CONFIG_FILE" && echo "  ✓ Removed $CONFIG_FILE"
    
    # Remove client directory
    [[ -d "client" ]] && rm -rf client && echo "  ✓ Removed client directory"
    
    # Remove Ansible inventory files
    [[ -f "$ANSIBLE_DIR/inventory/hosts" ]] && rm -f "$ANSIBLE_DIR/inventory/hosts" && echo "  ✓ Removed Ansible inventory"
    
    # Remove any backup files
    find . -name "*.bak" -delete 2>/dev/null && echo "  ✓ Removed backup files"
    
    log_success "Local cleanup completed"
}

# Optional: Clean up server before destroying (if accessible)
cleanup_remote_server() {
    if [[ ! -f "$CONFIG_FILE" ]] || [[ ! -f "$TERRAFORM_DIR/terraform.tfstate" ]]; then
        return
    fi
    
    log_info "Attempting to clean up server before destruction..."
    
    cd "$TERRAFORM_DIR"
    SERVER_IP=$(terraform output -raw wireguard_ip 2>/dev/null || echo "")
    cd ..
    
    if [[ -n "$SERVER_IP" ]]; then
        # Test if server is accessible
        if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@$SERVER_IP "echo 'Server accessible'" >/dev/null 2>&1; then
            log_info "Server accessible, running cleanup playbook..."
            
            cd "$ANSIBLE_DIR"
            echo "[wireguard_servers]" > inventory/destroy_hosts
            echo "$SERVER_IP ansible_user=root ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory/destroy_hosts
            
            ansible-playbook -i inventory/destroy_hosts destroy.yml || log_warning "Remote cleanup failed"
            rm -f inventory/destroy_hosts
            cd ..
        else
            log_info "Server not accessible, skipping remote cleanup"
        fi
    fi
}

# Show completion message
show_completion_message() {
    echo ""
    echo -e "${GREEN}🧹 Auto-WG Infrastructure Completely Destroyed! 🧹${NC}"
    echo ""
    echo -e "${BLUE}What was removed:${NC}"
    echo "  💰 Vultr server instance (billing stopped)"
    echo "  🌐 Cloudflare DNS records" 
    echo "  🗑️  All Terraform state files"
    echo "  📁 Local configuration and client files"
    echo ""
    echo -e "${GREEN}✅ No cloud resources remain - no ongoing costs!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  • Verify in Vultr dashboard: https://my.vultr.com/"
    echo "  • Verify in Cloudflare dashboard: https://dash.cloudflare.com/"
    echo "  • To redeploy: ./deploy.sh"
}

# Cleanup function for errors
cleanup_on_error() {
    if [[ $? -ne 0 ]]; then
        log_error "Destruction process failed!"
        log_warning "IMPORTANT: Check cloud dashboards for remaining resources:"
        log_warning "  💰 Vultr: https://my.vultr.com/"
        log_warning "  🌐 Cloudflare: https://dash.cloudflare.com/"
        log_warning "Manual cleanup may be required to stop billing!"
    fi
}

# Main destruction function
main() {
    echo -e "${RED}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                   Auto-WG Destroyer                         ║"
    echo "║           Complete Infrastructure Removal                   ║"
    echo "║         (Stops all cloud billing and costs!)               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Set up cleanup trap
    trap cleanup_on_error EXIT
    
    # Pre-flight checks
    check_root
    check_dependencies
    
    # Show current state and confirm
    show_current_infrastructure
    confirm_destruction
    
    # Clean up server first (optional)
    cleanup_remote_server
    
    # Destroy cloud infrastructure (MOST IMPORTANT)
    destroy_terraform_infrastructure
    
    # Clean up local files
    cleanup_local_files
    
    # Success
    show_completion_message
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi