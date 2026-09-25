#!/bin/bash

# ============================================
# Flutter / Dart / FVM Cache Cleaning
# ============================================

clean_flutter_dart_fvm() {
    print_section "Cleaning Flutter/Dart/FVM"

    local user home_dir
    user="$(real_user)"
    home_dir=$(eval echo "~$user")

    # Dart's global pub cache (shared across Flutter/Dart SDK versions)
    clean_dir_contents "$home_dir/.pub-cache/hosted" "Dart pub cache (hosted packages)"

    # FVM: cached Flutter SDK versions - the biggest FVM consumer by far.
    # Not removed automatically (a project may still need a given version);
    # just report the size and let the user opt in.
    local fvm_versions_dir="$home_dir/fvm/versions"
    [ -d "$fvm_versions_dir" ] || fvm_versions_dir="$home_dir/.fvm/versions"

    if [ -d "$fvm_versions_dir" ]; then
        local size
        size=$(get_folder_size "$fvm_versions_dir")
        print_info "FVM has $(format_size "$size") of cached Flutter SDK versions in $fvm_versions_dir"
        print_info "List them with 'fvm list' and remove one with 'fvm remove <version>'"
    else
        print_info "No FVM SDK cache found, skipping"
    fi

    # Flutter's own per-project build artifacts aren't safe to touch system-wide;
    # only clean the global Flutter SDK cache if a global Flutter install exists.
    if command_exists flutter && [ -f "./pubspec.yaml" ]; then
        run_command "flutter clean" "Flutter build artifacts cleaned (current directory)"
    elif command_exists flutter; then
        print_info "Not inside a Flutter project (no pubspec.yaml here) - run 'flutter clean' manually inside each project"
    fi

    if command_exists fvm; then
        print_info "Run 'fvm flutter clean' inside FVM-managed projects to clean their build artifacts"
    fi

    # Gradle cache (Android builds triggered from Flutter) - info only, same as Android Studio module
    if [ -d "$home_dir/.gradle/caches" ]; then
        local gradle_size
        gradle_size=$(get_folder_size "$home_dir/.gradle/caches")
        print_info "Gradle cache: $(format_size "$gradle_size") - clean manually with './gradlew cleanBuildCache' or 'rm -rf ~/.gradle/caches/*'"
    fi
}
