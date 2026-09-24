{
  config,
  pkgs,
  inputs,
  ...
}:

{
  services.xserver.enable = true;

  # Stock portal from binary cache; mask override to avoid forcing a local build.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      let
        stock = pkgs.xdg-desktop-portal-hyprland;
      in
      stock // { override = _: stock; };
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
