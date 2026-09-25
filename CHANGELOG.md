# Changelog

## Unreleased

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
