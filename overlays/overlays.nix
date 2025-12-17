# Overlay configuration for different systems
{inputs, ...}:
let
  overlays = import ./default.nix { inherit inputs; };
in {
  # Default overlays to apply to all systems
  default = [
    overlays.nur
  ];

  # Overlays for NixOS systems
  nixos = [
    overlays.additions
    overlays.nur
  ];

  # Overlays for home-manager configurations
  home-manager = [
    overlays.additions
    overlays.nur
  ];
}