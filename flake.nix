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
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
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
      url = "github:hyprwm/Hyprland/f88deb928a0f7dc02f427473f8c29e8f2bed14a3";
      # Pin to a specific commit to reduce rebuilds - update weekly
      # Last updated: 2025-12-18
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    Hyprspace = {
      url = "github:KZDKM/Hyprspace";
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

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        ./nixos
        ./home
      ];
    };
}