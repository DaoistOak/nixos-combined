{ config, lib, pkgs, inputs, ... }:

{
  flake.homeConfigurations."zeph" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      overlays = (import ../overlays/overlays.nix { inherit inputs; }).home-manager;
    };
    extraSpecialArgs = { inherit inputs; };
    modules = [
      ./home.nix
      inputs.catppuccin.homeModules.catppuccin
      inputs.caelestia-shell.homeManagerModules.default
      inputs.stylix.homeManagerModules.stylix
      {
        wayland.windowManager.hyprland = {
          enable = true;
          package = inputs.hyprland.packages."x86_64-linux".hyprland;
          portalPackage = inputs.hyprland.packages."x86_64-linux".xdg-desktop-portal-hyprland;
        };
      }
    ];
  };
}