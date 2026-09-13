# 🐧 NixOS Config (Lingnao)

Dendritic flake-based NixOS (`host = Lingnao`, `user = zeph`) + home-manager, x86_64-linux only.
Built on the dendritic pattern: `flake-parts` + `import-tree` for auto-discovery.

## ✨ Features

- **Flake-Powered**: Declarative NixOS and home-manager configs in one flake
- **Dendritic Layout**: `flake-parts` + `import-tree` auto-discovery of modules
- **Hyprland Ecosystem**: Modern Wayland WM with plugins (`hypr-dynamic-cursors`, `hyprland-scroll-overview`), noctalia shell, hyprpanel, and KDE/Plasma coexistence
- **Theming**: Stylix + Catppuccin with a custom themer (QML script) and tmux/kitty/zsh integration
- **Gaming & Development**: Steam, Lutris, Neovim, VSCode, and full dev toolchain
- **Modular & Secure**: Organized modules; no secrets are stored in the repo

## 🚀 Quick Start

### Prerequisites
- NixOS installed
- Flakes enabled
- `nh` (Nix helper) for quick rebuilds

### Installation
1. Clone this repo:
   ```bash
   git clone git@github.com:DaoistOak/nixos-combined.git ~/.config/nixos
   cd ~/.config/nixos
   ```

2. Build and switch:
   ```bash
   # Full system rebuild
   nh os switch .#nixosConfigurations.Lingnao

   # Home-manager only
   home-manager switch --flake .#zeph
   ```

## 🛠️ Commands

- **Update & rebuild all** (interactive): `./scripts/updt`
  - Options: `1` all, `2` flake update, `3` system, `4` home, `5` flatpak, `6` push, `7` exit (comma lists and ranges supported)
- **Build without switching**:
  - System: `nh os build .#nixosConfigurations.Lingnao`
  - Home: `home-manager build --flake .#zeph`
- **Rebuild system**: `nh os switch .#nixosConfigurations.Lingnao`
- **Rebuild home**: `home-manager switch --flake .#zeph`
- **Format code**: `nixfmt .`
- **Validate**: `nix flake check`

## ⌨️ Essential Keybinds

`SUPER` = Windows/Super key.

| Keybind | Action |
| --- | --- |
| `SUPER` (tap) | Run launcher |
| `SUPER` + `K` | List keybinds (cheatsheet) |
| `SUPER` + `RETURN` | Terminal (wezterm + tmux) |
| `SUPER` + `SPACE` ×3 / `SUPER` + `SHIFT` + `SPACE` | Window switcher |
| `SUPER` + `Q` | Toggle workspace overview |
| `SUPER` + `D` | Control center |
| `SUPER` + `V` | Clipboard menu |
| `SUPER` + `C` | Close window |
| `SUPER` + `X` | Session menu |
| `SUPER` + `1`–`0` | Switch workspace |
| `SUPER` + `SHIFT` + `1`–`0` | Move window to workspace |
| `SUPER` + `T` | Terminal apps menu |
| `SUPER` + `S` | Shell menu |
| `SUPER` + `E` | Apps menu |
| `SUPER` + `M` | Messaging menu |
| `SUPER` + `W` | Windows menu |
| `XF86AudioRaiseVolume` / `LowerVolume` / `Mute` | Volume up / down / mute |
| `XF86AudioMicMute` | Mic mute |
| `XF86MonBrightnessUp` / `Down` | Screen brightness up / down |

## 🗂️ Layout

- `flake.nix` — entry point; `import-tree ./flake-parts` + host composition
- `modules/system/hosts/Lingnao.nix` — thin host composition (NixOS + home-manager)
- `modules/system/` — NixOS modules (boot, network, desktop, themes, pkgs, users, services, misc)
- `modules/home/` — home-manager modules (`base/` entry point, `config/modules/`, `config/themes/`)
- `flake-parts/` — auto-discovered flake-parts modules
- `overlays/` — package overlays (additions, modifications, NUR)
- `pkgs/` — package definitions (reachable only through `overlays/`)
- `scripts/` — `updt` update helper

## 🤝 Contributing

Feel free to fork, modify, and submit PRs.