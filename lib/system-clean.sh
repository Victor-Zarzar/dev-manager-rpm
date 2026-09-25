#!/bin/bash

# ============================================
# System Logs, Caches & Temporary Files
# ============================================

clean_logs() {
    print_section "Cleaning System Logs"

    if command_exists journalctl; then
        run_command "sudo journalctl --vacuum-time=7d" "Journal logs older than 7 days removed"
        run_command "sudo journalctl --vacuum-size=200M" "Journal size capped at 200M"
    fi

    local removed_any=false
    for f in /var/log/*.gz /var/log/*.[0-9]; do
        [ -e "$f" ] || continue
        sudo rm -f "$f" 2>>"$LOG_FILE"
        removed_any=true
    done

    if [ "$removed_any" = true ]; then
        print_success "Rotated/old log files removed from /var/log"
        log_action "Rotated log files removed"
        ((TOTAL_INSTALLED++))
    else
        print_info "No rotated log archives found in /var/log"
    fi
}

clean_user_caches() {
    print_section "Cleaning User Caches"

    local user home_dir
    user="$(real_user)"
    home_dir=$(eval echo "~$user")

    clean_dir_contents "$home_dir/.cache/mozilla" "Firefox cache"
    clean_dir_contents "$home_dir/.cache/google-chrome" "Chrome cache"
    clean_dir_contents "$home_dir/.cache/BraveSoftware" "Brave cache"
    clean_dir_contents "$home_dir/.cache/thumbnails" "Thumbnail cache"

    if command_exists gio; then
        sudo -u "$user" bash -c "gio trash --empty" >> "$LOG_FILE" 2>&1
        print_success "Trash emptied"
        log_action "Trash emptied"
        ((TOTAL_INSTALLED++))
    else
        clean_dir_contents "$home_dir/.local/share/Trash/files" "Trash (files)"
        clean_dir_contents "$home_dir/.local/share/Trash/info" "Trash (metadata)"
    fi
}

clean_temp_files() {
    print_section "Cleaning Temporary Files"

    run_command "sudo find /tmp -mindepth 1 -mtime +2 -delete" "/tmp entries older than 2 days removed"
    run_command "sudo find /var/tmp -mindepth 1 -mtime +7 -delete" "/var/tmp entries older than 7 days removed"
}

verify_system_health() {
    print_section "System Health Check"

    echo -e "${CYAN}Disk usage:${NC}"
    df -h / | tee -a "$LOG_FILE"
    echo ""

    echo -e "${CYAN}Memory usage:${NC}"
    free -h | tee -a "$LOG_FILE"
    echo ""

    if command_exists dnf; then
        echo -e "${CYAN}DNF package check:${NC}"
        sudo dnf check 2>&1 | tee -a "$LOG_FILE" | head -n 20
        echo ""
    fi

    if systemctl --failed --quiet 2>/dev/null; then
        echo -e "${CYAN}Failed systemd units:${NC}"
        systemctl --failed --no-legend | tee -a "$LOG_FILE"
    fi

    log_action "System health check completed"
}
