#!/bin/bash

# ============================================
# Storage Optimization
# Old kernel removal (DNF/RPM-specific) & DB optimization
# ============================================

remove_old_kernels() {
    print_section "Removing Old Kernels"

    if ! command_exists rpm; then
        print_error "rpm not found - cannot manage kernels on this system"
        return 1
    fi

    local current_kernel installed_count
    current_kernel="$(uname -r)"
    installed_count=$(rpm -q kernel 2>/dev/null | wc -l)

    print_info "Current kernel: $current_kernel"
    print_info "Installed kernels: $installed_count"

    if [ "$installed_count" -le 2 ]; then
        print_info "2 or fewer kernels installed - nothing to remove"
        return 0
    fi

    # dnf's own installonly logic keeps the N most recent kernels and removes the rest,
    # always preserving the currently running one.
    if command_exists dnf5; then
        run_command "sudo dnf5 remove --oldinstallonly --setopt installonly_limit=2 -y" "Old kernels removed (kept latest 2)"
    else
        local old_kernels
        old_kernels=$(sudo "$PKG_MGR" repoquery --installonly --latest-limit=-2 -q 2>/dev/null)

        if [ -z "$old_kernels" ]; then
            print_info "No old kernels found to remove"
            return 0
        fi

        echo "$old_kernels" >> "$LOG_FILE"
        run_command "sudo $PKG_MGR remove -y $old_kernels" "Old kernels removed (kept latest 2)"
    fi

    print_warning "Reboot into the current kernel before removing old ones if you're currently running an older kernel"
}

optimize_databases() {
    print_section "Optimizing Local Databases"

    if command_exists mysql && systemctl is-active --quiet mysqld 2>/dev/null; then
        print_info "Optimizing MySQL/MariaDB tables (this may take a while on large databases)..."
        if sudo mysqlcheck --optimize --all-databases >> "$LOG_FILE" 2>&1; then
            print_success "MySQL/MariaDB tables optimized"
            log_action "MySQL/MariaDB tables optimized"
            ((TOTAL_INSTALLED++))
        else
            print_warning "Could not optimize MySQL/MariaDB automatically (check credentials/permissions)"
        fi
    else
        print_info "MySQL/MariaDB not running, skipping"
    fi

    if command_exists psql && systemctl is-active --quiet postgresql 2>/dev/null; then
        print_info "Running VACUUM on PostgreSQL..."
        if sudo -u postgres vacuumdb --all --analyze >> "$LOG_FILE" 2>&1; then
            print_success "PostgreSQL vacuumed and analyzed"
            log_action "PostgreSQL vacuumed"
            ((TOTAL_INSTALLED++))
        else
            print_warning "Could not vacuum PostgreSQL automatically (check permissions)"
        fi
    else
        print_info "PostgreSQL not running, skipping"
    fi

    if command_exists redis-cli && systemctl is-active --quiet redis 2>/dev/null; then
        run_command "redis-cli BGREWRITEAOF" "Redis AOF file rewritten/compacted"
    fi
}
