{
  description = "A comprehensive NixOS and home-manager configuration for zeph on Overlord";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
    };
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    };

    nur = {
      url = "github:nix-community/NUR";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland/";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, chaotic, nur, ... }@inputs:
    let
      overlays = import ./overlays/overlays.nix { inherit inputs; };
    in {
    nixosConfigurations."Overlord" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
      };
      modules = [
        {
          nixpkgs.overlays = overlays.nixos;
        }
        ./nixos/configuration.nix
        home-manager.nixosModules.default
        chaotic.nixosModules.default
      ];
    };

    homeConfigurations."zeph" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = overlays.home-manager;
      };
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./home-manager/home.nix
        inputs.catppuccin.homeModules.catppuccin
        inputs.caelestia-shell.homeManagerModules.default
        {
          wayland.windowManager.hyprland = {
            enable = true;
            package = inputs.hyprland.packages."x86_64-linux".hyprland;
            portalPackage = inputs.hyprland.packages."x86_64-linux".xdg-desktop-portal-hyprland;
          };
        }
      ];
    };
  };
}