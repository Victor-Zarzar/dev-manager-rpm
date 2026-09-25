#!/bin/bash

# ============================================
# Fedora/RHEL Server Development Environment Setup
# Main Entry Point (headless server/VM - no GUI)
# ============================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"
source "$SCRIPT_DIR/lib/system.sh"
source "$SCRIPT_DIR/lib/git.sh"
source "$SCRIPT_DIR/lib/docker.sh"
source "$SCRIPT_DIR/lib/devops.sh"
source "$SCRIPT_DIR/lib/databases.sh"
source "$SCRIPT_DIR/lib/nginx.sh"
source "$SCRIPT_DIR/lib/dev.sh"

# ============================================
# Interactive Menu
# ============================================

# Global variables
TOTAL_INSTALLED=0
LOG_FILE="$HOME/rpm_server_setup_$(date +%Y%m%d_%H%M%S).log"

show_menu() {
    clear
    print_header
    echo "1)  Run complete setup"
    echo "2)  Update system"
    echo "3)  Install Git"
    echo "4)  Install Docker + Docker Compose v2"
    echo "5)  Install Terraform"
    echo "6)  Install Kubernetes (kubectl)"
    echo "7)  Install Minikube"
    echo "8)  Install AWS CLI"
    echo "9)  Install Azure CLI"
    echo "10) Install Ansible"
    echo "11) Install eksctl"
    echo "12) Install Prometheus"
    echo "13) Install SQLite"
    echo "14) Install MySQL"
    echo "15) Install PostgreSQL"
    echo "16) Install Redis"
    echo "17) Install Nginx"
    echo "18) Install NVM"
    echo "19) Install Pyenv"
    echo "20) Configure Git"
    echo "21) View installation log"
    echo "0)  Exit"
    echo ""
    echo -n "Choose an option: "
}

run_full_setup() {
    print_header
    echo -e "${YELLOW}Starting complete server setup...${NC}\n"

    update_system
    install_git
    install_docker
    install_terraform
    install_kubectl
    install_minikube
    install_aws_cli
    install_azure_cli
    install_ansible
    install_eksctl
    install_prometheus
    install_sqlite
    install_mysql
    install_postgresql
    install_redis
    install_nginx
    install_nvm
    install_pyenv
    configure_git

    echo ""
    print_section "Setup Summary"
    echo -e "${GREEN}Total operations completed:${NC} $TOTAL_INSTALLED"
    echo -e "${GREEN}Log file:${NC} $LOG_FILE"
    echo ""
    print_success "Setup complete!"
    print_warning "Please log out and back in for Docker group changes to take effect"
    print_warning "Open a new shell (or 'source ~/.bashrc') to load NVM and Pyenv"
    echo ""

    log_action "Complete setup finished - Total operations: $TOTAL_INSTALLED"
}

# ============================================
# Main Loop
# ============================================

main() {
    if [ ! -f /etc/os-release ]; then
        print_error "Could not detect the operating system!"
        exit 1
    fi

    if ! grep -qiE 'fedora|rhel|rocky|almalinux|centos' /etc/os-release; then
        print_error "This script is for Fedora/RHEL/Rocky Linux/AlmaLinux/CentOS only!"
        exit 1
    fi

    touch "$LOG_FILE"
    detect_os
    log_action "Starting server setup script"

    while true; do
        show_menu
        read -r option

        case $option in
            1) run_full_setup ;;
            2) update_system ;;
            3) install_git ;;
            4) install_docker ;;
            5) install_terraform ;;
            6) install_kubectl ;;
            7) install_minikube ;;
            8) install_aws_cli ;;
            9) install_azure_cli ;;
            10) install_ansible ;;
            11) install_eksctl ;;
            12) install_prometheus ;;
            13) install_sqlite ;;
            14) install_mysql ;;
            15) install_postgresql ;;
            16) install_redis ;;
            17) install_nginx ;;
            18) install_nvm ;;
            19) install_pyenv ;;
            20) configure_git ;;
            21) cat "$LOG_FILE" | less ;;
            0)
                print_success "Goodbye!"
                log_action "Script finished"
                exit 0
                ;;
            *)
                print_error "Invalid option!"
                ;;
        esac

        echo ""
        read -p "Press ENTER to continue..."
    done
}

main
