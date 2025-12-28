# 🐧 NixOS Combined Configuration

A comprehensive, declarative NixOS and home-manager setup for seamless system and user environment management.

## ✨ Features

- **Unified Configuration**: Single flake managing both system (NixOS) and user (home-manager) configurations
- **Modular Design**: Organized into logical modules for easy maintenance
- **Hyprland WM**: Cutting-edge Wayland compositor with custom plugins and themes
- **KDE Plasma Integration**: Optional desktop environment with Hyprland portal support
- **Gaming Ready**: Includes Lutris, Steam, and GPU optimizations
- **Development Tools**: Neovim, VSCode, and essential dev packages
- **Security Focused**: Age-encrypted secrets and secure defaults

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

## 📁 Structure

```
.
├── flake.nix          # Main flake definition
├── nixos/             # System configuration modules
├── home-manager/      # User environment modules
├── pkgs/              # Custom packages and overrides
├── scripts/           # Utility scripts
└── AGENTS.md          # Coding guidelines for AI agents
```

## 🛠️ Commands

- **Rebuild system**: `nh os switch .#Overlord`
- **Rebuild home**: `nh home switch .#zeph`
- **Update flake**: `nix flake update`
- **Format code**: `nixfmt .`
- **Validate**: `nix flake check`

## 🤝 Contributing

Feel free to fork, modify, and submit PRs. Follow the guidelines in `AGENTS.md` for consistency.

## 📄 License

MIT License - see LICENSE file for details.
