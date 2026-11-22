# System-level (NixOS) `programs.*` declarations.
# Single source of truth for NixOS program options, mirroring pkgs/default.nix
# for packages. Edit here; wired into the system config via
# modules/system/config/programs/default.nix.
{
  pkgs,
  inputs,
  lib,
  ...
}:

{
  programs = {
    gamemode = {
      enable = true;
      settings = {
        general = {
          desiredgov = "performance";
          inhibit_screensaver = 1;
        };
        custom = {
          start = "/home/zeph/.config/hypr/scripts/performance-mode.sh start";
          end = "/home/zeph/.config/hypr/scripts/performance-mode.sh end";
        };
      };
    };
    hyprland = {
      enable = true;
      withUWSM = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.override {
        stdenv = pkgs.stdenv;
      };
      portalPackage =
        let
          stock = pkgs.xdg-desktop-portal-hyprland;
        in
        stock // { override = _: stock; };
    };

    xwayland.enable = true;
    xwayland.package = pkgs.xwayland;

    nix-ld = {
      enable = true;
      libraries =
        with pkgs;
        [
          libtheora
          speex
          libgudev
          libvdpau
        ]
        ++ (with pkgs.pkgsi686Linux; [
          libtheora
          speex
          libgudev
          libvdpau
        ]);
    };

    zsh.enable = true;
    direnv.enableZshIntegration = true;
  };
}
