{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.settings = {

    env = [
      # Environment variables for Hyprland and other apps
      "NIXOS_OZONE_WL,1"
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_TYPE,wayland"
      "XDG_SESSION_DESKTOP,Hyprland"
      "HYPRCURSOR_THEME,catppuccin-macchiato-light-cursors"
      "HYPRCURSOR_SIZE,32"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      "QT_QPA_PLATFORM,wayland"
      "QT_QPA_PLATFORMTHEME,qt5ct"
      "GDK_BACKEND,wayland,x11,*"
      "XCURSOR_THEME,catppuccin-macchiato-light-cursors"
      "XCURSOR_SIZE,32"
      # "WLR_DRM_DEVICES,/dev/dri/card1"
      # "WLR_RENDER_DRM_DEVICE,/dev/dri/renderD128"
      "MOZ_ENABLE_WAYLAND,1"
      "SDL_VIDEODRIVER,wayland"
      "CLUTTER_BACKEND,wayland"
    ];

    exec-once = [
      # Scripts and services
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "dbus-update-activation-environment --systemd HYPRLAND_INSTANCE_SIGNATURE"

      # Launch waybar with the specified configuration
      # "hyprpanel"
      "kwalletd6"
      "noctalia-shell"
      # Launch notifications service (swaync or mako)
      "/run/current-system/sw/bin/nm-applet"
      # Volume and brightness services
      "avizo-service"

      # Polkit authentication agent
      "hyprpolkitagent"

      # Idle and power management
      "hypridle"

      # Application autostarts
      "copyq"
      "syncthingtray"
      "keepassxc"

      # Wallpaper and background setup
      "swww-daemon --format xrgb"
      "waypaper --restore"
      # Uncomment and use if you want to start specific wallpaper or background managers
      # "exec-once = swaybg -m fill -i ~/Wallpaper/Image34.jpg"
      # "exec-once = hyprpaper"

      # Run the custom autostart script
      # "/.config/hypr/scripts/restartbar\&wall.sh"
      "~/bin/keyboard_led_control.sh"
      "~/bin/hyprland-clean"
      # Launching hyprshade for window effects
      "hyprsunset"
      "hyprctl dispatch submap global"
    ];
  };
}
