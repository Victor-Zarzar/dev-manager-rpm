#!/bin/bash

# ============================================
# Database Installation Functions
# ============================================

install_sqlite() {
    print_section "Installing SQLite"

    if command_exists sqlite3; then
        print_info "SQLite already installed ($(sqlite3 --version))"
        return 0
    fi

    run_command "sudo $PKG_MGR install -y sqlite" "SQLite installed"
}

install_mysql() {
    print_section "Installing MySQL"

    if command_exists mysql; then
        print_info "MySQL already installed ($(mysql --version))"
        return 0
    fi

    local pkg
    if [ "$IS_FEDORA" = true ]; then
        pkg="community-mysql-server"
    else
        pkg="mysql-server"
    fi

    run_command "sudo $PKG_MGR install -y $pkg" "MySQL Server installed"
    run_command "sudo systemctl enable --now mysqld" "MySQL service enabled and started"
    print_warning "Run 'sudo mysql_secure_installation' to secure the installation"
}

install_postgresql() {
    print_section "Installing PostgreSQL"

    if command_exists psql; then
        print_info "PostgreSQL already installed ($(psql --version))"
        return 0
    fi

    run_command "sudo $PKG_MGR install -y postgresql-server postgresql-contrib" "PostgreSQL installed"

    if [ ! -d /var/lib/pgsql/data ] || [ -z "$(ls -A /var/lib/pgsql/data 2>/dev/null)" ]; then
        run_command "sudo postgresql-setup --initdb" "PostgreSQL database initialized"
    else
        print_info "PostgreSQL data directory already initialized"
    fi

    run_command "sudo systemctl enable --now postgresql" "PostgreSQL service enabled and started"
    print_warning "Default user 'postgres': use 'sudo -iu postgres psql' to access"
}

install_redis() {
    print_section "Installing Redis"

    if command_exists redis-cli; then
        print_info "Redis already installed ($(redis-cli --version))"
        return 0
    fi

    run_command "sudo $PKG_MGR install -y redis" "Redis installed"
    run_command "sudo systemctl enable --now redis" "Redis service enabled and started (port 6379)"
}

install_databases() {
    print_section "Installing Databases"

    install_sqlite
    install_mysql
    install_postgresql
    install_redis

    log_action "Databases installed (SQLite, MySQL, PostgreSQL, Redis)"
}
