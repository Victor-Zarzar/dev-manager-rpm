#!/bin/bash

# ============================================
# Modern CLI / Shell Tools
# bat, eza, exa, zoxide, starship, Zim, FVM
# ============================================

# Appends a line to a rc file if it isn't already there (used by starship/zoxide init hooks)
_append_rc_line() {
    local rc_file="$1"
    local line="$2"
    local marker="$3"

    [ -f "$rc_file" ] || touch "$rc_file"

    if grep -qF "$marker" "$rc_file" 2>/dev/null; then
        return 0
    fi

    {
        echo ''
        echo "# $marker"
        echo "$line"
    } >> "$rc_file"
}

install_bat() {
    print_section "Installing bat (cat clone with syntax highlighting)"

    if command_exists bat || command_exists batcat; then
        print_info "bat already installed ($(bat --version 2>/dev/null || batcat --version 2>/dev/null))"
        return 0
    fi

    run_command "sudo $PKG_MGR install -y bat" "bat installed"
    print_info "Use 'bat <file>' instead of 'cat <file>' for syntax-highlighted output"
}

install_eza() {
    print_section "Installing eza (modern, maintained ls replacement)"

    if command_exists eza; then
        print_info "eza already installed ($(eza --version 2>/dev/null | head -n1))"
        return 0
    fi

    run_command "sudo $PKG_MGR install -y eza" "eza installed"
}

install_exa() {
    print_section "Installing exa"

    if command_exists exa; then
        print_info "exa already installed ($(exa --version 2>/dev/null | head -n1))"
        return 0
    fi

    print_warning "exa is unmaintained/archived upstream and was dropped from most current repos in favor of its fork, eza"

    if run_command "sudo $PKG_MGR install -y exa" "exa installed"; then
        return 0
    fi

    print_warning "exa isn't available in the enabled repos on this distro"
    print_info "Use option for eza instead (same features, actively maintained)"
    return 1
}

install_zoxide() {
    print_section "Installing zoxide (smarter cd)"

    if command_exists zoxide; then
        print_info "zoxide already installed ($(zoxide --version 2>/dev/null))"
    else
        if ! run_command "sudo $PKG_MGR install -y zoxide" "zoxide installed"; then
            print_info "Falling back to the official install script..."
            if curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash >> "$LOG_FILE" 2>&1; then
                print_success "zoxide installed via official script"
                log_action "zoxide installed via official script"
                ((TOTAL_INSTALLED++))
            else
                print_error "Failed to install zoxide"
                return 1
            fi
        fi
    fi

    local user home_dir
    user="$(real_user)"
    home_dir=$(eval echo "~$user")

    _append_rc_line "$home_dir/.bashrc" 'eval "$(zoxide init bash)"' "zoxide init (added by dev-setup-rpm-desktop)"
    if [ -f "$home_dir/.zshrc" ] || command_exists zsh; then
        _append_rc_line "$home_dir/.zshrc" 'eval "$(zoxide init zsh)"' "zoxide init (added by dev-setup-rpm-desktop)"
    fi

    print_info "'z <dir>' will jump to your most-used matching directory once the shell is reloaded"
}

install_starship() {
    print_section "Installing Starship prompt"

    if command_exists starship; then
        print_info "Starship already installed ($(starship --version 2>/dev/null))"
    else
        print_info "Installing Starship via the official installer..."
        if curl -sS https://starship.rs/install.sh | sh -s -- -y >> "$LOG_FILE" 2>&1; then
            print_success "Starship installed"
            log_action "Starship installed"
            ((TOTAL_INSTALLED++))
        else
            print_error "Failed to install Starship"
            return 1
        fi
    fi

    local user home_dir
    user="$(real_user)"
    home_dir=$(eval echo "~$user")

    _append_rc_line "$home_dir/.bashrc" 'eval "$(starship init bash)"' "Starship init (added by dev-setup-rpm-desktop)"
    if [ -f "$home_dir/.zshrc" ] || command_exists zsh; then
        _append_rc_line "$home_dir/.zshrc" 'eval "$(starship init zsh)"' "Starship init (added by dev-setup-rpm-desktop)"
    fi

    print_warning "Open a new shell (or run 'source ~/.bashrc') to see the new prompt"
    print_info "Customize it at ~/.config/starship.toml - see https://starship.rs/config/"
}

install_cli_enhancements() {
    print_section "Installing Modern CLI Enhancements"

    install_bat
    install_eza
    install_exa
    install_zoxide
    install_starship
}

install_zim() {
    print_section "Installing Zim (Zsh configuration framework)"

    if ! command_exists zsh; then
        print_info "Zsh is required for Zim - installing it first..."
        install_zsh
    fi

    local user home_dir
    user="$(real_user)"
    home_dir=$(eval echo "~$user")

    if [ -d "$home_dir/.zim" ]; then
        print_info "Zim already installed in $home_dir/.zim"
        return 0
    fi

    print_info "Installing Zim via the official installer..."
    if [ "$user" != "root" ]; then
        sudo -u "$user" bash -c "curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh" >> "$LOG_FILE" 2>&1
    else
        curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh >> "$LOG_FILE" 2>&1
    fi

    if [ -d "$home_dir/.zim" ]; then
        print_success "Zim installed in $home_dir/.zim"
        log_action "Zim installed"
        ((TOTAL_INSTALLED++))
        print_warning "Set Zsh as your default shell with: chsh -s \$(which zsh)"
        print_info "Tweak modules/themes in $home_dir/.zimrc, then run 'zimfw install'"
    else
        print_error "Failed to install Zim"
        log_action "FAILED: Zim installation"
        return 1
    fi
}

install_fvm() {
    print_section "Installing FVM (Flutter Version Management)"

    if command_exists fvm; then
        print_info "FVM already installed ($(fvm --version 2>/dev/null))"
        return 0
    fi

    local user home_dir
    user="$(real_user)"
    home_dir=$(eval echo "~$user")

    print_info "Installing FVM via the official installer..."
    if [ "$user" != "root" ]; then
        sudo -u "$user" bash -c "curl -fsSL https://fvm.app/install.sh | bash" >> "$LOG_FILE" 2>&1
    else
        curl -fsSL https://fvm.app/install.sh | bash >> "$LOG_FILE" 2>&1
    fi

    if sudo -u "$user" bash -c "command -v fvm" &>/dev/null || [ -f "$home_dir/.fvm_flutter/bin/fvm" ]; then
        print_success "FVM installed for $user"
        log_action "FVM installed"
        ((TOTAL_INSTALLED++))
        print_warning "Open a new shell (or run 'source ~/.bashrc') to use the 'fvm' command"
        print_info "Use 'fvm install <version>' and 'fvm use <version>' per project"
    else
        print_error "FVM was installed but isn't on PATH yet - open a new shell and check the installer output in $LOG_FILE"
        log_action "FVM install completed but verification failed - PATH issue likely"
    fi
}
