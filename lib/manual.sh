#!/bin/bash

# ============================================
# Manual Installation Functions
# ============================================

install_zed_editor() {
    print_section "Installing Zed Editor"

    if command_exists zed; then
        print_info "Zed Editor already installed ($(zed --version 2>/dev/null || echo 'version unknown'))"
        return 0
    fi

    print_info "Installing Zed Editor via official installer..."

    if curl -f https://zed.dev/install.sh | sh >> "$LOG_FILE" 2>&1; then
        print_success "Zed Editor installed successfully"
        log_action "Zed Editor installed"
        ((TOTAL_INSTALLED++))
        return 0
    else
        print_error "Failed to install Zed Editor"
        log_action "ERROR: Zed Editor installation failed"
        return 1
    fi
}

install_bun() {
    print_section "Installing Bun"

    if command_exists bun; then
        print_info "Bun already installed ($(bun --version))"
        return 0
    fi

    print_info "Installing Bun via official installer..."

    if curl -fsSL https://bun.sh/install | bash >> "$LOG_FILE" 2>&1; then
        print_success "Bun installed successfully"

        if ! grep -q '.bun/bin' "$HOME/.bashrc"; then
            echo '' >> "$HOME/.bashrc"
            echo '# Bun configuration' >> "$HOME/.bashrc"
            echo 'export BUN_INSTALL="$HOME/.bun"' >> "$HOME/.bashrc"
            echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> "$HOME/.bashrc"
            print_success "Bun added to .bashrc"
        fi

        log_action "Bun installed"
        ((TOTAL_INSTALLED++))
        return 0
    else
        print_error "Failed to install Bun"
        log_action "ERROR: Bun installation failed"
        return 1
    fi
}

install_editors() {
    print_section "Installing Text Editors"

    install_zed_editor

    if snap list 2>/dev/null | grep -q "sublime-text"; then
        print_info "Sublime Text already installed"
    else
        run_command "sudo snap install sublime-text --classic" "Sublime Text installed"
    fi
}
