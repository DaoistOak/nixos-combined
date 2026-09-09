{
  description = "Dendritic NixOS configuration for zeph on Lingnao";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:denful/import-tree";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    nur.url = "github:nix-community/NUR";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    catppuccin.url = "github:catppuccin/nix";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland/5c9377c15f85c50648f35ca5a213754f95b93ca0"; # v0.56.1 (has input.keyboard.key event AND activeWorkspace.id for noctalia)
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
    };
    preload-ng.url = "github:miguel-b-p/preload-ng";
  };

  outputs =
    inputs@{ flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        (import-tree ./flake-parts)
      ]
      ++ [
        ./modules/hosts/Lingnao.nix
      ];
    };
}
