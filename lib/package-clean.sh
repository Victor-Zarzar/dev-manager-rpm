#!/bin/bash

# ============================================
# Package Manager Cleaning (DNF, Snap, Flatpak)
# ============================================

fix_broken_packages() {
    print_section "Checking / Fixing Package Database"

    run_command "sudo $PKG_MGR check" "Package database checked"
    run_command "sudo rpm --rebuilddb" "RPM database rebuilt"

    if command_exists dnf5; then
        run_command "sudo dnf5 repoquery --duplicates" "Duplicate packages listed (see log)"
    fi
}

remove_orphaned_packages() {
    print_section "Removing Orphaned Packages"

    run_command "sudo $PKG_MGR autoremove -y" "Orphaned packages removed"
}

clean_dnf_cache() {
    print_section "Cleaning DNF Cache"

    local cache_dir="/var/cache/dnf"
    local size_before
    size_before=$(get_folder_size "$cache_dir")

    if run_command "sudo $PKG_MGR clean all" "DNF cache cleaned"; then
        print_info "Freed approximately $(format_size "$size_before") of package cache"
    fi

    run_command "sudo $PKG_MGR makecache" "DNF metadata cache rebuilt"
}

clean_snap() {
    print_section "Cleaning Snap Packages"

    if ! command_exists snap; then
        print_info "Snap not installed, skipping"
        return 0
    fi

    print_info "Removing disabled/old snap revisions..."
    local removed=0
    while read -r snapname revision; do
        [ -z "$snapname" ] && continue
        if sudo snap remove "$snapname" --revision="$revision" >> "$LOG_FILE" 2>&1; then
            ((removed++))
        fi
    done < <(snap list --all 2>/dev/null | awk '/disabled/{print $1, $3}')

    if [ "$removed" -gt 0 ]; then
        print_success "$removed old snap revision(s) removed"
        log_action "$removed old snap revision(s) removed"
        ((TOTAL_INSTALLED++))
    else
        print_info "No disabled snap revisions to remove"
    fi
}

clean_flatpak() {
    print_section "Cleaning Flatpak"

    if ! command_exists flatpak; then
        print_info "Flatpak not installed, skipping"
        return 0
    fi

    run_command "flatpak uninstall --unused -y" "Unused Flatpak runtimes removed"
    run_command "flatpak repair" "Flatpak repositories repaired"
}
