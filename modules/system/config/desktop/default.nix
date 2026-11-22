{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  services.xserver.enable = true;

  # Stock portal from binary cache; mask override to avoid forcing a local build.
  # Fix security wrapper for Hyprland: the wrapper script created by nix wraps
  # bin/Hyprland (a shell script), but the security wrapper requires an ELF.
  # Point it to the actual binary.
  security.wrappers.Hyprland = {
    owner = "root";
    group = "root";
    source = lib.mkForce "${inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.override { stdenv = pkgs.stdenv; }}/bin/.Hyprland-wrapped";
  };

  services.desktopManager.plasma6.enable = true;

  # UWSM-managed Hyprland is the default login session.
  services.displayManager.defaultSession = "hyprland-uwsm";

  security.polkit = {
    enable = true;
    enablePkexecWrapper = true;
  };

  services.blueman.enable = false;

  systemd.user.services.plasma-xdg-desktop-portal-kde = {
    description = "Portal service (KDE implementation)";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "xdg-desktop-portal.service" ];
    before = [ "xdg-desktop-portal.service" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.freedesktop.impl.portal.desktop.kde";
      ExecStart = "${pkgs.kdePackages.xdg-desktop-portal-kde}/libexec/xdg-desktop-portal-kde";
      Restart = "on-failure";
    };
  };

  xdg.portal = {
    enable = true;
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [
        "hyprland"
        "gtk"
      ];
      kde.default = [
        "kde"
        "gtk"
      ];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = false;
    wireplumber.enable = true;
  };

  security.rtkit.enable = true;
}
