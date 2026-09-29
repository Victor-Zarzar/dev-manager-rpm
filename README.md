# Fedora/RHEL Desktop Development Environment Manager

A modular, idempotent automated **setup + maintenance** toolkit for Fedora, RHEL, Rocky Linux, AlmaLinux, and CentOS desktops. It ships two independent entry points that share the same `lib/`:

- **`setup.sh`** — installs and configures a complete desktop development environment. This is the desktop counterpart of [dev-setup-rpm-server](https://github.com/Victor-Zarzar/dev-setup-rpm-server) — it keeps every server/DevOps tool from that project and adds GUI apps, Flatpak, Snap, DNF desktop packages, and NVIDIA graphics drivers, following the same module/menu pattern used in [dev-setup-debian](https://github.com/Victor-Zarzar/dev-setup-debian).
- **`maintenance.sh`** — cleans caches, prunes packages, and frees up disk space. This is the DNF/RPM counterpart of [dev-cleaner-debian](https://github.com/Victor-Zarzar/dev-cleaner-debian), adapted for `dnf`/`rpm` (package cache, orphan removal, kernel cleanup) instead of `apt`/`dpkg`.

## Features

- **Modular Architecture**: Every concern (install or clean) lives in its own library file under `lib/`, shared by both entry points
- **Idempotent Execution**: Safe to run multiple times without duplicating installations or re-cleaning what's already clean
- **Hybrid Package Strategy**: Uses DNF/YUM, Snap, Flatpak, NPM, and Pip/pipx
- **Interactive Menus**: Choose individual components or run the complete setup/maintenance routine
- **Automatic Logging**: Detailed timestamped logs for troubleshooting, with failed-command output also printed to the terminal
- **Freed-space reporting**: Cleaning operations report roughly how much disk space each step freed

## What Gets Installed

### Text Editors & IDEs

- Zed Editor (official installer)
- Sublime Text (Snap)
- Android Studio (Snap)

### Shell & Terminal

- Zsh
- Zim (Zsh configuration framework)
- Starship (cross-shell prompt)
- zoxide (smarter `cd`)
- bat (`cat` with syntax highlighting)
- eza (modern, maintained `ls` replacement)
- exa (legacy/unmaintained; kept for compatibility, eza is recommended instead)

### Development Tools

- Git, Docker, Docker Compose V2
- Node.js tools: NPM, PNPM, NVM
- Python: Pip, Pipx, Pyenv (with build dependencies), FastAPI, Uvicorn, Leme (DevOps CLI)
- Build tools: CMake, Automake, Ninja, Clang
- OpenJDK 21, Nginx, OpenSSH Server
- DevOps: Terraform, kubectl, Minikube, AWS CLI, Azure CLI, Ansible, eksctl, Prometheus
- Bun
- FVM (Flutter Version Management)

### Databases

- SQLite, MySQL, PostgreSQL, Redis

### Applications

- **Snap**: Postman, Figma, Proton VPN, Notion, Trello, WhatsApp, Slack, Telegram, Spotify, Brave, LocalSend
- **Flatpak**: LibreOffice, CPU-X, PDF Arranger, Boxes (VM manager)
- **Browsers**: Firefox (Snap, optional), Google Chrome, Brave (Snap)
- **Extras** (`lib/extras.sh`):
- **Proton Authenticator**: official `.rpm` (x86_64), latest version resolved from Proton's `version.json` with SHA512 verification
- **DaVinci Resolve (free)**: official `.run` installer, requires a manual download (see [DaVinci Resolve](#davinci-resolve))

### Graphics & Drivers

- **NVIDIA Drivers**: Automatic GPU detection and proprietary driver installation
  - Fedora: RPM Fusion (`akmod-nvidia`)
  - RHEL/Rocky/AlmaLinux: ELRepo (`kmod-nvidia`)

### Security & Utilities

- KeePassXC, LocalSend, OpenVPN
- KDE Spectacle, KDiskMark, Balena Etcher
- JetBrains Mono font, plus optional Nerd Fonts (JetBrains Mono, Fira Code, Cascadia Code, Hack)

## Requirements

- Fedora, RHEL, Rocky Linux, AlmaLinux, or CentOS
- Sudo privileges
- Internet connection

## Installation

```bash
git clone https://github.com/Victor-Zarzar/dev-manager-rpm-desktop
cd dev-manager-rpm-desktop
chmod +x setup.sh maintenance.sh

./setup.sh        # install the dev environment
./maintenance.sh  # clean caches and free up space (run any time after)
```

Both scripts are independent — run either one on its own, whenever you need it.

## Directory Structure

```
dev-manager-rpm-desktop/
├── setup.sh              # Setup entry point
├── maintenance.sh        # Maintenance/cleaner entry point
├── lib/
│   ├── colors.sh          # Color functions (shared)
│   ├── helpers.sh         # Print/log helpers, header banner, run_command wrapper,
│   │                      # clean_dir_contents/clean_path/format_size (shared)
│   ├── system.sh          # OS/package-manager detection, update, snapd, directories, zsh (shared)
│   │
│   │   # --- setup.sh modules ---
│   ├── dnf.sh             # DNF desktop package installations
│   ├── snap.sh            # Snap package installations
│   ├── flatpak.sh         # Flatpak package installations
│   ├── fonts.sh           # Font installations
│   ├── manual.sh          # Manual installations (Zed, Bun, editors)
│   ├── docker.sh          # Docker and Compose v2 setup
│   ├── devops.sh          # Terraform, kubectl, Minikube, AWS CLI, Azure CLI, Ansible, eksctl, Prometheus
│   ├── databases.sh       # SQLite, MySQL, PostgreSQL, Redis
│   ├── nginx.sh           # Nginx setup
│   ├── dev.sh             # NVM, Pyenv, pipx, Leme
│   ├── git.sh             # Git configuration
│   ├── nvidia.sh          # NVIDIA driver installation (RPM Fusion / ELRepo)
│   ├── shell_tools.sh     # bat, eza, exa, zoxide, Starship, Zim, FVM
│   ├── extras.sh          # Proton Authenticator (.rpm), DaVinci Resolve (free, .run)
│   │
│   │   # --- maintenance.sh modules ---
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

## Menu Options

```
1)  Run complete setup
2)  Update system
3)  Setup Snapd
4)  Setup directories
5)  Install Git
6)  Install text editors (Zed, Sublime)
7)  Install security tools
8)  Install Python environment
9)  Install Snap applications
10) Install Node.js tools
11) Install Docker
12) Install DevOps tools (Terraform, kubectl, Minikube, AWS CLI, Azure CLI, Ansible, eksctl, Prometheus)
13) Install browsers
14) Install fonts (JetBrains Mono, Nerd, Fira, Cascadia, Hack)
15) Install system tools
16) Install utility tools
17) Install Flatpak applications
18) Install databases
19) Install Nginx
20) Install NVM
21) Install Pyenv
22) Install Zsh
23) Configure Git
24) Install Bun
25) Install Nvidia drivers
26) Install CLI enhancements (bat, eza, exa, zoxide, Starship)
27) Install Zim (Zsh framework)
28) Install FVM (Flutter Version Management)
29) Install Proton Authenticator
30) Install DaVinci Resolve (free)
31) View installation log
 0) Exit
