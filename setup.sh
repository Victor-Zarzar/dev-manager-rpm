#!/bin/bash

# ============================================
# Fedora/RHEL Desktop Development Environment Setup
# Main Entry Point
# ============================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"
source "$SCRIPT_DIR/lib/system.sh"
source "$SCRIPT_DIR/lib/dnf.sh"
source "$SCRIPT_DIR/lib/snap.sh"
source "$SCRIPT_DIR/lib/flatpak.sh"
source "$SCRIPT_DIR/lib/fonts.sh"
source "$SCRIPT_DIR/lib/manual.sh"
source "$SCRIPT_DIR/lib/docker.sh"
source "$SCRIPT_DIR/lib/devops.sh"
source "$SCRIPT_DIR/lib/databases.sh"
source "$SCRIPT_DIR/lib/nginx.sh"
source "$SCRIPT_DIR/lib/dev.sh"
source "$SCRIPT_DIR/lib/git.sh"
source "$SCRIPT_DIR/lib/nvidia.sh"
source "$SCRIPT_DIR/lib/shell_tools.sh"

# ============================================
# Interactive Menu
# ============================================

# Global variables
TOTAL_INSTALLED=0
LOG_FILE="$HOME/rpm_desktop_setup_$(date +%Y%m%d_%H%M%S).log"

show_menu() {
    clear
    print_header
    echo "1)  Run complete setup"
    echo "2)  Update system"
    echo "3)  Setup Snapd"
    echo "4)  Setup directories"
    echo "5)  Install Git"
    echo "6)  Install text editors (Zed, Sublime)"
    echo "7)  Install security tools"
    echo "8)  Install Python environment"
    echo "9)  Install Snap applications"
    echo "10) Install Node.js tools"
    echo "11) Install Docker"
    echo "12) Install DevOps tools (Terraform, kubectl, Minikube, AWS CLI, Azure CLI, Ansible, eksctl, Prometheus)"
    echo "13) Install browsers"
    echo "14) Install fonts"
    echo "15) Install system tools"
    echo "16) Install utility tools"
    echo "17) Install Flatpak applications"
    echo "18) Install databases"
    echo "19) Install Nginx"
    echo "20) Install NVM"
    echo "21) Install Pyenv"
    echo "22) Install Zsh"
    echo "23) Configure Git"
    echo "24) Install Bun"
    echo "25) Install Nvidia drivers"
    echo "26) Install CLI enhancements (bat, eza, exa, zoxide, Starship)"
    echo "27) Install Zim (Zsh framework)"
    echo "28) Install FVM (Flutter Version Management)"
    echo "29) View installation log"
    echo "0)  Exit"
    echo ""
    echo -n "Choose an option: "
}

run_full_setup() {
    print_header
    echo -e "${YELLOW}Starting complete setup...${NC}\n"

    update_system
    setup_snapd
    setup_directories
    install_git
    install_editors
    install_security_tools
    install_python_env
    install_snap_apps
    install_nodejs_tools
    install_docker
    install_devops_tools
    install_browsers
    install_fonts
    install_system_tools
    install_utility_tools
    install_flatpak_apps
    install_databases
    install_nginx
    install_nvm
    install_pyenv
    install_zsh
    configure_git
    install_bun
    install_nvidia_drivers
    install_cli_enhancements
    install_zim
    install_fvm

    echo ""
    print_section "Setup Summary"
    echo -e "${GREEN}Total operations completed:${NC} $TOTAL_INSTALLED"
    echo -e "${GREEN}Log file:${NC} $LOG_FILE"
    echo ""
    print_success "Setup complete!"
    print_warning "Please log out and back in for all changes to take effect"
    print_warning "Run 'chsh -s \$(which zsh)' to set Zsh as default shell"
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
    log_action "Starting setup script"

    while true; do
        show_menu
        read -r option

        case $option in
            1) run_full_setup ;;
            2) update_system ;;
            3) setup_snapd ;;
            4) setup_directories ;;
            5) install_git ;;
            6) install_editors ;;
            7) install_security_tools ;;
            8) install_python_env ;;
            9) install_snap_apps ;;
            10) install_nodejs_tools ;;
            11) install_docker ;;
            12) install_devops_tools ;;
            13) install_browsers ;;
            14) install_fonts ;;
            15) install_system_tools ;;
            16) install_utility_tools ;;
            17) install_flatpak_apps ;;
            18) install_databases ;;
            19) install_nginx ;;
            20) install_nvm ;;
            21) install_pyenv ;;
            22) install_zsh ;;
            23) configure_git ;;
            24) install_bun ;;
            25) install_nvidia_drivers ;;
            26) install_cli_enhancements ;;
            27) install_zim ;;
            28) install_fvm ;;
            29) cat "$LOG_FILE" | less ;;
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
