# AGENTS.md - Coding Guidelines for NixOS Configuration

## Build/Test Commands
- **Full system build**: `sudo nixos-rebuild switch --flake .#Overlord`
- **Home-manager build**: `home-manager switch --flake .#zeph`
- **Flake validation**: `nix flake check`
- **Update dependencies**: `nix flake update`
- **Test system build (no switch)**: `sudo nixos-rebuild build --flake .#Overlord`
- **Test home-manager build (no switch)**: `home-manager build --flake .#zeph`
- **Syntax check**: `nix-instantiate --eval flake.nix` (basic syntax validation)

## Code Style Guidelines
- **Language**: Nix (functional, declarative, dynamically typed)
- **File naming**: kebab-case (e.g., `configuration.nix`, `home-manager/`)
- **Attribute naming**: camelCase (e.g., `homeDirectory`, `stateVersion`)
- **Structure**: Use attribute sets `{ key = value; }` with 2-space indentation
- **Imports**: List in arrays `[ ./file.nix ./other.nix ]`
- **Local variables**: Use `let ... in` blocks for complex expressions
- **Modularity**: Separate concerns into logical modules/files
- **Comments**: Minimal, only for complex configurations
- **Error handling**: Leverage Nix's evaluation errors; use assertions for validation
- **Formatting**: Follow nixpkgs style, use `nixfmt` for consistency</content>
<parameter name="filePath">/home/zeph/.config/nixos/AGENTS.md