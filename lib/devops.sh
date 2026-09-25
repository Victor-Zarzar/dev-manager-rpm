#!/bin/bash

# ============================================
# DevOps Tools Installation Functions
# ============================================

install_terraform() {
    print_section "Installing Terraform"

    if command_exists terraform; then
        print_info "Terraform already installed ($(terraform version | head -n1))"
        return 0
    fi

    local repo_url
    if [ "$IS_FEDORA" = true ]; then
        repo_url="https://rpm.releases.hashicorp.com/fedora/hashicorp.repo"
    else
        repo_url="https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo"
    fi

    run_command "sudo $PKG_MGR install -y dnf-plugins-core" "dnf-plugins-core ensured"
    add_repo_from_url "$repo_url" "HashiCorp repository added"

    if run_command "sudo $PKG_MGR install -y terraform" "Terraform installed"; then
        return 0
    fi

    print_warning "HashiCorp's repo doesn't have a build for this Fedora/Nobara version yet ($OS_VERSION_ID)."
    print_info "Falling back to the official Terraform binary release..."

    local tf_version tf_url
    tf_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | grep -o '"current_version":"[^"]*"' | cut -d '"' -f 4)

    if [ -z "$tf_version" ]; then
        print_error "Could not determine the latest Terraform version"
        return 1
    fi

    tf_url="https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip"

    if ! command_exists unzip; then
        run_command "sudo $PKG_MGR install -y unzip" "unzip installed"
    fi

    if curl -sL "$tf_url" -o /tmp/terraform.zip >> "$LOG_FILE" 2>&1; then
        (cd /tmp && unzip -oq terraform.zip) >> "$LOG_FILE" 2>&1
        run_command "sudo mv /tmp/terraform /usr/local/bin/terraform" "Terraform ${tf_version} installed (official binary)"
        rm -f /tmp/terraform.zip
    else
        print_error "Failed to download Terraform ${tf_version}"
    fi
}

install_kubectl() {
    print_section "Installing kubectl (Kubernetes)"

    if command_exists kubectl; then
        print_info "kubectl already installed ($(kubectl version --client --short 2>/dev/null || kubectl version --client))"
        return 0
    fi

    local k8s_version="v1.31"

    print_info "Configuring Kubernetes repository ($k8s_version)..."
    sudo tee /etc/yum.repos.d/kubernetes.repo > /dev/null <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/${k8s_version}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/${k8s_version}/rpm/repodata/repomd.xml.key
EOF

    run_command "sudo $PKG_MGR install -y kubectl" "kubectl installed"
}

install_minikube() {
    print_section "Installing Minikube"

    if command_exists minikube; then
        print_info "Minikube already installed ($(minikube version --short 2>/dev/null))"
        return 0
    fi

    print_info "Downloading Minikube RPM package..."
    if curl -Lo /tmp/minikube-latest.rpm https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm >> "$LOG_FILE" 2>&1; then
        run_command "sudo rpm -Uvh /tmp/minikube-latest.rpm" "Minikube installed"
        rm -f /tmp/minikube-latest.rpm
    else
        print_error "Failed to download Minikube"
    fi
}

install_aws_cli() {
    print_section "Installing AWS CLI"

    if command_exists aws; then
        print_info "AWS CLI already installed ($(aws --version))"
        return 0
    fi

    if ! command_exists unzip; then
        run_command "sudo $PKG_MGR install -y unzip" "unzip installed"
    fi

    print_info "Downloading AWS CLI v2..."
    if curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip >> "$LOG_FILE" 2>&1; then
        (cd /tmp && unzip -q -o awscliv2.zip) >> "$LOG_FILE" 2>&1
        run_command "sudo /tmp/aws/install" "AWS CLI v2 installed"
        rm -rf /tmp/awscliv2.zip /tmp/aws
    else
        print_error "Failed to download AWS CLI"
    fi
}

