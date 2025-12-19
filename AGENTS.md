# AGENTS.md - Coding Guidelines for NixOS Configuration

## Build/Test Commands
- **Full system build**: `sudo nixos-rebuild switch --flake .#Overlord`
- **Home-manager build**: `home-manager switch --flake .#zeph`
- **Quick rebuild (nh)**: `nh os switch .#Overlord` / `nh home switch .#zeph`
- **Flake validation**: `nix flake check`
- **Update dependencies**: `nix flake update`
- **Test builds (no switch)**: `nh os build .#Overlord` / `nh home build .#zeph`
- **Format code**: `nixfmt .`
- **Syntax check**: `nix-instantiate --eval flake.nix`

## Code Style Guidelines
- **Language**: Nix (functional, declarative, dynamically typed)
- **File naming**: kebab-case (e.g., `configuration.nix`)
- **Attribute naming**: camelCase (e.g., `homeDirectory`, `stateVersion`)
- **Structure**: Attribute sets `{ key = value; }` with 2-space indentation
- **Imports**: Arrays `[ ./file.nix ./other.nix ]`
- **Local variables**: `let ... in` blocks for complex expressions
- **Modularity**: Separate concerns into logical modules/files
- **Comments**: Minimal, only for complex configurations
- **Error handling**: Use assertions; leverage Nix evaluation errors
- **Formatting**: Follow nixpkgs style with `nixfmt`
- **Security**: Never expose secrets; use `config.age.secrets`</content>
<parameter name="filePath">/home/zeph/.config/nixos/AGENTS.md