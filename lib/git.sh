#!/bin/bash

# ============================================
# Git Configuration Functions
# ============================================

configure_git() {
    print_section "Configuring Git"

    print_info "Enter your Git username:"
    read -r GIT_USERNAME

    print_info "Enter your Git email:"
    read -r GIT_EMAIL

    run_command "git config --global user.name '$GIT_USERNAME'" "Git username configured"
    run_command "git config --global user.email '$GIT_EMAIL'" "Git email configured"
}
