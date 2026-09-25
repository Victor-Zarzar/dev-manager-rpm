#!/bin/bash

# ============================================
# NVIDIA Driver Installation Functions
# ============================================

check_nvidia_gpu() {
    if lspci | grep -i nvidia &> /dev/null; then
        return 0
    else
        return 1
    fi
}

_install_nvidia_fedora() {
    print_info "Fedora detected - installing via RPM Fusion (akmod-nvidia)"

    local fedora_ver
    fedora_ver=$(rpm -E %fedora)

    if ! rpm -q rpmfusion-free-release &> /dev/null; then
        run_command "sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_ver}.noarch.rpm" "RPM Fusion Free repository added"
    else
        print_info "RPM Fusion Free repository already enabled"
    fi

    if ! rpm -q rpmfusion-nonfree-release &> /dev/null; then
        run_command "sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_ver}.noarch.rpm" "RPM Fusion Nonfree repository added"
    else
        print_info "RPM Fusion Nonfree repository already enabled"
    fi

    run_command "sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda" "NVIDIA driver (akmod-nvidia) installed"

    print_info "Waiting for the akmod kernel module to build (this can take a few minutes)..."
    run_command "sudo akmods --force" "akmod kernel module built"
    run_command "sudo dracut --force" "initramfs regenerated"

    print_warning "IMPORTANT: Reboot your system for changes to take effect"
    print_info "After reboot, verify with: modinfo -F version nvidia && nvidia-smi"
}

_install_nvidia_nobara() {
    print_info "Nobara detected - NVIDIA drivers are managed by Nobara's own repo (nobara-nvidia-production)"
    print_info "RPM Fusion and ELRepo are NOT used on Nobara and will conflict with its akmod-nvidia/dkms-nvidia packages"

    if rpm -q dkms-nvidia &> /dev/null || rpm -q akmod-nvidia &> /dev/null || rpm -q nvidia-driver &> /dev/null; then
        print_info "An NVIDIA driver package is already installed by Nobara"
        print_info "Run 'sudo $PKG_MGR upgrade' to update it, or after a kernel update run: sudo akmods --force && sudo dracut --force"
        return 0
    fi

    run_command "sudo $PKG_MGR install -y akmod-nvidia xorg-x11-drv-nvidia-cuda" "NVIDIA driver (akmod-nvidia) installed"

    print_info "Waiting for the akmod kernel module to build (this can take a few minutes)..."
    run_command "sudo akmods --force" "akmod kernel module built"
    run_command "sudo dracut --force" "initramfs regenerated"

    print_warning "IMPORTANT: Reboot your system for changes to take effect"
    print_info "After reboot, verify with: modinfo -F version nvidia && nvidia-smi"
}

_install_nvidia_rhel_family() {
    print_info "RHEL/Rocky/AlmaLinux detected - installing via ELRepo (kmod-nvidia)"

    local major_ver
    major_ver=$(echo "$OS_VERSION_ID" | cut -d. -f1)

    if ! rpm -q epel-release &> /dev/null; then
        run_command "sudo $PKG_MGR install -y epel-release" "EPEL repository enabled"
    fi

    if ! rpm -q elrepo-release &> /dev/null; then
        run_command "sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org" "ELRepo GPG key imported"
        run_command "sudo $PKG_MGR install -y https://www.elrepo.org/elrepo-release-${major_ver}.el${major_ver}.elrepo.noarch.rpm" "ELRepo repository added"
    else
        print_info "ELRepo repository already enabled"
    fi

    run_command "sudo $PKG_MGR install -y kmod-nvidia nvidia-x11-drv nvidia-x11-drv-cuda" "NVIDIA driver (kmod-nvidia) installed"

    print_warning "IMPORTANT: Reboot your system for changes to take effect"
    print_info "After reboot, verify with: nvidia-smi"
}

install_nvidia_drivers() {
    print_section "Installing NVIDIA Drivers"

    if ! check_nvidia_gpu; then
        print_warning "No NVIDIA GPU detected on this system"
        print_info "Skipping NVIDIA driver installation"
        return 0
    fi

    print_success "NVIDIA GPU detected!"

    if command_exists nvidia-smi; then
        print_info "NVIDIA driver already installed"

        local driver_version
        driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -n1)
        if [ -n "$driver_version" ]; then
            print_info "Driver version: $driver_version"
        fi

        echo -n "Do you want to reinstall/update NVIDIA drivers? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_info "Skipping NVIDIA driver installation"
            return 0
        fi
    fi

    if command_exists getenforce && [ "$(getenforce)" = "Enforcing" ]; then
        print_warning "SELinux is Enforcing. If the driver fails to load after reboot, check 'sudo ausearch -m avc -ts recent'"
    fi

    if [ "$IS_NOBARA" = true ]; then
        _install_nvidia_nobara
    elif [ "$IS_FEDORA" = true ]; then
        _install_nvidia_fedora
    else
        _install_nvidia_rhel_family
    fi

    log_action "NVIDIA driver installation completed for: $OS_ID $OS_VERSION_ID"
}
