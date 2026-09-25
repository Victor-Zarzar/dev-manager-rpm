#!/bin/bash

# ============================================
# Helper Functions (Maintenance)
# ============================================

print_header() {
    local free_space
    free_space=$(get_disk_usage)
    local current_date
    current_date=$(date '+%Y-%m-%d %H:%M:%S')
    local username
    username=$(whoami)
    local os_version
    os_version=$(get_os_version)

    echo -e "${GREEN}"
    echo '  ██████╗ ██████╗ ███╗   ███╗'
    echo '  ██╔══██╗██╔══██╗████╗ ████║'
    echo '  ██████╔╝██████╔╝██╔████╔██║'
    echo '  ██╔══██╗██╔═══╝ ██║╚██╔╝██║'
    echo '  ██║  ██║██║     ██║ ╚═╝ ██║'
    echo '  ╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝'
    echo ''
    echo '██████╗ ███████╗███████╗██╗  ██╗████████╗ ██████╗ ██████╗ '
    echo '██╔══██╗██╔════╝██╔════╝██║ ██╔╝╚══██╔══╝██╔═══██╗██╔══██╗'
    echo '██║  ██║█████╗  ███████╗█████╔╝    ██║   ██║   ██║██████╔╝'
    echo '██║  ██║██╔══╝  ╚════██║██╔═██╗    ██║   ██║   ██║██╔═══╝ '
    echo '██████╔╝███████╗███████║██║  ██╗   ██║   ╚██████╔╝██║     '
    echo '╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝     '
    echo -e "${NC}"
    echo -e "  ${GREEN}──────────────────────────────────────────────────────────${NC}"
    echo -e "  ${GREEN}✦ User:${NC}        $username"
    echo -e "  ${GREEN}✦ System:${NC}      $os_version"
    echo -e "  ${GREEN}✦ Package Mgr:${NC} $PKG_MGR"
    echo -e "  ${GREEN}✦ Free Space:${NC}  $free_space"
    echo -e "  ${GREEN}✦ Date:${NC}        $current_date"
    echo -e "  ${GREEN}──────────────────────────────────────────────────────────${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${PURPLE}$1${NC}"
    echo "────────────────────────────────────────"
}

print_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

print_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

get_folder_size() {
    local path="$1"
    if [ -e "$path" ]; then
        du -sk "$path" 2>/dev/null | awk '{print $1}'
    else
        echo "0"
    fi
}

show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))

    printf "\r${CYAN}["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' ' '
    printf "] %d%%${NC}" $percentage
}

get_disk_usage() {
    df -h / | tail -1 | awk '{print $4}'
}

# ============================================
# Cleaning Helpers (used by maintenance.sh modules)
# ============================================

# Converts a size in KB (as returned by get_folder_size) into a human string
format_size() {
    local kb="${1:-0}"
    if [ "$kb" -ge 1048576 ] 2>/dev/null; then
        awk "BEGIN { printf \"%.2f GB\", $kb/1048576 }"
    elif [ "$kb" -ge 1024 ] 2>/dev/null; then
        awk "BEGIN { printf \"%.2f MB\", $kb/1024 }"
    else
        echo "${kb} KB"
    fi
}

# Removes the CONTENTS of a directory (keeps the directory itself), reporting freed space.
# Skips silently (with an info line) if the path doesn't exist.
clean_dir_contents() {
    local path="$1"
    local label="$2"

    if [ ! -d "$path" ]; then
        print_info "$label: not found, skipping"
        return 0
    fi

    local size_before freed
    size_before=$(get_folder_size "$path")

    find "$path" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>>"$LOG_FILE"

    freed=$(format_size "$size_before")
    print_success "$label cleaned (freed ~$freed)"
    log_action "$label cleaned (~$freed freed)"
    ((TOTAL_INSTALLED++))
}

# Removes a directory or file entirely, reporting freed space.
# Skips silently (with an info line) if the path doesn't exist.
clean_path() {
    local path="$1"
    local label="$2"

    if [ ! -e "$path" ]; then
        print_info "$label: not found, skipping"
        return 0
    fi

    local size_before freed
    size_before=$(get_folder_size "$path")

    rm -rf "$path" 2>>"$LOG_FILE"

    freed=$(format_size "$size_before")
    print_success "$label cleaned (freed ~$freed)"
    log_action "$label cleaned (~$freed freed)"
    ((TOTAL_INSTALLED++))
}

# ============================================
# Fedora/RHEL OS version detection
# ============================================
get_os_version() {
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        echo "${PRETTY_NAME:-$NAME $VERSION}"
    else
        echo "Unknown Fedora/RHEL system"
    fi
}

# Returns 0 if the command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Real user, even when the script runs with sudo
real_user() {
    if [ -n "$SUDO_USER" ]; then
        echo "$SUDO_USER"
    else
        echo "$USER"
    fi
}

# ============================================
# Repo Helper (dnf5 / dnf4 compatible)
# ============================================

# Adds a .repo file from a URL. dnf5 (Fedora 41+, used on this system) renamed
# the config-manager plugin syntax from "config-manager --add-repo URL" to
# "config-manager addrepo --from-repofile=URL". This tries the new syntax
# first and falls back to the old one for dnf4/yum systems.
add_repo_from_url() {
    local repo_url="$1"
    local success_msg="$2"
    local output

    echo -e "${YELLOW}→${NC} Adding repo: $repo_url"

    if output=$(sudo dnf config-manager addrepo --from-repofile="$repo_url" 2>&1); then
        echo "$output" >> "$LOG_FILE"
        print_success "$success_msg"
        log_action "$success_msg"
        ((TOTAL_INSTALLED++))
        return 0
    fi

    if output=$(sudo "$PKG_MGR" config-manager --add-repo "$repo_url" 2>&1); then
        echo "$output" >> "$LOG_FILE"
        print_success "$success_msg"
        log_action "$success_msg"
        ((TOTAL_INSTALLED++))
        return 0
    fi

    echo "$output" >> "$LOG_FILE"
    print_error "Failed: $success_msg (see $LOG_FILE)"
    log_action "FAILED: $success_msg"
    return 1
}

# ============================================
# Command Execution Helper
# ============================================

run_command() {
    local cmd="$1"
    local msg="$2"
    local output

    echo -e "${YELLOW}→${NC} Executing: $cmd"
    if output=$(eval "$cmd" 2>&1); then
        echo "$output" >> "$LOG_FILE"
        print_success "$msg"
        log_action "$msg"
        ((TOTAL_INSTALLED++))
        return 0
    else
        echo "$output" >> "$LOG_FILE"
        print_error "Failed: $msg (see $LOG_FILE)"
        log_action "FAILED: $msg"
        echo -e "${RED}--- Last lines of output ---${NC}"
        echo "$output" | tail -n 10
        echo -e "${RED}-----------------------------${NC}"
        return 1
    fi
}
