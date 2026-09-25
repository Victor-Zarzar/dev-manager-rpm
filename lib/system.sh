#!/bin/bash

# ============================================
# System Configuration Functions
# ============================================

OS_ID=""
OS_VERSION_ID=""
OS_ID_LIKE=""
IS_FEDORA=false
IS_NOBARA=false
PKG_MGR="dnf"

detect_os() {
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        OS_ID="$ID"
        OS_VERSION_ID="$VERSION_ID"
        OS_ID_LIKE="${ID_LIKE:-}"
    else
        print_error "Could not detect the operating system (/etc/os-release missing)"
        exit 1
    fi

    case "$OS_ID" in
        fedora)
            IS_FEDORA=true
            ;;
        nobara)
            # Nobara is a Fedora derivative (ID_LIKE="fedora"), not RHEL-based.
            # It has its own repos (e.g. nobara-nvidia-production) and doesn't need EPEL.
            IS_FEDORA=true
            IS_NOBARA=true
            ;;
        rhel|rocky|almalinux|centos)
            IS_FEDORA=false
            ;;
        *)
            if [[ "$OS_ID_LIKE" == *fedora* ]]; then
                print_info "Distribution '$OS_ID' is Fedora-based (ID_LIKE=\"$OS_ID_LIKE\"); treating as Fedora."
                IS_FEDORA=true
            else
                print_warning "Distribution '$OS_ID' not explicitly tested. Assuming RHEL compatibility."
                IS_FEDORA=false
            fi
            ;;
    esac

    if command_exists dnf; then
        PKG_MGR="dnf"
    elif command_exists yum; then
        PKG_MGR="yum"
    else
        print_error "Neither dnf nor yum found. This script requires Fedora/RHEL/Rocky/AlmaLinux."
        exit 1
    fi

    print_info "Detected system: $OS_ID $OS_VERSION_ID (package manager: $PKG_MGR)"
}

update_system() {
    print_section "Updating System"

    run_command "sudo $PKG_MGR upgrade -y" "System updated"
    run_command "sudo $PKG_MGR autoremove -y" "Unused packages removed"

    if ! rpm -q dnf-plugins-core &> /dev/null && [ "$PKG_MGR" = "dnf" ]; then
        run_command "sudo dnf install -y dnf-plugins-core" "dnf-plugins-core installed"
    fi

    for tool in curl wget unzip tar; do
        if ! command_exists "$tool"; then
            run_command "sudo $PKG_MGR install -y $tool" "$tool installed"
        fi
    done

    log_action "System updated"
}

setup_snapd() {
    print_section "Setting Up Snapd"

    if rpm -q snapd &> /dev/null; then
        print_info "Snapd already installed"
    else
        if [ "$IS_FEDORA" != true ]; then
            if ! rpm -q epel-release &> /dev/null; then
                run_command "sudo $PKG_MGR install -y epel-release" "EPEL repository enabled"
            fi
        fi

        # snapd-store's %post scriptlet is known to fail harmlessly on some distros
        # (it tries to copy a .desktop file that doesn't exist yet), which makes dnf5
        # report the whole transaction as failed even though snapd itself got installed.
        if run_command "sudo $PKG_MGR install -y snapd" "Snapd installed"; then
            :
        elif rpm -q snapd &> /dev/null; then
            print_warning "dnf reported an error, but 'snapd' is installed (harmless snapd-store %post scriptlet failure)"
            log_action "Snapd installed (non-fatal snapd-store post-script warning)"
            ((TOTAL_INSTALLED++))
        else
            print_error "Snapd installation failed"
        fi
    fi

    if [ -L /snap ] || [ -d /snap ]; then
        print_info "Snap symlink already exists"
    else
        run_command "sudo ln -sf /var/lib/snapd/snap /snap" "Snap symlink created"
    fi

    if systemctl is-active snapd.socket &> /dev/null; then
        print_info "Snapd service already active"
    else
        run_command "sudo systemctl enable --now snapd.socket" "Snapd service enabled"
    fi

    if command_exists getenforce && [ "$(getenforce)" = "Enforcing" ]; then
        print_warning "SELinux is Enforcing. Classic-confinement snaps may fail to run."
        print_info "If a snap fails to start, see: https://snapcraft.io/docs/installing-snap-on-fedora"
    fi

    print_warning "It can take a minute after install for 'snap' commands to become fully available"
    log_action "Snapd configured"
}

setup_directories() {
    print_section "Setting Up Directories"

    local dirs=(
        "$HOME/Projects"
    )

    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir" && print_success "Created: $dir" || print_error "Failed to create: $dir"
        else
            print_info "Already exists: $dir"
        fi
    done

    log_action "Directories configured"
}

install_zsh() {
    print_section "Installing Zsh"

    if command_exists zsh; then
        print_info "Zsh already installed ($(zsh --version))"
    else
        run_command "sudo $PKG_MGR install -y zsh" "Zsh installed"
    fi

    print_info "To make Zsh your default shell, run: chsh -s \$(which zsh)"
}
