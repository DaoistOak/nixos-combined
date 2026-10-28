{ config, pkgs, lib, ... }:
{
  # Plymouth boot splash. The stock nixos-loading-white theme is copied and
  # recolored to the theme-changer accent at build time.
  boot.plymouth = {
    theme = "nixos-loading-white";
    themePackages = [ pkgs.plymouth-nixos-loading-theme ];
  };
  boot.consoleLogLevel = 3;
}
