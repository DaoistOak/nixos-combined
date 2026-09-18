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

    # Higher fidelity audio: 24-bit processing, best resampler.
    extraConfig.pipewire."99-audio-quality" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.allowed-rates = [
          44100
          48000
          96000
        ];
      };
      stream.properties = {
        audio.format = "S32LE";
        audio.resample.quality = 15;
      };
    };

    wireplumber.extraConfig."99-audio-quality" = {
      "wireplumber.settings" = {
        "audio.format" = "S32LE";
        "audio.rate" = 48000;
        "audio.channels" = 2;
        "audio.position" = [
          "FL"
          "FR"
        ];
      };
    };
  };

  security.rtkit.enable = true;
}
