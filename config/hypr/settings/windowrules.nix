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
        "match:class ^(pavucontrol)$, float"
        "match:class ^(qalculate-qt)$, float"
        "match:class ^(com.github.hluk.copyq)$, float"
        "match:class ^(xarchiver)$, float"
        "match:class ^(org.qbittorrent.qBittorrent)$, float"
        "match:class ^(lxqt-sudo)$, float"
        "match:class ^(pcmanfm-qt)$, match:title ^(Properties)$, float"
        "match:class ^(pcmanfm-qt)$, match:title ^(Preferences)$, float"
        "match:class ^(pcmanfm-qt)$, match:title ^(Choose an Application)$, float"
        "match:class ^(pcmanfm-qt)$, match:title ^(Copy Files)$, float"
        "match:class ^(pcmanfm-qt)$, match:title ^(Move Files)$, float"
        "match:class ^(pcmanfm-qt)$, match:title ^(Confirm to replace files)$, float"
        "match:class ^(blueman-manager)$, float"
        "match:class ^(org.kde.polkit-kde-authentication-agent-1)$, float"
        "match:class ^(nm-connection-editor)$, float"
        "match:class ^(xdg-desktop-portal-hyprland)$, float"
        "match:class ^(once)$, match:title ^(sudo)$, float"
        "match:class ^(steam)$, match:title ^(Steam)$, float"
        "match:class ^(waypaper)$, match:title ^(Waypaper)$, float"

        # Firefox dialogs and picture-in-picture
        "match:class ^(firefox)$, match:title ^(Save File|Open File|Picture-in-Picture)$, float"
        "match:class ^(firefox)$, match:title ^(Picture-in-Picture)$, pin"
        "match:class ^(firefox)$, match:title ^(Picture-in-Picture)$, decorate off"
        "match:class ^(firefox)$, match:title ^(Picture-in-Picture)$, rounding 0"
        "match:class ^(firefox)$, match:title ^(Picture-in-Picture)$, no_shadow"

        # Steam overlay or apps (if needed)
        # "match:class ^(steam_app)$, immediate"
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
