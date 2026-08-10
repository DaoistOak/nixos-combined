# Overlay configuration for different systems
{ inputs, ... }:
let
  overlays = import ./default.nix { inherit inputs; };
in
{
  # Overlays for NixOS systems
  nixos = [
    overlays.additions
    overlays.modifications
    overlays.nur
  ];
}
