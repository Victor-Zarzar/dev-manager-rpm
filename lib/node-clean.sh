#!/bin/bash

# ============================================
# Node.js / Package Manager Cache Cleaning
# NPM, NVM, Bun, PNPM, PIP
# ============================================

clean_npm_nvm() {
    print_section "Cleaning NPM/NVM"

    local user home_dir
    user="$(real_user)"
    home_dir=$(eval echo "~$user")

    if command_exists npm; then
        run_command "npm cache clean --force" "NPM cache cleaned"
    else
        print_info "NPM not found, skipping npm cache"
    fi

    # NVM caches per-Node-version download tarballs under ~/.nvm/.cache
    clean_dir_contents "$home_dir/.nvm/.cache" "NVM download cache"
}

clean_bun() {
    print_section "Cleaning Bun"

    local user home_dir
    user="$(real_user)"
    home_dir=$(eval echo "~$user")

    if [ ! -d "$home_dir/.bun" ]; then
        print_info "Bun not installed, skipping"
        return 0
    fi

    clean_dir_contents "$home_dir/.bun/install/cache" "Bun install cache"
    clean_dir_contents "$home_dir/.bun/install/global/cache" "Bun global package cache"

    if [ -d "$home_dir/.bun/logs" ]; then
        find "$home_dir/.bun/logs" -type f -mtime +7 -delete 2>>"$LOG_FILE"
        print_success "Bun logs older than 7 days removed"
        log_action "Bun old logs removed"
        ((TOTAL_INSTALLED++))
    fi
}

clean_pnpm() {
    print_section "Cleaning PNPM"

    if command_exists pnpm; then
        run_command "pnpm store prune" "PNPM store pruned"
    else
        print_info "PNPM not found, skipping"
    fi
}

clean_pip() {
    print_section "Cleaning PIP Cache"

    local user home_dir
    user="$(real_user)"
    home_dir=$(eval echo "~$user")

    if command_exists pip3; then
        run_command "pip3 cache purge" "PIP cache purged"
    elif [ -d "$home_dir/.cache/pip" ]; then
        clean_dir_contents "$home_dir/.cache/pip" "PIP cache directory"
    else
        print_info "PIP cache not found, skipping"
    fi
}