```

> **Note:** option `1` (complete setup) includes Proton Authenticator but **not** DaVinci Resolve, since Resolve requires a manual download and an interactive installer. Run option `30` separately.

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

## What Gets Cleaned

### Package Management

- **DNF cache**: downloaded package archives and metadata (`dnf clean all`)
- **RPM database**: consistency check and rebuild (`rpm --rebuilddb`)
- **Orphaned packages**: no-longer-needed dependencies (`dnf autoremove`)
- **Old kernels**: keeps the current + 1 previous kernel, removes the rest
- **Snap**: disabled/old revisions
- **Flatpak**: unused runtimes and dependencies

### Development Tools

- **NPM/NVM**: package manager cache
- **Bun**: install cache, global cache, logs older than 7 days
- **PNPM**: store pruning
- **PIP**: package cache
- **Flutter/Dart/FVM**: Dart pub cache; reports FVM's cached SDK versions size (removed manually with `fvm remove <version>` since a project may still need it); runs `flutter clean` when inside a Flutter project
- **Android Studio & Emulator**: AVD caches, build cache, IDE caches and logs
- **Gradle**: size reported only, not removed automatically (same reasoning as Flutter/Android: deleting it forces a slow rebuild)
- **Docker**: unused containers, images, volumes, networks, and build cache

### System Maintenance

- **System logs**: journal vacuum (7 days / 200 MB cap), rotated log archives
- **User caches**: browser caches, thumbnails, trash
- **Temporary files**: `/tmp` (2+ days) and `/var/tmp` (7+ days)
- **Databases**: MySQL/MariaDB table optimization, PostgreSQL `VACUUM ANALYZE`, Redis AOF rewrite (only for running services)
- **System health check**: disk/memory usage, `dnf check`, failed systemd units

## Post-Installation

1. **Log out and log back in** for Docker group changes
2. **Restart terminal** for shell configurations (NVM, Pyenv, Bun, pipx)
3. **Reboot system** if NVIDIA drivers were installed
4. **Set Zsh as default**: `chsh -s $(which zsh)`
5. **Install Python**: `pyenv install 3.11.0 && pyenv global 3.11.0`
6. **Install Node.js**: `nvm install --lts && nvm use --lts`
7. **Secure MySQL**: `sudo mysql_secure_installation`
8. **Access PostgreSQL**: `sudo -iu postgres psql`

## NVIDIA Drivers

The script automatically detects NVIDIA GPUs and installs the appropriate proprietary drivers:

- **Fedora**: enables RPM Fusion (free + nonfree) and installs `akmod-nvidia` + `xorg-x11-drv-nvidia-cuda`, then waits for the kernel module (`akmod`) to build.
- **RHEL/Rocky/AlmaLinux**: enables EPEL + ELRepo and installs `kmod-nvidia`.

After installation:

```bash
# Verify installation
nvidia-smi

