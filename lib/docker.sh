#!/bin/bash

# ============================================
# Docker Installation Functions
# ============================================

install_docker() {
    print_section "Installing Docker"

    if command_exists docker; then
        print_info "Docker already installed ($(docker --version))"
    else
        local repo_url
        if [ "$IS_FEDORA" = true ]; then
            repo_url="https://download.docker.com/linux/fedora/docker-ce.repo"
        else
            repo_url="https://download.docker.com/linux/rhel/docker-ce.repo"
        fi

        run_command "sudo $PKG_MGR remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman-docker" "Old Docker packages removed (if present)" || true
        run_command "sudo $PKG_MGR install -y dnf-plugins-core" "dnf-plugins-core ensured"
        add_repo_from_url "$repo_url" "Docker CE repository added"

        if ! run_command "sudo $PKG_MGR install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin" "Docker Engine and Compose v2 installed"; then
            print_warning "Docker CE has no build yet for this Fedora/Nobara version ($OS_VERSION_ID)."
            print_info "You can try again later, or temporarily use \$releasever override, e.g.:"
            print_info "  sudo dnf install -y --releasever=41 docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
        fi
    fi

    run_command "sudo systemctl enable --now docker" "Docker service enabled and started"

    print_info "Configuring Docker group..."
    local user
    user="$(real_user)"

    if [ "$user" != "root" ] && ! groups "$user" | grep -q docker; then
        run_command "sudo usermod -aG docker $user" "User '$user' added to the docker group"
        print_warning "Log out/log in (or run 'newgrp docker') to use Docker without sudo"
    else
        print_info "User already in docker group"
    fi

    if command_exists docker; then
        print_info "Docker Compose version: $(docker compose version 2>/dev/null || echo 'not detected')"
    fi

    log_action "Docker configured with Compose V2 plugin"
}
