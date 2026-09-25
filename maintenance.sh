#!/bin/bash

# ============================================
# Fedora/RHEL Desktop Maintenance & Cleaner
# Main Entry Point
# ============================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/helpers.sh"
source "$SCRIPT_DIR/lib/system.sh"
source "$SCRIPT_DIR/lib/package-clean.sh"
source "$SCRIPT_DIR/lib/node-clean.sh"
source "$SCRIPT_DIR/lib/flutter-clean.sh"
source "$SCRIPT_DIR/lib/android-clean.sh"
source "$SCRIPT_DIR/lib/docker-clean.sh"
source "$SCRIPT_DIR/lib/system-clean.sh"
source "$SCRIPT_DIR/lib/storage-optimize.sh"
source "$SCRIPT_DIR/lib/restart-system.sh"

# ============================================
# Interactive Menu
# ============================================

# Global variables
TOTAL_INSTALLED=0
LOG_FILE="$HOME/rpm_desktop_maintenance_$(date +%Y%m%d_%H%M%S).log"

show_menu() {
    clear
    print_header
    echo "1)  Run complete maintenance"
    echo "2)  Update system packages"
    echo "3)  Fix broken packages"
    echo "4)  Remove orphaned packages"
    echo "5)  Clean DNF cache"
    echo "6)  Clean Snap packages"
    echo "7)  Clean Flatpak"
    echo "8)  Clean NPM/NVM"
    echo "9)  Clean Bun"
    echo "10) Clean PNPM"
    echo "11) Clean Flutter/Dart/FVM"
    echo "12) Clean Android Studio"
    echo "13) Clean Docker"
    echo "14) Remove old kernels"
    echo "15) Clean logs"
    echo "16) Clean user caches"
    echo "17) Clean temporary files"
    echo "18) Clean PIP cache"
    echo "19) Optimize databases"
    echo "20) Verify system health"
    echo "21) View action log"
    echo "22) Restart system"
    echo "0)  Exit"
    echo ""
    echo -n "Choose an option: "
}

run_full_maintenance() {
    print_header
    echo -e "${YELLOW}Starting complete maintenance...${NC}\n"

    update_system
    fix_broken_packages
    remove_orphaned_packages
    clean_dnf_cache
    clean_snap
    clean_flatpak
    clean_npm_nvm
    clean_bun
    clean_pnpm
    clean_flutter_dart_fvm
    clean_android_studio
    clean_docker
    remove_old_kernels
    clean_logs
    clean_user_caches
    clean_temp_files
    clean_pip
    optimize_databases
    verify_system_health

    echo ""
    print_section "Maintenance Summary"
    echo -e "${GREEN}Total operations completed:${NC} $TOTAL_INSTALLED"
    echo -e "${GREEN}Log file:${NC} $LOG_FILE"
    echo ""
    print_success "Maintenance complete!"
    print_warning "A system restart is recommended, especially if old kernels were removed"
    echo ""

    log_action "Complete maintenance finished - Total operations: $TOTAL_INSTALLED"
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
    log_action "Starting maintenance script"

    while true; do
        show_menu
        read -r option

        case $option in
            1) run_full_maintenance ;;
            2) update_system ;;
            3) fix_broken_packages ;;
            4) remove_orphaned_packages ;;
            5) clean_dnf_cache ;;
            6) clean_snap ;;
            7) clean_flatpak ;;
            8) clean_npm_nvm ;;
            9) clean_bun ;;
            10) clean_pnpm ;;
            11) clean_flutter_dart_fvm ;;
            12) clean_android_studio ;;
            13) clean_docker ;;
            14) remove_old_kernels ;;
            15) clean_logs ;;
            16) clean_user_caches ;;
            17) clean_temp_files ;;
            18) clean_pip ;;
            19) optimize_databases ;;
            20) verify_system_health ;;
            21) cat "$LOG_FILE" | less ;;
            22) restart_system ;;
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
