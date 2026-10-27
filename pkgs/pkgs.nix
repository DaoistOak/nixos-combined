# Aggregated package definitions.
# Single source of truth: `pkgs/default.nix` (edit `system-packages` / `user-packages` there).
# system-pkgs → environment.systemPackages (NixOS)
# home-pkgs   → home.packages (home-manager)
{ pkgs, inputs, ... }:

let
  manifest = import ./default.nix { inherit pkgs inputs; };
in
{
  system-pkgs = manifest.system-packages;
  home-pkgs = manifest.user-packages;
}
