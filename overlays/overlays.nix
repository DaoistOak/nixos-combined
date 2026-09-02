# Overlay configuration for different systems
{ inputs, ... }:
let
  overlays = import ./default.nix { inherit inputs; };
in
{
  # Overlays for NixOS systems
  nixos = [
    inputs.nix-cachyos-kernel.overlays.pinned
    overlays.additions
    overlays.modifications
    overlays.nur
  ];
}