# Check the built kernel module version (Fedora)
modinfo -F version nvidia
```

**Important**: A system reboot is required after NVIDIA driver installation for changes to take effect. If Secure Boot is enabled, you may need to enroll the akmod signing key (MOK) on first boot.

## Docker Usage

Docker Compose V2 is installed as a plugin:

```bash
docker compose up
docker compose down
docker compose version
```

## Shell Enhancements (bat, eza, exa, zoxide, Starship, Zim)

- **bat**: drop-in `cat` replacement with syntax highlighting and Git integration. Use `bat <file>`.
- **eza**: actively maintained `ls` replacement (icons, Git status, tree view). `exa` is also offered for compatibility, but it's unmaintained upstream and often missing from current repos — prefer `eza`.
- **zoxide**: learns your most-visited directories; after installation, `eval "$(zoxide init bash|zsh)"` is added to your shell rc automatically, and you can jump around with `z <partial-name>`.
- **Starship**: fast, customizable prompt for any shell. The installer adds the `starship init` line to `~/.bashrc`/`~/.zshrc`; customize it at `~/.config/starship.toml`.
- **Zim**: Zsh configuration framework (plugin manager + themes). Installed to `~/.zim`; edit `~/.zimrc` to add modules, then run `zimfw install`. Requires Zsh (installed automatically if missing).

Restart your terminal (or `source ~/.bashrc` / `source ~/.zshrc`) after installing any of these for the changes to take effect.

## Flutter Version Management (FVM)

FVM lets you pin a Flutter SDK version per project instead of relying on one global install. It's installed via the official script to your user's home directory. After installation, open a new shell and use:

```bash
fvm install stable
fvm use stable
```

## Proton Authenticator

Installed from Proton's official `.rpm` (x86_64 only). The script:

1. Fetches `https://proton.me/download/authenticator/linux/version.json`
2. Picks the latest `.x86_64.rpm` entry
3. Downloads it and verifies the **SHA512** checksum (aborts on mismatch)
4. Installs it with `dnf install`

It is skipped if `proton-authenticator` is already installed. Unlike the `.deb`, the `.rpm` may not configure an update repository, so to update just run option `29` again after removing the old version, or check with `dnf repolist` whether Proton added a repo.

## DaVinci Resolve

The **free** edition is installed using Blackmagic's official `.run` installer. Blackmagic requires a registration form, so the ZIP has to be downloaded manually:

