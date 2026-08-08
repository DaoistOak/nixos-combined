{
  config,
  pkgs,
  lib,
  ...
}:

{
  wayland.windowManager.hyprland = {
    settings = {
      window_rule = [
        # Workspace rules
        {
          match = {
            class = "^(alacritty)$";
          };
          workspace = 1;
        }
        {
          match = {
            class = "^(firefox)$";
          };
          workspace = 2;
        }
        {
          match = {
            class = "^(kate|geany)$";
          };
          workspace = 3;
        }
        {
          match = {
            class = "^(pcmanfm-qt)$";
          };
          workspace = 4;
        }
        {
          match = {
            title = "^(ranger)$";
          };
          workspace = 4;
        }
        {
          match = {
            class = "^(rhythmbox|cantata)$";
          };
          workspace = 5;
        }
        {
          match = {
            title = "^(ncmpcpp)$";
          };
          workspace = 5;
        }
        {
          match = {
            class = "^(mpv)$";
          };
          workspace = 6;
        }
        {
          match = {
            class = "^(discord|WebCord)$";
          };
          workspace = 7;
        }
        {
          match = {
            title = "^(htop|bashtop)$";
          };
          workspace = 9;
        }

        # Floating windows
        {
          match = {
            class = "^(pavucontrol)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(qalculate-qt)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(com.github.hluk.copyq)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(xarchiver)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(org.qbittorrent.qBittorrent)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(lxqt-sudo)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(pcmanfm-qt)$";
            title = "^(Properties)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(pcmanfm-qt)$";
            title = "^(Preferences)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(pcmanfm-qt)$";
            title = "^(Choose an Application)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(pcmanfm-qt)$";
            title = "^(Copy Files)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(pcmanfm-qt)$";
            title = "^(Move Files)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(pcmanfm-qt)$";
            title = "^(Confirm to replace files)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(blueman-manager)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(org.kde.polkit-kde-authentication-agent-1)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(nm-connection-editor)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(xdg-desktop-portal-hyprland)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(once)$";
            title = "^(sudo)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(steam)$";
            title = "^(Steam)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(waypaper)$";
            title = "^(Waypaper)$";
          };
          float = true;
        }

        # Firefox dialogs and picture-in-picture
        {
          match = {
            class = "^(firefox)$";
            title = "^(Save File|Open File|Picture-in-Picture)$";
          };
          float = true;
        }
        {
          match = {
            class = "^(firefox)$";
            title = "^(Picture-in-Picture)$";
          };
          pin = true;
        }
        {
          match = {
            class = "^(firefox)$";
            title = "^(Picture-in-Picture)$";
          };
          decorate = false;
        }
        {
          match = {
            class = "^(firefox)$";
            title = "^(Picture-in-Picture)$";
          };
          rounding = 0;
        }
        {
          match = {
            class = "^(firefox)$";
            title = "^(Picture-in-Picture)$";
          };
          no_shadow = true;
        }

        # Steam overlay or apps (if needed)
        # { match = { class = "^(steam_app)$" }; immediate = true; }
      ];

      # Layer rules (ignore certain overlays)
      # layer_rule = [
      #   { match = { namespace = "^(swaync-control-center)$" }; ignore_alpha = 0; }
      # ];
    };
  };
}
