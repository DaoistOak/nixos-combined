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
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    # stdenv override: the flake's pinned nixpkgs is glibc 2.42 but the system is
    # glibc 2.44 with a mesa requiring GLIBC_2.43. Hyprland dlopens that GBM
    # driver from /run/opengl-driver, so it must link the system glibc or it
    # aborts at startup ("MESA-LOADER: version GLIBC_2.43 not found" ->
    # "CBackend::create() failed!"). Deps (aquamarine/hyprutils/...) stay from
    # hyprland's own overlay, so plugins keep matching store paths.
    # MUST stay byte-identical to modules/home/.../hyprland/default.nix or the
    # session package and the home-manager package diverge.
    # hyprland input's own nixpkgs in flake.nix -- do NOT add a postPatch here,
    # it would not reach the plugins' private Hyprland builds.
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.override {
      stdenv = pkgs.stdenv;
    };
    portalPackage =
      let
        stock = pkgs.xdg-desktop-portal-hyprland;
      in
      stock // { override = _: stock; };
  };

  # Fix security wrapper for Hyprland: the wrapper script created by nix wraps
  # bin/Hyprland (a shell script), but the security wrapper requires an ELF.
  # Point it to the actual binary.
  security.wrappers.Hyprland.source = lib.mkForce "${inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.override { stdenv = pkgs.stdenv; }}/bin/.Hyprland-wrapped";

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
