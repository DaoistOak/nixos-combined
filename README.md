# 🐧 NixOS Combined Configuration

A comprehensive, declarative NixOS and home-manager setup for seamless system and user environment management.

## ✨ Features

- **Flake-Powered**: Declarative NixOS and home-manager configs in one flake
- **Hyprland Ecosystem**: Modern Wayland WM with custom plugins, themes, and KDE integration
- **Gaming & Development**: Steam, Lutris, Neovim, VSCode, and full dev toolchain
- **Modular & Secure**: Organized modules with age-encrypted secrets and best practices

## 🚀 Quick Start

### Prerequisites
- NixOS installed
- Flakes enabled
- `nh` (Nix helper) for quick rebuilds

### Installation
1. Clone this repo:
   ```bash
   git clone https://github.com/DaoistOak/nixos-combined.git ~/.config/nixos
   cd ~/.config/nixos
   ```

2. Build and switch:
   ```bash
   # Full system rebuild
   nh os switch .#Overlord

   # Home-manager only
   nh home switch .#zeph
   ```

## 🛠️ Commands

- ***Update & rebuild all***: `./scripts/updt`
- **Rebuild system**: `nh os switch .#Overlord`
- **Rebuild home**: `nh home switch .#zeph`
- **Format code**: `nixfmt .`
- **Validate**: `nix flake check`

## 🤝 Contributing

Feel free to fork, modify, and submit PRs. Follow the guidelines in `AGENTS.md` for consistency.
