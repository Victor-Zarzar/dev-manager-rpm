#!/bin/bash

# ============================================
# NVM, Pyenv, pipx, Leme
# ============================================

install_nvm() {
    print_section "Installing NVM"

    local user home_dir
    user="$(real_user)"
    home_dir=$(eval echo "~$user")

    if [ -d "$home_dir/.nvm" ]; then
        print_info "NVM already installed in $home_dir/.nvm"
        return 0
    fi

    print_info "Fetching the latest NVM release from GitHub..."
    local nvm_version
    nvm_version=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | cut -d '"' -f 4)
    nvm_version=${nvm_version:-v0.40.1}

    if [ "$user" != "root" ]; then
        sudo -u "$user" bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh | bash" >> "$LOG_FILE" 2>&1
    else
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh" | bash >> "$LOG_FILE" 2>&1
    fi

    if [ -d "$home_dir/.nvm" ]; then
        print_success "NVM $nvm_version installed in $home_dir/.nvm"
        log_action "NVM $nvm_version installed"
        ((TOTAL_INSTALLED++))
        print_warning "Open a new shell (or run 'source ~/.bashrc') to use the 'nvm' command"
    else
        print_error "Failed to install NVM"
    fi
}

install_pyenv() {
    print_section "Installing Pyenv"

    local user home_dir
    user="$(real_user)"
    home_dir=$(eval echo "~$user")

    if [ -d "$home_dir/.pyenv" ]; then
        print_info "Pyenv already installed in $home_dir/.pyenv"
        return 0
    fi

    print_info "Installing build dependencies for Pyenv..."
    run_command "sudo $PKG_MGR groupinstall -y 'Development Tools'" "'Development Tools' group installed"
    run_command "sudo $PKG_MGR install -y gcc make patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel" "Pyenv dependencies installed"

    if [ "$user" != "root" ]; then
        sudo -u "$user" bash -c "curl https://pyenv.run | bash" >> "$LOG_FILE" 2>&1
    else
        curl https://pyenv.run | bash >> "$LOG_FILE" 2>&1
    fi

    if [ -d "$home_dir/.pyenv" ]; then
        print_success "Pyenv installed in $home_dir/.pyenv"
        log_action "Pyenv installed"
        ((TOTAL_INSTALLED++))
        print_warning "Add to ~/.bashrc (or ~/.zshrc):"
        echo '  export PYENV_ROOT="$HOME/.pyenv"'
        echo '  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
        echo '  eval "$(pyenv init -)"'
    else
        print_error "Failed to install Pyenv"
    fi
}

install_pipx() {
    print_section "Installing pipx"

    local user home_dir
    user="$(real_user)"
    home_dir=$(eval echo "~$user")

    if command_exists pipx; then
        print_info "pipx already installed"
        return 0
    fi

    print_info "Installing pipx via pip..."
    run_command "sudo $PKG_MGR install -y python3-pip" "python3-pip installed"

    if [ "$user" != "root" ]; then
        sudo -u "$user" bash -c "python3 -m pip install --user pipx" >> "$LOG_FILE" 2>&1
        sudo -u "$user" bash -c "python3 -m pipx ensurepath" >> "$LOG_FILE" 2>&1
    else
        python3 -m pip install --user pipx >> "$LOG_FILE" 2>&1
        python3 -m pipx ensurepath >> "$LOG_FILE" 2>&1
    fi

    if sudo -u "$user" bash -c "command -v pipx" &>/dev/null || [ -f "$home_dir/.local/bin/pipx" ]; then
        print_success "pipx installed for $user"
        log_action "pipx installed"
        ((TOTAL_INSTALLED++))
        print_warning "Open a new shell (or run 'source ~/.bashrc') to use the 'pipx' command"
    else
        print_error "Failed to install pipx"
    fi
}

install_leme() {
    print_section "Installing Leme (DevOps CLI)"

    if command_exists leme; then
        print_info "Leme already installed ($(leme --version 2>&1))"
        return 0
    fi

    if command_exists pipx; then
        run_command "pipx install leme" "Leme DevOps CLI installed (pipx)"
    elif command_exists pip3; then
        run_command "pip3 install --user --break-system-packages leme" "Leme DevOps CLI installed (pip3)"
    else
        print_error "Neither pipx nor pip3 found - cannot install Leme"
        return 1
    fi

    export PATH="$HOME/.local/bin:$PATH"
    if command_exists leme; then
        print_success "Leme verified: $(leme --version 2>&1)"
        log_action "Leme installed and verified ($(leme --version 2>&1))"
    else
        print_error "Leme was installed but isn't on PATH yet. Add \$HOME/.local/bin to your PATH (restart terminal), then re-run this option."
        log_action "Leme install completed but verification failed - PATH issue likely"
    fi
}
