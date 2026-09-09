{
  config,
  pkgs,
  inputs,
  ...
}:

{
  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-macchiato-mauve";
  };

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

  security.pam.services.sddm.enableKwallet = true;
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
