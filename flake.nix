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
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    catppuccin.url = "github:catppuccin/nix";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland/5c9377c15f85c50648f35ca5a213754f95b93ca0"; # v0.56.1 (has input.keyboard.key event AND activeWorkspace.id for noctalia)
    pixie-sddm.url = "github:xCaptaiN09/pixie-sddm";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    hypr-dynamic-cursors = {
      # f5ba36c is the rev the plugin pins for v0.56.1 (5c9377c...) per its
      # hyprpm.toml commit_pins; newer main targets v0.56.2+ and won't build.
      url = "github:VirtCode/hypr-dynamic-cursors/f5ba36c7622098b53bf62ddb8ddf03b914abbdf8";
      inputs.hyprland.follows = "hyprland";
    };
    hyprland-scroll-overview = {
      url = "github:yayuuu/hyprland-scroll-overview";
      inputs.hyprland.follows = "hyprland";
    };
    # No flake upstream; plain source, packaged manually in pkgs/hyprwinwrap.nix
    hyprwinwrap = {
      # a72d3ee is the rev pinned for v0.56.0 in hyprwinwrap's hyprpm.toml
      # commit_pins (highest pin; v0.56.1 is a patch on the same ABI line).
      url = "github:gen3vra/hyprwinwrap/a72d3eeecfb0eaab64092c23410662ec907ca671";
      flake = false;
    };
    # No flake in this repo; plain source, packaged manually in pkgs/hypr-edgehover.nix
    hypr-edgehover = {
      # Main (77b5e14): "adapt to Hyprland v0.56" — builds against v0.56.1
      # headers (pre-#15779: desktop/view/Window.hpp still present).
      url = "github:gfhdhytghd/hypr-edgehover/main";
      flake = false;
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
        ./modules/system/hosts/Lingnao.nix
      ];
    };
}