1. Download `DaVinci_Resolve_<version>_Linux.zip` from https://www.blackmagicdesign.com/event/davinciresolvedownload
2. Leave it in `~/Downloads` (or point elsewhere with `RESOLVE_SRC_DIR`)
3. Run option `30`

What the script does:

- Installs dependencies via DNF (`unzip`, `xcb-util-cursor`, `apr`, `apr-util`, `mesa-libGLU`, `libxcrypt-compat`, `fuse-libs`, `alsa-lib`)
- Extracts the ZIP into `~/resolve_build` (needs roughly 15 GB free; warns if less)
- Runs the installer with `SKIP_PACKAGE_CHECK=1 ... -i -y` (required on non-supported distros such as Fedora)
- Moves Resolve's bundled `libglib`, `libgio` and `libgmodule` to `/opt/resolve/libs/disabled-libraries`, which avoids conflicts with the system glib
- Optionally removes the build directory

Environment variables:

| Variable          | Default       | Description                                                                                                                      |
| ----------------- | ------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `RESOLVE_SRC_DIR` | `~/Downloads` | Folder where the Resolve ZIP is located                                                                                          |
| `RESOLVE_EDITION` | `free`        | `free` or `studio`. Studio expects `DaVinci_Resolve_Studio_*_Linux.zip` and requires your own license (activation key or dongle) |

```bash
# Default (free), ZIP in ~/Downloads
./setup.sh

# ZIP in a custom folder
RESOLVE_SRC_DIR=/path/to/folder ./setup.sh

# Studio edition
RESOLVE_EDITION=studio ./setup.sh
```

Resolve needs a working GPU driver. On NVIDIA systems, install the drivers first (option `25`) and confirm `nvidia-smi` works.

## Log Files

Each entry point keeps its own timestamped log:

- `setup.sh` → `~/rpm_desktop_setup_YYYYMMDD_HHMMSS.log`
- `maintenance.sh` → `~/rpm_desktop_maintenance_YYYYMMDD_HHMMSS.log`

If a step fails, the script also prints the last lines of the actual error directly in the terminal (in addition to the log file), so you don't need to open the log to see what went wrong.

## Troubleshooting

**Snap apps not appearing:**

```bash
sudo systemctl restart snapd
```

**Classic-confinement Snap apps fail to launch (SELinux):**

See: https://snapcraft.io/docs/installing-snap-on-fedora

**Docker permission denied:**

```bash
# Log out and log back in, then:
docker run hello-world
```

**Flatpak issues:**

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

**NVIDIA driver issues:**

```bash
# Check if an NVIDIA GPU is detected
lspci | grep -i nvidia

# Fedora: check akmod build status
modinfo -F version nvidia
sudo akmods --force
sudo dracut --force

# Reinstall using the script
./setup.sh  # Select option 25
```

**DaVinci Resolve: "ZIP not found":**

```bash
# The script looks for the free edition by default
ls ~/Downloads/DaVinci_Resolve_*_Linux.zip

# Studio ZIP (has "Studio" in the name) needs:
RESOLVE_EDITION=studio ./setup.sh
```

**DaVinci Resolve does not start:**

```bash
# Confirm the GPU driver works
nvidia-smi

# Only one OpenCL ICD should exist
ls /etc/OpenCL/vendors/

# Run from the terminal to see the error
/opt/resolve/bin/resolve
```

If the error mentions `libglib`/`libgio`, make sure the bundled copies are in `/opt/resolve/libs/disabled-libraries`.

**Package install fails (e.g. MySQL, Redis, kdiskmark):**

```bash
# Check the last lines printed in the terminal, or the full log:
cat ~/rpm_desktop_setup_*.log        # setup.sh issues
cat ~/rpm_desktop_maintenance_*.log  # maintenance.sh issues

# Common causes:
# - Repository metadata out of date: sudo dnf clean all && sudo dnf makecache
# - Package renamed/unavailable on your distro version (RHEL/Rocky may
#   require EPEL/RPM Fusion enabled for some packages)
# - No internet access
```

**Old kernel removal did nothing / kept more than 2:**

```bash
# List installed kernels
rpm -q kernel

# The running kernel is never removed - reboot into the newest one first if needed
uname -r
```

## License

MIT License

## Author

Victor Zarzar
