#!/bin/bash

# ============================================
# Nginx Installation Functions
# ============================================

install_nginx() {
    print_section "Installing Nginx"

    if command_exists nginx; then
        print_info "Nginx already installed ($(nginx -v 2>&1))"
        return 0
    fi

    run_command "sudo $PKG_MGR install -y nginx" "Nginx installed"
    run_command "sudo systemctl enable --now nginx" "Nginx service enabled and started (port 80)"

    if command_exists firewall-cmd && sudo systemctl is-active --quiet firewalld; then
        run_command "sudo firewall-cmd --permanent --add-service=http" "Firewall: HTTP (80) allowed"
        run_command "sudo firewall-cmd --permanent --add-service=https" "Firewall: HTTPS (443) allowed"
        run_command "sudo firewall-cmd --reload" "Firewall reloaded"
    fi
}
