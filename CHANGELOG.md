# Changelog

## Unreleased (server branch)

### Changed

- `setup.sh` re-scoped to match [dev-setup-rpm-server](https://github.com/Victor-Zarzar/dev-setup-rpm-server): now only installs Git, Docker, Terraform, kubectl, Minikube, AWS CLI, Azure CLI, Ansible, eksctl, Prometheus, SQLite/MySQL/PostgreSQL/Redis, Nginx, NVM, and Pyenv. No desktop/GUI packages, Snap, Flatpak, fonts, manual editor installs, NVIDIA drivers, or shell enhancements (bat/eza/zoxide/Starship/Zim/FVM).
- Moved `install_git` from `lib/dnf.sh` into `lib/git.sh` (which already had `configure_git`), since `lib/dnf.sh` (desktop-only) was removed on this branch.
- Removed desktop-only libraries not used by this branch's `setup.sh` or by `maintenance.sh`: `lib/dnf.sh`, `lib/snap.sh`, `lib/flatpak.sh`, `lib/fonts.sh`, `lib/manual.sh`, `lib/nvidia.sh`, `lib/shell_tools.sh`.
- Updated the banner in `lib/helpers.sh` from "RPM DESKTOP" to "RPM SERVER" (same `ansi_shadow` font/layout, shared cosmetically with `maintenance.sh`).

### Unchanged

- `maintenance.sh` and every `lib/*-clean.sh` / `lib/storage-optimize.sh` / `lib/restart-system.sh` module are byte-for-byte identical to the `main` branch.

## Unreleased (main branch)

### Features

- Renamed project to `dev-manager-rpm-desktop`, unifying setup and maintenance into a single repo with two independent entry points (`setup.sh`, `maintenance.sh`) sharing `lib/colors.sh`, `lib/helpers.sh`, and `lib/system.sh`.
- Added `maintenance.sh`, a DNF/RPM-native counterpart to `dev-cleaner-debian`: `lib/package-clean.sh` (DNF cache/orphans, RPM db, Snap, Flatpak), `lib/node-clean.sh` (NPM/NVM, Bun, PNPM, PIP), `lib/flutter-clean.sh` (Dart pub cache, FVM SDK cache reporting), `lib/android-clean.sh` (Android Studio & Emulator), `lib/docker-clean.sh` (system prune), `lib/system-clean.sh` (journal logs, user caches, temp files, health check), `lib/storage-optimize.sh` (old kernel removal, DB optimization), `lib/restart-system.sh`.
- Added shared cleaning helpers to `lib/helpers.sh`: `format_size`, `clean_dir_contents`, `clean_path`.
- Added `lib/shell_tools.sh` to `setup.sh`: bat, eza, exa (legacy), zoxide, Starship, Zim, and FVM (Flutter Version Management).

## 1.0.0 (2026-09-16)

### Features

- Initial release, branched from `dev-setup-rpm-server`, restructured to follow the `dev-setup-debian` module/menu pattern.
- Added Flatpak application support (LibreOffice, CPU-X, PDF Arranger, Boxes).
- Added Snap application support (Postman, Notion, Trello, WhatsApp, Android Studio, Brave, Spotify, Slack, Telegram, Figma, Proton VPN, Sublime Text, LocalSend, Firefox).
- Added DNF desktop application support (KeePassXC, OpenVPN, Google Chrome, KDE Spectacle, KDiskMark, Balena Etcher, build tools, OpenJDK 21).
- Added NVIDIA proprietary driver installation (RPM Fusion/akmod-nvidia on Fedora, ELRepo/kmod-nvidia on RHEL/Rocky/AlmaLinux).
- Added Nerd Fonts installer (JetBrains Mono, Fira Code, Cascadia Code, Hack).
- Added Zed Editor and Bun manual installers.
- Kept all existing server-oriented tooling from `dev-setup-rpm-server` (Docker, DevOps tooling, databases, Nginx, NVM, Pyenv, pipx, Leme).
