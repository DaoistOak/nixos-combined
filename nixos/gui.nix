{ config, pkgs, inputs, ... }:

let
  catppuccin-sddm-custom = pkgs.catppuccin-sddm.override {
    flavor = "macchiato";
    accent = "mauve";
    font = "JetBrains Mono";
    fontSize = "9";
    background = "${./sddm/wallpaper}";
    loginBackground = true;
  };
in
{
  # Enable X11
  services.xserver.enable=true;
  programs.xwayland.enable = true;

  # Enable SDDM
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-macchiato-mauve";
  };
  # Enable KDE Plasma 6
  services.desktopManager.plasma6= {
    enable = true;
    # Now nest your KWin tweaks here—this is the correct path
  };
# --- KWallet 6 auto-unlock at login ---------------------------
  security.pam.services.sddm.enableKwallet = true;     # still works
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

  programs.steam.enable = true;
  programs.hyprland.enable = true;
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;  # Use portal for file pickers too
    configPackages = [ pkgs.kdePackages.xdg-desktop-portal-kde ];  # Or -kde for Plasma
#     extraPortals = [  pkgs.kdePackages.xdg-desktop-portal-kde ];

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
  services.pulseaudio.enable=false;
  # Enable real-time scheduling for better audio performance
  security.rtkit.enable = true;

  # SDDM theme package
  environment.systemPackages = [ catppuccin-sddm-custom ];
}
