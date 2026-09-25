# Fedora/RHEL Server Development Environment Manager

**`server` branch** — the headless-server counterpart of the `main` branch. Same toolkit, same modular pattern, same `maintenance.sh`, but `setup.sh` is trimmed down to what a Fedora/RHEL/Rocky/AlmaLinux/CentOS **server or VM (no GUI)** actually needs, matching the scope of [dev-setup-rpm-server](https://github.com/Victor-Zarzar/dev-setup-rpm-server).

- **`setup.sh`** — installs a DevOps-oriented server environment: Git, Docker, Terraform, kubectl, Minikube, AWS/Azure CLI, Ansible, eksctl, Prometheus, SQLite/MySQL/PostgreSQL/Redis, Nginx, NVM, Pyenv. No desktop packages, no Snap/Flatpak, no GUI apps, no NVIDIA drivers.
- **`maintenance.sh`** — identical to the `main` branch, unchanged. It still knows how to clean Flutter/Android/Docker/etc. caches if any of those happen to be present, but nothing here installs them.

## Features

- **Modular Architecture**: Every concern (install or clean) lives in its own library file under `lib/`, shared by both entry points
- **Idempotent Execution**: Safe to run multiple times without duplicating installations or re-cleaning what's already clean
- **DNF/YUM Package Strategy**: Automatically detects and uses the available package manager
- **Interactive Menus**: Choose individual components or run the complete setup/maintenance routine
- **Automatic Logging**: Detailed timestamped logs for troubleshooting, with failed-command output also printed to the terminal
- **Freed-space reporting**: Cleaning operations report roughly how much disk space each step freed

## What Gets Installed

### Development Tools
- Git, Docker, Docker Compose V2

### DevOps
- Terraform (HashiCorp official repo)
- kubectl (Kubernetes)
- Minikube
- AWS CLI v2
- Azure CLI
- Ansible
- eksctl
- Prometheus (systemd service on port 9090)

### Databases
- SQLite, MySQL, PostgreSQL (with automatic `initdb`), Redis (systemd service on port 6379)

### Web Server
- Nginx (with automatic firewalld rules for HTTP/HTTPS, when firewalld is active)

### Language Version Managers
- NVM (Node.js)
- Pyenv (Python, with build dependencies)

## Requirements

- Fedora, RHEL, Rocky Linux, AlmaLinux, or CentOS
- Sudo privileges
- Internet connection

## Installation

```bash
git clone -b server https://github.com/Victor-Zarzar/dev-manager-rpm-desktop
cd dev-manager-rpm-desktop
chmod +x setup.sh maintenance.sh

./setup.sh        # install the server environment
./maintenance.sh  # clean caches and free up space (run any time after)
```

Both scripts are independent — run either one on its own, whenever you need it.

## Directory Structure

```
dev-manager-rpm-desktop/  (server branch)
├── setup.sh              # Setup entry point (server-scoped)
├── maintenance.sh        # Maintenance/cleaner entry point (unchanged from main)
├── lib/
│   ├── colors.sh          # Color functions (shared)
│   ├── helpers.sh         # Print/log helpers, header banner, run_command wrapper,
│   │                      # clean_dir_contents/clean_path/format_size (shared)
│   ├── system.sh          # OS/package-manager detection, update, snapd, directories, zsh (shared)
│   │
│   │   # --- setup.sh modules ---
│   ├── git.sh             # Git installation + configuration
│   ├── docker.sh          # Docker and Compose v2 setup
│   ├── devops.sh          # Terraform, kubectl, Minikube, AWS CLI, Azure CLI, Ansible, eksctl, Prometheus
│   ├── databases.sh       # SQLite, MySQL, PostgreSQL, Redis
│   ├── nginx.sh           # Nginx setup
│   ├── dev.sh             # NVM, Pyenv, pipx, Leme
│   │
│   │   # --- maintenance.sh modules (untouched) ---
│   ├── package-clean.sh   # DNF cache/orphans, RPM db, Snap, Flatpak cleaning
│   ├── node-clean.sh      # NPM/NVM, Bun, PNPM, PIP cache cleaning
│   ├── flutter-clean.sh   # Flutter/Dart/FVM cache cleaning
│   ├── android-clean.sh   # Android Studio & Emulator cache cleaning
│   ├── docker-clean.sh    # Docker system prune
│   ├── system-clean.sh    # Journal logs, user caches, temp files, health check
│   ├── storage-optimize.sh # Old kernel removal (DNF/RPM), DB optimization
│   └── restart-system.sh  # Safe restart prompt
└── README.md
```

## Setup Menu Options

```
1)  Run complete setup
2)  Update system
3)  Install Git
4)  Install Docker + Docker Compose v2
5)  Install Terraform
6)  Install Kubernetes (kubectl)
7)  Install Minikube
8)  Install AWS CLI
9)  Install Azure CLI
10) Install Ansible
11) Install eksctl
12) Install Prometheus
13) Install SQLite
14) Install MySQL
15) Install PostgreSQL
16) Install Redis
17) Install Nginx
18) Install NVM
19) Install Pyenv
20) Configure Git
21) View installation log
 0) Exit
```

## Maintenance Menu Options

```
1)  Run complete maintenance
2)  Update system packages
3)  Fix broken packages
4)  Remove orphaned packages
5)  Clean DNF cache
6)  Clean Snap packages
7)  Clean Flatpak
8)  Clean NPM/NVM
9)  Clean Bun
10) Clean PNPM
11) Clean Flutter/Dart/FVM
12) Clean Android Studio
13) Clean Docker
14) Remove old kernels
15) Clean logs
16) Clean user caches
17) Clean temporary files
18) Clean PIP cache
19) Optimize databases
20) Verify system health
21) View action log
22) Restart system
 0) Exit
```

Snap/Flatpak/Android Studio cleaning options are harmless no-ops here (they check `command_exists`/directory presence first) — they're kept because `maintenance.sh` is shared as-is with the `main` (desktop) branch.

## What Gets Cleaned

### Package Management
- **DNF cache**: downloaded package archives and metadata (`dnf clean all`)
- **RPM database**: consistency check and rebuild (`rpm --rebuilddb`)
- **Orphaned packages**: no-longer-needed dependencies (`dnf autoremove`)
- **Old kernels**: keeps the current + 1 previous kernel, removes the rest
- **Snap / Flatpak**: skipped automatically if not installed

### Development Tools
- **NPM/NVM**: package manager cache
- **PIP**: package cache
- **Docker**: unused containers, images, volumes, networks, and build cache
- **Bun / PNPM / Flutter / Dart / FVM / Android Studio**: cleaned if present, skipped otherwise (unlikely on a server, but harmless to keep)

### System Maintenance
- **System logs**: journal vacuum (7 days / 200 MB cap), rotated log archives
- **User caches**: browser caches, thumbnails, trash
- **Temporary files**: `/tmp` (2+ days) and `/var/tmp` (7+ days)
- **Databases**: MySQL/MariaDB table optimization, PostgreSQL `VACUUM ANALYZE`, Redis AOF rewrite (only for running services)
- **System health check**: disk/memory usage, `dnf check`, failed systemd units

## Post-Installation

1. **Log out and log back in** for Docker group changes to take effect
2. **Open a new shell** (or `source ~/.bashrc`) to load NVM and Pyenv
3. **Secure MySQL**: `sudo mysql_secure_installation`
4. **Access PostgreSQL**: `sudo -iu postgres psql`
5. **Install Node.js**: `nvm install --lts && nvm use --lts`
6. **Install Python**: `pyenv install 3.11.0 && pyenv global 3.11.0`
7. **Add Pyenv to your shell profile** (`~/.bashrc` or `~/.zshrc`):

```bash
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

## Docker Usage

Docker Compose V2 is installed as a plugin:

```bash
docker compose up
docker compose down
docker compose version
```

## Log Files

Each entry point keeps its own timestamped log:

- `setup.sh` → `~/rpm_server_setup_YYYYMMDD_HHMMSS.log`
- `maintenance.sh` → `~/rpm_desktop_maintenance_YYYYMMDD_HHMMSS.log` (log file name unchanged - `maintenance.sh` is shared verbatim with `main`)

If a step fails, the script also prints the last lines of the actual error directly in the terminal (in addition to the log file), so you don't need to open the log to see what went wrong.

## Troubleshooting

**Docker permission denied:**

```bash
# Log out and log back in, then:
docker run hello-world
```

**Package install fails (e.g. MySQL, Redis):**

```bash
# Check the last lines printed in the terminal, or the full log:
cat ~/rpm_server_setup_*.log

# Common causes:
# - Repository metadata out of date: sudo dnf clean all && sudo dnf makecache
# - Package renamed/unavailable on your distro version (RHEL/Rocky may
#   require EPEL enabled for some packages): sudo dnf install epel-release
# - No internet access from the VM
```

**Nginx firewall issues:**

```bash
sudo firewall-cmd --list-services
sudo firewall-cmd --reload
```

**Old kernel removal did nothing / kept more than 2:**

```bash
# List installed kernels
rpm -q kernel

# The running kernel is never removed - reboot into the newest one first if needed
uname -r
```

**Re-running a specific step:**

```bash
./setup.sh   # choose the corresponding menu option
```

## License

MIT License

## Author

Victor Zarzar
