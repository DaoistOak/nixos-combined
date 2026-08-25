{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Enable X11
  services.xserver.enable = true;

  # Enable SDDM
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-macchiato-mauve";
  };
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # Use the stock portal so it comes from the binary cache. The module's
    # portalPackage.apply re-overrides anything accepting a `hyprland` arg
    # (forcing a local build against the flake's Hyprland), so mask `override`
    # to make the stock package pass through untouched. Portal and compositor
    # versions are allowed to differ per the module docs.
    portalPackage =
      let
        stock = pkgs.xdg-desktop-portal-hyprland;
      in
      stock // { override = _: stock; };
  };
  # Enable KDE Plasma 6
  services.desktopManager.plasma6 = {
    enable = true;
    # Now nest your KWin tweaks here—this is the correct path
  };
  # --- KWallet 6 auto-unlock at login ---------------------------
  security.pam.services.sddm.enableKwallet = true;

  # Polkit + setuid pkexec wrapper (KDE polkit agent provides GUI auth)
  security.polkit = {
    enable = true;
    enablePkexecWrapper = true;
  };

  # 🎧 Blueman (Bluetooth GUI) — disabled as requested
  services.blueman.enable = false;

  # Ensure KDE portal service is properly linked and started
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
  # PipeWire (Audio)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = false;
    wireplumber.enable = true;
  };
  # Enable real-time scheduling for better audio performance
  security.rtkit.enable = true;
}
