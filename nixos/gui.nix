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
  programs.hyprland.enable = true;
  # Enable KDE Plasma 6
  services.desktopManager.plasma6 = {
    enable = true;
    # Now nest your KWin tweaks here—this is the correct path
  };
  # --- KWallet 6 auto-unlock at login ---------------------------
  security.pam.services.sddm.enableKwallet = true; # still works
  # --- Ensure kwalletd6 is running -------------------------------
  systemd.user.services.kwalletd6 = {
    description = "KWallet 6 Daemon";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.kdePackages.kwallet}/bin/kwalletd6 --pam-login";
      Restart = "always";
    };
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
    xdgOpenUsePortal = true;
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
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
    wireplumber.enable = true;
  };
  services.pulseaudio.enable = false;
  # Enable real-time scheduling for better audio performance
  security.rtkit.enable = true;
}
