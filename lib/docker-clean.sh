#!/bin/bash

# ============================================
# Docker Cleanup
# ============================================

clean_docker() {
    print_section "Cleaning Docker"

    if ! command_exists docker; then
        print_info "Docker not installed, skipping"
        return 0
    fi

    if ! sudo docker info &>/dev/null; then
        print_warning "Docker daemon isn't running or isn't accessible - skipping"
        return 0
    fi

    run_command "sudo docker container prune -f" "Stopped containers removed"
    run_command "sudo docker image prune -af" "Unused images removed"
    run_command "sudo docker volume prune -f" "Unused volumes removed"
    run_command "sudo docker network prune -f" "Unused networks removed"
    run_command "sudo docker builder prune -af" "Build cache pruned"

    print_info "Full report: run 'docker system df' to see current disk usage by Docker"
}
