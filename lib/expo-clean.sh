#!/bin/bash

# ============================================
# Expo & React Native Cache Cleaning
# ============================================

clean_expo_react_native() {
    print_section "Cleaning Expo & React Native"

    # Only the cache is removed: ~/.expo/state.json (your Expo login) is kept
    clean_dir_contents "$HOME/.expo/cache" "Expo CLI cache"
    clean_dir_contents "$HOME/.eas" "EAS CLI cache"

    if command_exists watchman; then
        run_command "watchman watch-del-all" "Watchman watches cleared"
    else
        print_info "Watchman not installed, skipping"
    fi

    # Metro bundler caches (Linux uses the system temp dir)
    local tmp_base="${TMPDIR:-/tmp}"
    tmp_base="${tmp_base%/}"
    local d
    for d in "$tmp_base"/metro-* "$tmp_base"/haste-map-* "$tmp_base"/react-native-packager-cache-*; do
        [ -e "$d" ] || continue
        clean_path "$d" "Metro cache ($d)"
    done

    # React Native Android build artifacts inside your projects
    local projects_dir="${EXPO_PROJECTS_DIR:-$HOME/Projects}"
    if [ -d "$projects_dir" ]; then
        local build_dirs
        build_dirs=$(find "$projects_dir" -maxdepth 5 -type d -path "*/android/app/build" -not -path "*/node_modules/*" 2>/dev/null)
        if [ -n "$build_dirs" ]; then
            print_warning "React Native Android build artifacts found:"
            echo "$build_dirs"
            echo -n "Remove all of these android/app/build directories? (y/N): "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                local dir
                while IFS= read -r dir; do
                    clean_path "$dir" "Android build artifacts ($dir)"
                done <<< "$build_dirs"
            else
                print_info "Skipped: React Native Android build artifacts"
            fi
        fi
    else
        print_info "Projects directory not found ($projects_dir), skipping Android build scan"
    fi
}
