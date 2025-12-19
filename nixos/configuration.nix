# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./pkgs-config.nix
      ./services.nix
      ./users.nix
      ./gui.nix
    ];


  # System settings
  system = {
    autoUpgrade = {
      enable = true;
      dates = "weekly";
    };
    stateVersion = "25.11";
  };
  # Nix Settings
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  # Networking settings
  networking = {
    hostName = "Overlord";
    networkmanager = {
      enable = true;
    };
    nftables = {
      enable = true;
    };
  };
  # Localization settings
  time.timeZone = "Asia/Kathmandu";
  i18n.defaultLocale = "en_US.UTF-8";
  # Virtualization
  virtualisation = {
    docker.enable = true;
    waydroid.enable=true;
    libvirtd = {
      enable = true;
      extraConfig = ''
        virtiofsd_path = "${pkgs.qemu}/bin/virtiofsd"
      '';
    };
  };
  programs.xwayland.enable = true;
  # Console settings
  # /run/current-system/sw/share/consolefonts/ter-u16n.psfu.gz
  console.font = "/run/current-system/sw/share/consolefonts/ter-u18n.psf.gz";

  # Stylix theming
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    targets.console.enable = true;
    targets.plymouth.enable = true;
  };

  environment.systemPackages = with pkgs; [
    base16-schemes
  ];

}