#!/bin/bash

# ============================================
# Extra Apps (Fedora/RHEL): Proton Authenticator + DaVinci Resolve
# ============================================

install_proton_authenticator() {
    print_section "Installing Proton Authenticator"

    if command_exists proton-authenticator || rpm -qa 2>/dev/null | grep -qi "proton-\?authenticator"; then
        print_info "Proton Authenticator already installed"
        return 0
    fi

    if [ "$(uname -m)" != "x86_64" ]; then
        print_warning "Proton Authenticator .rpm is only available for x86_64, skipping"
        return 0
    fi

    local tmp_dir json rpm_url rpm_sha rpm_file
    tmp_dir=$(mktemp -d)
    json="$tmp_dir/version.json"

    print_info "Fetching latest version info..."
    if ! curl -fsSL https://proton.me/download/authenticator/linux/version.json -o "$json" >> "$LOG_FILE" 2>&1; then
        print_error "Failed to fetch Proton Authenticator version info"
        rm -rf "$tmp_dir"
        return 1
    fi

    # The first .rpm entry in the JSON is the latest release
    rpm_url=$(grep -m1 -o 'https://[^"]*\.x86_64\.rpm' "$json")
    rpm_sha=$(grep -m1 -A1 '\.x86_64\.rpm"' "$json" | grep -o '[0-9a-f]\{128\}')

    if [ -z "$rpm_url" ]; then
        print_error "Could not find the .rpm URL in version.json"
        rm -rf "$tmp_dir"
        return 1
    fi

    rpm_file="$tmp_dir/ProtonAuthenticator.rpm"
    print_info "Downloading $(basename "$rpm_url")..."
    if ! curl -fsSL "$rpm_url" -o "$rpm_file" >> "$LOG_FILE" 2>&1; then
        print_error "Failed to download Proton Authenticator"
        rm -rf "$tmp_dir"
        return 1
    fi

    if [ -n "$rpm_sha" ]; then
        if echo "$rpm_sha  $rpm_file" | sha512sum --check --status; then
            print_success "SHA512 checksum verified"
        else
            print_error "Checksum mismatch, aborting installation"
            rm -rf "$tmp_dir"
            return 1
        fi
    else
        print_warning "Could not read the checksum from version.json, skipping verification"
    fi

    run_command "sudo dnf install -y '$rpm_file'" "Proton Authenticator installed"
    rm -rf "$tmp_dir"
    log_action "Proton Authenticator installed"
    ((TOTAL_INSTALLED++))
}

install_davinci_resolve() {
    print_section "Installing DaVinci Resolve (${RESOLVE_EDITION:-free})"

    if [ -x /opt/resolve/bin/resolve ]; then
        print_info "DaVinci Resolve already installed"
        return 0
    fi

    local edition="${RESOLVE_EDITION:-free}"   # free (padrão) | studio
    local src_dir="${RESOLVE_SRC_DIR:-$HOME/Downloads}"
    local work_dir="$HOME/resolve_build"

    print_info "Installing dependencies..."
    run_command "sudo dnf install -y unzip xcb-util-cursor apr apr-util mesa-libGLU libxcrypt-compat fuse-libs alsa-lib" "Resolve dependencies installed"

    local zip_file
    if [ "$edition" = "studio" ]; then
        zip_file=$(ls -1t "$src_dir"/DaVinci_Resolve_Studio_*_Linux.zip 2>/dev/null | head -n1)
    else
        zip_file=$(ls -1t "$src_dir"/DaVinci_Resolve_[0-9]*_Linux.zip 2>/dev/null | head -n1)
    fi

    if [ -z "$zip_file" ]; then
        print_warning "Manual download required (Blackmagic asks for a registration form)"
        print_error "Resolve ($edition) ZIP not found in $src_dir"
        print_info "Download it from https://www.blackmagicdesign.com/event/davinciresolvedownload"
        if command -v xdg-open &> /dev/null; then
            echo -n "Open the download page in your browser now? (y/N): "
            read -r open_resp
            if [[ "$open_resp" =~ ^[Yy]$ ]]; then
                xdg-open "https://www.blackmagicdesign.com/event/davinciresolvedownload" &> /dev/null &
            fi
        fi
        print_info "After downloading, run this option again"
        return 1
    fi

    print_info "Resolve ZIP: $(basename "$zip_file")"

    local free_gb
    free_gb=$(df -BG --output=avail "$HOME" | tail -n1 | tr -dc '0-9')
    if [ "${free_gb:-0}" -lt 15 ]; then
        print_warning "Only ${free_gb}GB free in \$HOME. Extraction needs roughly 15GB"
        echo -n "Continue anyway? (y/N): "
        read -r response
        [[ "$response" =~ ^[Yy]$ ]] || return 0
    fi

    mkdir -p "$work_dir"
    run_command "unzip -o '$zip_file' -d '$work_dir'" "Resolve ZIP extracted"

    local run_file
    run_file=$(ls -1 "$work_dir"/DaVinci_Resolve*_Linux.run 2>/dev/null | head -n1)
    if [ -z "$run_file" ]; then
        print_error "Could not find the .run installer after extraction"
        return 1
    fi

    chmod +x "$run_file"
    print_info "Running the official installer..."
    if ! run_command "sudo SKIP_PACKAGE_CHECK=1 '$run_file' -i -y" "DaVinci Resolve installed"; then
        print_error "Installer failed, check $LOG_FILE"
        return 1
    fi

    # Fix: bundled glib conflicts with the system one on Fedora
    if [ -d /opt/resolve/libs ]; then
        print_info "Applying glib fix..."
        sudo mkdir -p /opt/resolve/libs/disabled-libraries
        sudo sh -c 'mv /opt/resolve/libs/libglib-2.0.so* /opt/resolve/libs/libgio-2.0.so* /opt/resolve/libs/libgmodule-2.0.so* /opt/resolve/libs/disabled-libraries/ 2>/dev/null'
    fi

    echo -n "Remove the build directory ($work_dir)? (Y/n): "
    read -r response
    if [[ ! "$response" =~ ^[Nn]$ ]]; then
        rm -rf "$work_dir"
        print_info "Build directory removed"
    fi

    if [ "$edition" = "studio" ]; then
        print_info "Studio needs a license: activate with your key on first launch or plug in your dongle"
    fi
    print_warning "If Resolve does not start: check your GPU driver (nvidia-smi / OpenCL) and that only one OpenCL ICD exists in /etc/OpenCL/vendors/"
    log_action "DaVinci Resolve ($edition) installed"
    ((TOTAL_INSTALLED++))
}
