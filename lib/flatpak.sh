#!/bin/bash

# ============================================
# Flatpak Package Installation Functions
# ============================================

install_flatpak_apps() {
    print_section "Installing Flatpak Applications"

    if ! command_exists flatpak; then
        print_info "Flatpak not found, installing..."
        run_command "sudo $PKG_MGR install -y flatpak" "Flatpak installed"
    fi

    print_info "Adding Flathub (system-wide) repository..."
    if flatpak remote-list --system | grep -q "flathub"; then
        print_info "Flathub repository already added"
    else
        sudo flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo >> "$LOG_FILE" 2>&1
        print_success "Flathub repository added"
    fi

    # Nobara/KDE spins ship a "flathub" remote in both the system and user
    # installations, so an unqualified "flatpak install flathub ..." is
    # ambiguous ("Remote 'flathub' found in multiple installations"). Always
    # target --system explicitly, matching the rest of this script (sudo-driven,
    # machine-wide installs).
    local apps=(
        "org.libreoffice.LibreOffice:LibreOffice"
        "io.github.thetumultuousunicornofdarkness.cpu-x:CPU-X"
        "com.github.jeromerobert.pdfarranger:PDF Arranger"
        "org.gnome.Boxes:Boxes"
        "org.freedownloadmanager.Manager:Free Download Manager"
        "ru.linux_gaming.PortProton: Port Proton"
        "net.davidotek.pupgui2: PUP GUI"
    )

    for app in "${apps[@]}"; do
        IFS=':' read -r pkg desc <<< "$app"

        if flatpak list --system | grep -q "$pkg"; then
            print_info "$desc already installed"
        else
            run_command "sudo flatpak install -y --system flathub $pkg" "$desc"
        fi
    done
}
