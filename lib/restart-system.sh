#!/bin/bash

# ============================================
# System Restart
# ============================================

restart_system() {
    print_section "Restart System"

    print_warning "This will restart the machine immediately."
    read -p "Are you sure you want to restart now? (y/N): " confirm

    case "$confirm" in
        y|Y|yes|YES)
            log_action "System restart requested by user"
            print_info "Restarting..."
            sudo systemctl reboot
            ;;
        *)
            print_info "Restart cancelled"
            ;;
    esac
}
