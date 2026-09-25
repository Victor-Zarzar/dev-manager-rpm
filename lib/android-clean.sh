#!/bin/bash

# ============================================
# Android Studio & Emulator Cache Cleaning
# ============================================

clean_android_studio() {
    print_section "Cleaning Android Studio & Emulator"

    local user home_dir
    user="$(real_user)"
    home_dir=$(eval echo "~$user")

    # AVD per-emulator caches
    if [ -d "$home_dir/.android/avd" ]; then
        for avd_cache in "$home_dir"/.android/avd/*/cache; do
            [ -d "$avd_cache" ] || continue
            clean_dir_contents "$avd_cache" "AVD cache ($(basename "$(dirname "$avd_cache")"))"
        done
    else
        print_info "No AVDs found, skipping emulator caches"
    fi

    clean_dir_contents "$home_dir/.android/cache" "Android general cache"
    clean_dir_contents "$home_dir/.android/build-cache" "Android build cache"

    # Android Studio itself (JetBrains toolbox naming: AndroidStudioYYYY.N)
    for cache_dir in "$home_dir"/.cache/Google/AndroidStudio*; do
        [ -d "$cache_dir" ] || continue
        clean_dir_contents "$cache_dir" "Android Studio cache ($(basename "$cache_dir"))"
    done

    for ide_dir in "$home_dir"/.local/share/Google/AndroidStudio*; do
        [ -d "$ide_dir" ] || continue
        clean_dir_contents "$ide_dir/caches" "Android Studio IDE cache ($(basename "$ide_dir"))"
        clean_path "$ide_dir/log" "Android Studio logs ($(basename "$ide_dir"))"
    done

    # Gradle: info only, same reasoning as the Debian/macOS versions of this tool -
    # deleting it automatically would force a slow re-download on next build.
    if [ -d "$home_dir/.gradle/caches" ]; then
        local gradle_size
        gradle_size=$(get_folder_size "$home_dir/.gradle/caches")
        print_info "Gradle cache: $(format_size "$gradle_size") (not removed automatically)"
        print_info "Clean it with './gradlew cleanBuildCache' in a project, or 'rm -rf ~/.gradle/caches/*'"
    fi
}