install_eksctl() {
    print_section "Installing eksctl"

    if command_exists eksctl; then
        print_info "eksctl already installed ($(eksctl version))"
        return 0
    fi

    print_info "Fetching the latest eksctl release from GitHub..."
    local eksctl_url
    eksctl_url=$(curl -s https://api.github.com/repos/eksctl-io/eksctl/releases/latest \
        | grep "browser_download_url.*Linux_amd64.tar.gz\"" | cut -d '"' -f 4)

    if [ -n "$eksctl_url" ]; then
        if curl -sL "$eksctl_url" -o /tmp/eksctl.tar.gz >> "$LOG_FILE" 2>&1; then
            tar -xzf /tmp/eksctl.tar.gz -C /tmp >> "$LOG_FILE" 2>&1
            run_command "sudo mv /tmp/eksctl /usr/local/bin/eksctl" "eksctl installed"
            rm -f /tmp/eksctl.tar.gz
        else
            print_error "Failed to download eksctl"
        fi
    else
        print_error "Could not locate the eksctl download URL"
    fi
}

install_prometheus() {
    print_section "Installing Prometheus"

    if command_exists prometheus; then
        print_info "Prometheus already installed ($(prometheus --version 2>&1 | head -n1))"
        return 0
    fi

    print_info "Fetching the latest Prometheus release from GitHub..."
    local prom_url
    prom_url=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest \
        | grep "browser_download_url.*linux-amd64.tar.gz\"" | cut -d '"' -f 4)

    if [ -z "$prom_url" ]; then
        print_error "Could not locate the Prometheus download URL"
        return 1
    fi

    if ! curl -sL "$prom_url" -o /tmp/prometheus.tar.gz >> "$LOG_FILE" 2>&1; then
        print_error "Failed to download Prometheus"
        return 1
    fi

    tar -xzf /tmp/prometheus.tar.gz -C /tmp >> "$LOG_FILE" 2>&1
    local prom_dir
    prom_dir=$(tar -tzf /tmp/prometheus.tar.gz | head -1 | cut -f1 -d/)

    if ! id prometheus &> /dev/null; then
        run_command "sudo useradd --no-create-home --shell /sbin/nologin prometheus" "User 'prometheus' created"
    fi

    run_command "sudo mkdir -p /etc/prometheus /var/lib/prometheus" "Prometheus directories created"
    run_command "sudo cp /tmp/${prom_dir}/prometheus /tmp/${prom_dir}/promtool /usr/local/bin/" "Prometheus binaries copied"
    run_command "sudo cp -r /tmp/${prom_dir}/consoles /tmp/${prom_dir}/console_libraries /tmp/${prom_dir}/prometheus.yml /etc/prometheus/" "Configuration files copied"
    run_command "sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus /usr/local/bin/prometheus /usr/local/bin/promtool" "Permissions adjusted"

    sudo tee /etc/systemd/system/prometheus.service > /dev/null <<'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

    run_command "sudo systemctl daemon-reload" "systemd reloaded"
    run_command "sudo systemctl enable --now prometheus" "Prometheus service enabled and started (port 9090)"

    rm -rf /tmp/prometheus.tar.gz "/tmp/${prom_dir}"
}

install_azure_cli() {
    print_section "Installing Azure CLI"

    if command_exists az; then
        print_info "Azure CLI already installed ($(az version --output tsv --query '\"azure-cli\"' 2>/dev/null || az --version | head -n1))"
        return 0
    fi

    run_command "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc" "Microsoft GPG key imported"

    sudo tee /etc/yum.repos.d/azure-cli.repo > /dev/null <<'EOF'
[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

    run_command "sudo $PKG_MGR install -y azure-cli" "Azure CLI installed"
}

install_ansible() {
    print_section "Installing Ansible"

    if command_exists ansible; then
        print_info "Ansible already installed ($(ansible --version | head -n1))"
        return 0
    fi

    _ensure_epel
    run_command "sudo $PKG_MGR install -y ansible" "Ansible installed"
}

install_devops_tools() {
    print_section "Installing DevOps Tools"

    install_terraform
    install_kubectl
    install_minikube
    install_aws_cli
    install_azure_cli
    install_ansible
    install_eksctl
    install_prometheus

    log_action "DevOps tools installed (Terraform, kubectl, Minikube, AWS CLI, Azure CLI, Ansible, eksctl, Prometheus)"
}
