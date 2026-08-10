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

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
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
      # Pinned to v0.55.4 (latest release tag): the Lua config API and the
      # plugin stack (hyprspace/hyprgrass/gloview-era plugins) all target <=0.55;
      # Hyprland 0.56-dev broke their headers, and the ecosystem hasn't caught up.
      url = "github:hyprwm/Hyprland?ref=v0.55.4";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    hypr-dynamic-cursors = {
      # da447486: last rev that builds against v0.55.4 headers (newer revs target the
      # 0.56 restructure: src/pointer/, src/output/, src/state/...).
      url = "github:VirtCode/hypr-dynamic-cursors/da447486c8";
      inputs.hyprland.follows = "hyprland";
    };

    hyprspace = {
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };

    hyprgrass = {
      # 2da35f4a: last rev that builds against v0.55.4 headers (newer revs target
      # the 0.56 restructure: src/output/, src/state/, ...).
      url = "github:horriblename/hyprgrass/2da35f4a16";
      inputs.hyprland.follows = "hyprland";
    };

    # No flake in these repos; plain source, packaged manually in pkgs/
    hypr-edgehover = {
      # 9e12120d: last rev that builds against v0.55.4 headers (newer revs target
      # the 0.56 restructure: desktop/state/ViewState.hpp, ...).
      url = "github:gfhdhytghd/hypr-edgehover/9e12120d2e";
      flake = false;
    };
    hyprglass = {
      # 28e4eefc: last rev that builds against v0.55.4 headers (newer revs target
      # the 0.56 restructure: layer alpha/viewState/sceneGeneration, ...).
      url = "github:hyprnux/hyprglass/28e4eefcba";
      flake = false;
    };
    # caelestia-shell = {
    #   url = "github:caelestia-dots/shell";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
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
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
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
