{
  description = "A comprehensive NixOS and home-manager configuration for zeph on Overlord";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
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
    nur = {
      url = "github:nix-community/NUR";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      # NOTE: keep the "github:" fetcher (no submodules) — it matches the builds
      # uploaded to hyprland.cachix.org by Hyprland's CI. "git+...?submodules=1"
      # produces different store hashes and forces compilation every time.
      url = "github:hyprwm/Hyprland";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
    };
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        ./nixos
      ];
      flake.homeConfigurations."zeph" = inputs.home-manager.lib.homeManagerConfiguration {
        # home-manager's pkgs is a plain nixpkgs import (no NUR overlay), so
        # expose NUR explicitly for flake-sourced packages like the Charm
        # `crush` package (nur.repos.charmbracelet.crush), and allow its
        # FSL-1.1-MIT (unfree) license.
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [ inputs.nur.overlays.default ];
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./home-manager/home.nix
          inputs.catppuccin.homeModules.catppuccin
          inputs.stylix.homeModules.stylix
        ];
      };
    };
}
