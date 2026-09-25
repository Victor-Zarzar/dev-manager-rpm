#!/bin/bash

# ============================================
# DNF Package Installation Functions
# ============================================

install_git() {
    print_section "Installing Git"

    if command_exists git; then
        print_info "Git already installed ($(git --version))"
        return 0
    fi

    run_command "sudo $PKG_MGR install -y git" "Git installed"
}

_ensure_epel() {
    if [ "$IS_FEDORA" != true ] && ! rpm -q epel-release &> /dev/null; then
        run_command "sudo $PKG_MGR install -y epel-release" "EPEL repository enabled"
    fi
}

install_security_tools() {
    print_section "Installing Security Tools"

    _ensure_epel

    if rpm -q keepassxc &> /dev/null; then
        print_info "KeePassXC already installed"
    else
        run_command "sudo $PKG_MGR install -y keepassxc" "KeePassXC installed"
    fi

    if snap list 2>/dev/null | grep -q "localsend"; then
        print_info "LocalSend already installed"
    else
        run_command "sudo snap install localsend" "LocalSend installed"
    fi

    if rpm -q openvpn &> /dev/null; then
        print_info "OpenVPN already installed"
    else
        run_command "sudo $PKG_MGR install -y NetworkManager-openvpn openvpn" "OpenVPN installed"
    fi
}

install_python_env() {
    print_section "Installing Python Environment"

    if rpm -q python3-pip &> /dev/null; then
        print_info "python3-pip already installed"
    else
        run_command "sudo $PKG_MGR install -y python3-pip" "python3-pip installed"
    fi

    if ! pip3 list 2>/dev/null | grep -q "fastapi"; then
        run_command "pip3 install --user --break-system-packages fastapi uvicorn" "FastAPI and Uvicorn installed"
    else
        print_info "FastAPI and Uvicorn already installed"
    fi

    install_pipx
    install_leme

    log_action "Python environment configured"
}

install_nodejs_tools() {
    print_section "Installing Node.js Tools"

    if ! command_exists npm; then
        run_command "sudo $PKG_MGR install -y npm" "NPM installed"
    else
        print_info "NPM already installed ($(npm --version))"
    fi

    if command_exists pnpm; then
        print_info "PNPM already installed ($(pnpm --version))"
    else
        # "sudo npm install -g pnpm" often fails with "npm: command not found"
        # because sudo uses a restricted secure_path that doesn't include the
        # user's npm location. Use the official standalone installer instead
        # (same pattern already used for bun/nvm/pyenv in this script).
        print_info "Installing PNPM via the official standalone installer..."
        local user home_dir
        user="$(real_user)"
        home_dir=$(eval echo "~$user")

        if [ "$user" != "root" ]; then
            sudo -u "$user" bash -c "curl -fsSL https://get.pnpm.io/install.sh | sh -" >> "$LOG_FILE" 2>&1
        else
            curl -fsSL https://get.pnpm.io/install.sh | sh - >> "$LOG_FILE" 2>&1
        fi

        if [ -f "$home_dir/.local/share/pnpm/pnpm" ] || sudo -u "$user" bash -c "command -v pnpm" &>/dev/null; then
            print_success "PNPM installed for $user"
            log_action "PNPM installed"
            ((TOTAL_INSTALLED++))
            print_warning "Open a new shell (or run 'source ~/.bashrc') to use the 'pnpm' command"
        else
            print_error "Failed to install PNPM"
            log_action "FAILED: PNPM installed"
        fi
    fi

    print_info "NVM is available via option 20 (Install NVM)"
}

install_browsers() {
    print_section "Installing Additional Browsers"

    if command_exists google-chrome || command_exists google-chrome-stable; then
        print_info "Google Chrome already installed"
        return 0
    fi

    print_info "Installing Google Chrome..."
    if wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -O /tmp/chrome.rpm >> "$LOG_FILE" 2>&1; then
        run_command "sudo $PKG_MGR install -y /tmp/chrome.rpm" "Google Chrome installed"
        rm -f /tmp/chrome.rpm
    else
        print_error "Failed to download Chrome"
    fi

    print_info "Brave is available via Snap (option 9)"
}

install_utility_tools() {
    print_section "Installing Utility Tools"

    if rpm -q kdiskmark &> /dev/null; then
        print_info "KDiskMark already installed"
    else
        if ! run_command "sudo $PKG_MGR install -y kdiskmark" "Disk benchmark tool installed"; then
            print_warning "KDiskMark isn't available in the enabled repos on this distro (try a COPR repo)"
        fi
    fi

    if command_exists balena-etcher || rpm -q balena-etcher &> /dev/null; then
        print_info "Balena Etcher already installed"
    else
        print_info "Downloading Balena Etcher from GitHub..."
        local etcher_url
        etcher_url=$(curl -s https://api.github.com/repos/balena-io/etcher/releases/latest | grep "browser_download_url.*x86_64\.rpm" | cut -d '"' -f 4)

        if [ -n "$etcher_url" ]; then
            if wget -q "$etcher_url" -O /tmp/balena-etcher.rpm >> "$LOG_FILE" 2>&1; then
                run_command "sudo $PKG_MGR install -y /tmp/balena-etcher.rpm" "Balena Etcher installed"
                rm -f /tmp/balena-etcher.rpm
            else
                print_error "Failed to download Balena Etcher"
            fi
        else
            print_error "Failed to find Balena Etcher download URL"
        fi
    fi
}

install_system_tools() {
    print_section "Installing System Tools"

    if rpm -q openssh-server &> /dev/null; then
        print_info "SSH server already installed"
    else
        run_command "sudo $PKG_MGR install -y openssh-server" "SSH server installed"
        run_command "sudo systemctl enable --now sshd" "SSH server enabled"
    fi

    if rpm -q nano &> /dev/null; then
        print_info "Nano already installed"
    else
        run_command "sudo $PKG_MGR install -y nano" "Text editor"
    fi

    if command_exists spectacle || rpm -q kde-spectacle &> /dev/null || rpm -q spectacle &> /dev/null; then
        print_info "Spectacle already installed"
    else
        # The package was renamed from "kde-spectacle" to "spectacle" with the
        # Plasma 6 / KF6 transition on newer Fedora/Nobara releases.
        if run_command "sudo $PKG_MGR install -y spectacle" "Screenshot tool installed"; then
            :
        elif run_command "sudo $PKG_MGR install -y kde-spectacle" "Screenshot tool installed"; then
            :
        else
            print_warning "Neither 'spectacle' nor 'kde-spectacle' found - it's usually preinstalled on the KDE Plasma Desktop Edition spin"
        fi
    fi

    if rpm -q cmake &> /dev/null; then
        print_info "Build tools already installed"
    else
        run_command "sudo $PKG_MGR install -y cmake automake ninja-build clang" "Build tools installed"
    fi

    if rpm -q flatpak &> /dev/null; then
        print_info "Flatpak already installed"
    else
        run_command "sudo $PKG_MGR install -y flatpak" "Flatpak installed"
    fi

    if rpm -q java-21-openjdk-devel &> /dev/null; then
        print_info "OpenJDK 21 already installed"
    else
        run_command "sudo $PKG_MGR install -y java-21-openjdk-devel" "OpenJDK 21 installed"
    fi
}
