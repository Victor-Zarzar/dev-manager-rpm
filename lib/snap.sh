#!/bin/bash

# ============================================
# Snap Package Installation Functions
# ============================================

install_snap_apps() {
    print_section "Installing Snap Applications"

    local apps=(
        "postman:Postman"
        "notion-snap-reborn:Notion"
        "trello-desktop:Trello"
        "whatsapp-linux-desktop:WhatsApp"
        "android-studio --classic:Android Studio"
        "brave:Brave"
        "spotify:Spotify"
        "slack --classic:Slack"
        "telegram-desktop:Telegram"
        "figma-linux:Figma"
        "proton-vpn:Proton VPN"
    )

    for app in "${apps[@]}"; do
        IFS=':' read -r cmd desc <<< "$app"
        local pkg_name=$(echo "$cmd" | awk '{print $1}')

        if snap list 2>/dev/null | grep -q "^$pkg_name "; then
            print_info "$desc already installed"
        else
            run_command "sudo snap install $cmd" "$desc"
        fi
    done

    print_info "Sublime Text and Zed Editor are available via option 6 (Install text editors)"
}

install_firefox() {
    print_section "Installing Firefox (Optional)"

    if command_exists firefox; then
        print_warning "Firefox is already installed on your system"
        echo -n "Do you want to install Firefox from Snap anyway? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_info "Skipping Firefox installation"
            return 0
        fi
    fi

    if snap list 2>/dev/null | grep -q "^firefox "; then
        print_info "Firefox (Snap) already installed"
        return 0
    fi

    run_command "sudo snap install firefox" "Firefox"
}
