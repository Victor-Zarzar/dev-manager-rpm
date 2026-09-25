# Contributing to Dev Setup RPM Desktop

Thanks for your interest in contributing to Dev Setup RPM Desktop.

Dev Setup RPM Desktop helps developers set up a complete desktop development environment on Fedora/RHEL-based systems.

## Ways to contribute

- Report bugs
- Propose new packages or applications
- Improve scripts and distro compatibility (Fedora vs RHEL/Rocky/AlmaLinux)
- Improve documentation (README / examples / translations)

## Before you start

- Check existing issues and pull requests first.
- Keep changes focused and small.
- For install behavior changes, include clear reproduction and verification steps.
- Prioritize idempotency (safe to re-run) over aggressive/destructive defaults.

## Development setup

1. Fork and clone the repository.
2. Create a branch:

   - `feat/<short-name>` for new features
   - `fix/<short-name>` for bug fixes
   - `docs/<short-name>` for documentation

3. Make your changes.
4. Test affected scripts on a Fedora and/or RHEL-based system whenever possible.

## Pull request checklist

- [ ] Scope is focused and related to one topic.
- [ ] Scripts run without syntax errors (`bash -n <script>.sh`).
- [ ] Documentation is updated if behavior or commands changed.
- [ ] Install commands were tested safely and are idempotent.
- [ ] No unrelated refactors or formatting-only changes.
- [ ] PR description includes what changed, why, and how it was tested.

## Commit message examples

- `feat: add flatpak app X`
- `feat: add nvidia driver support for Rocky Linux`
- `fix: prevent errors when snapd is not installed`
- `fix: handle missing dnf-plugins-core gracefully`
- `docs: update installation instructions`

## Coding guidelines

- Prefer simple and readable shell scripts.
- Keep install operations idempotent (check before installing).
- Always verify that a command/package exists before assuming it does.
- Gracefully handle missing packages or commands.
- Follow the existing style used throughout the repository (see `lib/helpers.sh`).

## Reporting bugs (suggested template)

Please include:

- Distribution and version (Fedora/RHEL/Rocky/AlmaLinux/CentOS)
- Desktop environment (GNOME/KDE/etc.)
- Shell (`bash`/`zsh`) and version
- Exact command run (menu option number)
- Expected vs actual behavior
- Relevant terminal output / log file excerpt

## Need help?

Open an issue and provide as much context as possible. We appreciate all contributions.
