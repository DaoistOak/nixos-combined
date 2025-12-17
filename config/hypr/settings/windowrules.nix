{ config, pkgs, lib, ... }:

{
  wayland.windowManager.hyprland = {
    settings = {

      windowrulev2 = [
        # Workspace rules
        "workspace:1, class:^(alacritty)$"
        "workspace:2, class:^(firefox)$"
        "workspace:3, class:^(kate|geany)$"
        "workspace:4, class:^(pcmanfm-qt)$"
        "workspace:4, title:^(ranger)$"
        "workspace:5, class:^(rhythmbox|cantata)$"
        "workspace:5, title:^(ncmpcpp)$"
        "workspace:6, class:^(mpv)$"
        "workspace:7, class:^(discord|WebCord)$"
        "workspace:9, title:^(htop|bashtop)$"

        # Floating windows
        "float, class:^(pavucontrol)$"
        "float, class:^(qalculate-qt)$"
        "float, class:^(com.github.hluk.copyq)$"
        "float, class:^(xarchiver)$"
        "float, class:^(org.qbittorrent.qBittorrent)$"
        "float, class:^(lxqt-sudo)$"
        "float, class:^(pcmanfm-qt)$, title:^(Properties)$"
        "float, class:^(pcmanfm-qt)$, title:^(Preferences)$"
        "float, class:^(pcmanfm-qt)$, title:^(Choose an Application)$"
        "float, class:^(pcmanfm-qt)$, title:^(Copy Files)$"
        "float, class:^(pcmanfm-qt)$, title:^(Move Files)$"
        "float, class:^(pcmanfm-qt)$, title:^(Confirm to replace files)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(org.kde.polkit-kde-authentication-agent-1)$"
        "float, class:^(nm-connection-editor)$"
        "float, class:^(xdg-desktop-portal-hyprland)$"
        "float, class:^(once)$, title:^(sudo)$"
        "float, class:^(steam)$, title:^(Steam)$"
        "float, class:^(waypaper)$, title:^(Waypaper)$"

        # Firefox dialogs and picture-in-picture
        "float, class:^(firefox)$, title:^(Save File|Open File|Picture-in-Picture)$"
        "pin, class:^(firefox)$, title:^(Picture-in-Picture)$"
        "noborder, class:^(firefox)$, title:^(Picture-in-Picture)$"
        "rounding 0, class:^(firefox)$, title:^(Picture-in-Picture)$"
        "noshadow, class:^(firefox)$, title:^(Picture-in-Picture)$"

        # Steam overlay or apps (if needed)
        # "immediate, class:^(steam_app)$"
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

