{
  config,
  pkgs,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.settings = {

    env = [
      # Environment variables for Hyprland and other apps
      {
        _args = [
          "NIXOS_OZONE_WL"
          "1"
        ];
      }
      {
        _args = [
          "XDG_CURRENT_DESKTOP"
          "Hyprland"
        ];
      }
      {
        _args = [
          "XDG_SESSION_TYPE"
          "wayland"
        ];
      }
      {
        _args = [
          "XDG_SESSION_DESKTOP"
          "Hyprland"
        ];
      }
      {
        _args = [
          "HYPRCURSOR_THEME"
          "catppuccin-macchiato-light-cursors"
        ];
      }
      {
        _args = [
          "HYPRCURSOR_SIZE"
          "32"
        ];
      }
      {
        _args = [
          "QT_WAYLAND_DISABLE_WINDOWDECORATION"
          "1"
        ];
      }
      {
        _args = [
          "QT_QPA_PLATFORM"
          "wayland"
        ];
      }
      {
        _args = [
          "QT_QPA_PLATFORMTHEME"
          "qt5ct"
        ];
      }
      {
        _args = [
          "GDK_BACKEND"
          "wayland,x11,*"
        ];
      }
      {
        _args = [
          "XCURSOR_THEME"
          "catppuccin-macchiato-light-cursors"
        ];
      }
      {
        _args = [
          "XCURSOR_SIZE"
          "32"
        ];
      }
      # {
      #   _args = [ "WLR_DRM_DEVICES" "/dev/dri/card1" ];
      # }
      # {
      #   _args = [ "WLR_RENDER_DRM_DEVICE" "/dev/dri/renderD128" ];
      # }
      {
        _args = [
          "MOZ_ENABLE_WAYLAND"
          "1"
        ];
      }
      {
        _args = [
          "CLUTTER_BACKEND"
          "wayland"
        ];
      }
    ];

    on = {
      _args = [
        "hyprland.start"
        (lib.generators.mkLuaInline ''
          function()
            -- Launch the shell / bar
            hl.exec_cmd("noctalia")
            -- Launch notifications service (swaync or mako)
            hl.exec_cmd("/run/current-system/sw/bin/nm-applet")
            -- Volume and brightness services
            hl.exec_cmd("avizo-service")

            -- Polkit authentication agent
            hl.exec_cmd("systemctl --user start hyprpolkitagent")

            -- Idle and power management
            -- hl.exec_cmd("hypridle") -- disabled: run as systemd user unit via home-manager services.hypridle

            -- Application autostarts
            -- hl.exec_cmd("copyq")
            hl.exec_cmd("wl-paste --watch cliphist store")
            hl.exec_cmd("syncthingtray")
            hl.exec_cmd("keepassxc")

            -- Wallpaper and background setup
            hl.exec_cmd("swww-daemon --format xrgb")
            hl.exec_cmd("waypaper --restore")
            -- Configured for Sylix: Enable wallpaper daemon management
            -- hl.exec_cmd("swaybg -m fill -i ~/Wallpaper/Image34.jpg")
            hl.exec_cmd("sylix --daemon")

            -- Run the custom autostart script
            -- hl.exec_cmd("~/.config/hypr/scripts/restartbar&wall.sh")
            hl.exec_cmd("~/bin/keyboard_led_control.sh")
            hl.exec_cmd("~/bin/hyprland-clean")
            -- Launching hyprshade for window effects
            hl.exec_cmd("hyprsunset")
            hl.exec_cmd("hyprctl dispatch submap global")
          end
        '')
      ];
    };
  };
}
