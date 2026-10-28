{
  description = "Dendritic NixOS configuration for zeph on Lingnao";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/61b7c44c4073f0b827768aff0049561b5110ea5a";
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
    hyprland = {
      # v0.56.2 (efb50993), current stable. Revs below must move together with
      # hypr-dynamic-cursors: the plugin pins an exact compositor commit, so a
      # mismatched pair fails at load with "version mismatch!".
      url = "github:hyprwm/Hyprland/efb50993780079460b0cbed1363e2166a2de1d9f";

      # nixpkgs override (glaze). v0.56.2's CMakeLists does
      # `find_package(glaze 7...<8 QUIET)` and falls back to FetchContent when
      # that misses -- which always happens on Hyprland's default nixpkgs pin
      # (e72e4f2, glaze 8.0.0), so the build dies in the sandbox with "could
      # not find git for clone of glaze". nixpkgs' own hyprland package works
      # around this with a postPatch, but that only helps the nixpkgs package:
      # the plugin flakes (hypr-dynamic-cursors, hyprland-scroll-overview) build
      # their OWN copy of Hyprland for its headers, and no downstream override
      # reaches those. Pinning the input's nixpkgs instead fixes it at the
      # source for every consumer, and drops the postPatch entirely.
      # 61b7c44c is Hyprland's own v0.56.1 nixpkgs pin and ships glaze 7.9.0,
      # which satisfies the constraint; v0.56.2 is a patch release on top of
      # the v0.56.1 tree, so the rest of its deps are unchanged.
      inputs.nixpkgs.url = "github:NixOS/nixpkgs/61b7c44c4073f0b827768aff0049561b5110ea5a";
    };

    # hyprland-guiutils: Hyprland GUI utilities (successor to hyprland-qtutils).
    # Built against the flake Hyprland dev output with deps from the
    # hyprland-packages overlay (matches how hyprwinwrap / hypr-edgehover are
    # built). Available as pkgs.hyprland-guiutils for downstream packages
    # (e.g. hypridle + custom tools that link against it).
    hyprland-guiutils = {
      url = "github:hyprwm/hyprland-guiutils/d038577531e3ab6646b13a82d17e610be34c30cc";
      # Pinned ahead of the main HEAD so a bump to a post-v0.56.x revision
      # cannot silently change the ABI of the C libs we link against.
      # Bump together with the pinned Hyprland rev + hyprwinwrap/hypr-edgehover
      # revs if the Hyprland ecosystem API changes.
      flake = true;
    };
    lazyvim = {
      # LazyVim home-manager module (programs.lazyvim). Plugin versions come
      # from nixpkgs; LazyVim itself is the nixpkgs vimPlugins.LazyVim package.
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Neovim plugin, not packaged in nixpkgs and pure Lua, so the checkout is
    # its own package and no build step is needed. Provides <leader>r's
    # language -> command resolution; see modules/home/config/modules/nvim.
    cook = {
      url = "github:07CalC/cook.nvim";
      flake = false;
    };
    pixie-sddm.url = "github:xCaptaiN09/pixie-sddm";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hypr-dynamic-cursors = {
      # 5a22428 is the rev hyprpm.toml pins for v0.56.2 (efb50993...); it is
      # the "draw cursor on toplevel capture like hl" fix, required because
      # 0.56.2 changed the renderSoftwareCursorsFor signature (#15638) and the
      # 0.56.1 pin (f5ba36c) no longer resolves. Switch both together.
      url = "github:VirtCode/hypr-dynamic-cursors/5a224284872208b5324759d535d65061043725de";
      inputs.hyprland.follows = "hyprland";
    };
    hyprland-scroll-overview = {
      url = "github:yayuuu/hyprland-scroll-overview";
      inputs.hyprland.follows = "hyprland";
    };
    # No flake upstream; plain source, packaged manually in pkgs/hyprwinwrap.nix
    hyprwinwrap = {
      # 3b6e337 is the single rev hyprpm.toml pins for v0.56.0, v0.56.1 AND
      # v0.56.2 (the plugin needed no source change across those patches).
      url = "github:gen3vra/hyprwinwrap/3b6e337b9ee934ee23179d1445cb8cacfc38af28";
      flake = false;
    };
    # No flake in this repo; plain source, packaged manually in pkgs/hypr-edgehover.nix
    hypr-edgehover = {
      # 77b5e14 (main, "adapt to Hyprland v0.56"): builds against v0.56.x
      # headers. Still pre-#15779, so desktop/view/Window.hpp must exist —
      # PR #15779 merged 2026-08-17, AFTER the v0.56.2 tag (2026-08-05), so
      # v0.56.2 is safe. Bumping past v0.56.2 WILL break this plugin.
      url = "github:gfhdhytghd/hypr-edgehover/77b5e1445361b3a1f7b6f03bb4bee15e91229c94";
      flake = false;
    };
    preload-ng.url = "github:miguel-b-p/preload-ng";
    nixos-loading-plymouth.url = "github:qboileau/nixos-load-plymouth";
  };

  outputs =
    inputs@{ flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        (import-tree ./flake-parts)
      ]
      ++ [
        ./modules/system/hosts/_Lingnao.nix
        inputs.home-manager.flakeModules.home-manager
      ];
    };
}
