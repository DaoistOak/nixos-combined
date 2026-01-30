{
  config,
  pkgs,
  lib,
  ...
}:

{
  wayland.windowManager.hyprland = {
    settings = {

      windowrule = [
        # Workspace rules
        "match:class ^(alacritty)$, workspace 1"
        "match:class ^(firefox)$, workspace 2"
        "match:class ^(kate|geany)$, workspace 3"
        "match:class ^(pcmanfm-qt)$, workspace 4"
        "match:title ^(ranger)$, workspace 4"
        "match:class ^(rhythmbox|cantata)$, workspace 5"
        "match:title ^(ncmpcpp)$, workspace 5"
        "match:class ^(mpv)$, workspace 6"
        "match:class ^(discord|WebCord)$, workspace 7"
        "match:title ^(htop|bashtop)$, workspace 9"

        # Floating windows
        "match:class ^(pavucontrol)$, float on"
        "match:class ^(qalculate-qt)$, float on"
        "match:class ^(com.github.hluk.copyq)$, float on"
        "match:class ^(xarchiver)$, float on"
        "match:class ^(org.qbittorrent.qBittorrent)$, float on"
        "match:class ^(lxqt-sudo)$, float on"
        "match:class ^(pcmanfm-qt)$, match:title ^(Properties)$, float on"
        "match:class ^(pcmanfm-qt)$, match:title ^(Preferences)$, float on"
        "match:class ^(pcmanfm-qt)$, match:title ^(Choose an Application)$, float on"
        "match:class ^(pcmanfm-qt)$, match:title ^(Copy Files)$, float on"
        "match:class ^(pcmanfm-qt)$, match:title ^(Move Files)$, float on"
        "match:class ^(pcmanfm-qt)$, match:title ^(Confirm to replace files)$, float on"
        "match:class ^(blueman-manager)$, float on"
        "match:class ^(org.kde.polkit-kde-authentication-agent-1)$, float on"
        "match:class ^(nm-connection-editor)$, float on"
        "match:class ^(xdg-desktop-portal-hyprland)$, float on"
        "match:class ^(once)$, match:title ^(sudo)$, float on"
        "match:class ^(steam)$, match:title ^(Steam)$, float on"
        "match:class ^(waypaper)$, match:title ^(Waypaper)$, float on"

        # Firefox dialogs and picture-in-picture
        "match:class ^(firefox)$, match:title ^(Save File|Open File|Picture-in-Picture)$, float on"
        "match:class ^(firefox)$, match:title ^(Picture-in-Picture)$, pin on"
        "match:class ^(firefox)$, match:title ^(Picture-in-Picture)$, decorate off"
        "match:class ^(firefox)$, match:title ^(Picture-in-Picture)$, rounding 0"
        "match:class ^(firefox)$, match:title ^(Picture-in-Picture)$, no_shadow on"

        # Steam overlay or apps (if needed)
        # "match:class ^(steam_app)$, immediate on"
      ];

      # Layer rules (ignore certain overlays)
      layerrule = [
        # "ignorezero, swaync-control-center"
        # "ignorezero, avizo"
        # "ignorezero, waybar"
        # "ignorezero, rofi"
      ];
    };
  };
}
