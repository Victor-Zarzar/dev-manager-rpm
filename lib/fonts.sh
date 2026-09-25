#!/bin/bash

# ============================================
# Font Installation Functions
# ============================================

# Nerd Fonts release version (ryanoasis/nerd-fonts)
NERD_FONTS_VERSION="v3.2.1"
NERD_FONTS_BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}"

_install_dnf_jetbrains_mono() {
    if rpm -q jetbrains-mono-fonts &> /dev/null; then
        print_info "JetBrains Mono (default) already installed"
    else
        run_command "sudo $PKG_MGR install -y jetbrains-mono-fonts" "JetBrains Mono (default) installed"
    fi
}

# $1 = zip file name in the Nerd Fonts release (e.g. JetBrainsMono, FiraCode, Hack, CascadiaCode)
# $2 = friendly display name
_install_nerd_font() {
    local zip_name="$1"
    local friendly_name="$2"
    local dest_dir="$HOME/.local/share/fonts/${zip_name}NerdFont"

    if [ -d "$dest_dir" ] && [ "$(ls -A "$dest_dir" 2>/dev/null)" ]; then
        print_info "${friendly_name} Nerd Font already installed"
        return 0
    fi

    print_info "Downloading ${friendly_name} Nerd Font..."
    mkdir -p "$dest_dir"
    local tmp_zip="/tmp/${zip_name}NerdFont.zip"

    if wget -q "${NERD_FONTS_BASE_URL}/${zip_name}.zip" -O "$tmp_zip" >> "$LOG_FILE" 2>&1; then
        unzip -oq "$tmp_zip" -d "$dest_dir" >> "$LOG_FILE" 2>&1
        rm -f "$tmp_zip"
        fc-cache -f "$dest_dir" >> "$LOG_FILE" 2>&1
        print_success "${friendly_name} Nerd Font installed"
        log_action "${friendly_name} Nerd Font installed"
        ((TOTAL_INSTALLED++))
    else
        print_error "Failed to download ${friendly_name} Nerd Font"
        rm -rf "$dest_dir"
    fi
}

install_fonts() {
    print_section "Installing Fonts"

    local options=(
        "JetBrains Mono (default, via dnf)"
        "JetBrains Mono Nerd Font"
        "Fira Code Nerd Font"
        "Cascadia Code Nerd Font"
        "Hack Nerd Font"
    )

    echo "Select the fonts you want to install (separate numbers with spaces, e.g.: 1 2 3):"
    echo ""
    local i=1
    for opt in "${options[@]}"; do
        echo "  $i) $opt"
        ((i++))
    done
    echo "  0) Cancel"
    echo ""
    echo -n "Options: "
    read -r -a choices

    if [ "${#choices[@]}" -eq 0 ]; then
        print_info "No option selected"
        return 0
    fi

    for choice in "${choices[@]}"; do
        case "$choice" in
            1) _install_dnf_jetbrains_mono ;;
            2) _install_nerd_font "JetBrainsMono" "JetBrains Mono" ;;
            3) _install_nerd_font "FiraCode" "Fira Code" ;;
            4) _install_nerd_font "CascadiaCode" "Cascadia Code" ;;
            5) _install_nerd_font "Hack" "Hack" ;;
            0)
                print_info "Font installation cancelled"
                return 0
                ;;
            *)
                print_error "Invalid option: $choice"
                ;;
        esac
    done
}
