# Aggregated package definitions.
# system-pkgs → environment.systemPackages (NixOS)
# home-pkgs → home.packages (home-manager)
# Define new packages in the relevant list in default.nix.
{ pkgs, inputs, ... }:

let
  pkgs' = import ./default.nix { inherit pkgs inputs; };
in
{
  system-pkgs = pkgs'.system-packages;
  home-pkgs = pkgs'.user-packages;
}
