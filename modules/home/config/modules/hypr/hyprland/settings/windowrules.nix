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

        # Keep browsers fully opaque: transparent web UI hurts readability.
        # Covers everything launched from SUPER+E,W (firefox, zen, brave,
        # qutebrowser) plus librewolf.
        {
          match = {
            class = "^(zen|org\\.zen-browser\\.[Zz]en|[Ff]irefox|[Bb]rave(-[Bb]rowser)?|[Qq]utebrowser|[Ll]ibrewolf)$";
          };
          opacity = "1 override 1 override";
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

        # Browser dialogs (Save/Open file)
        {
          match = {
            class = "^(firefox|zen|org.zen-browser.zen|librewolf)$";
            title = "^(Save File|Open File)$";
          };
          float = true;
        }

        # Picture-in-Picture for all browsers - keep it pinned on top as an overlay
        {
          match = {
            title = "^(Picture-in-Picture|Picture in Picture)$";
          };
          float = true;
        }
        {
          match = {
            title = "^(Picture-in-Picture|Picture in Picture)$";
          };
          pin = true;
        }
        {
          match = {
            title = "^(Picture-in-Picture|Picture in Picture)$";
          };
          decorate = false;
        }
        {
          match = {
            title = "^(Picture-in-Picture|Picture in Picture)$";
          };
          rounding = 0;
        }
        {
          match = {
            title = "^(Picture-in-Picture|Picture in Picture)$";
          };
          no_shadow = true;
        }

        # Steam overlay or apps (if needed)
        # { match = { class = "^(steam_app)$" }; immediate = true; }
      ];

      # Layer rules — bars, panels, OSD, notifications, wallpaper, widgets
      # Valid effects for hl.layer_rule in Hyprland v0.56: no_anim, blur,
      # blur_popups, ignore_alpha, dim_around, xray, animation, order,
      # above_lock, no_screen_share.
      layer_rule = [
        # Noctalia bars, dock, panels, notifications, desktop widgets: blur
        # whatever scrolls behind them and sample alpha for correct blending.
        {
          match = {
            namespace = "^noctalia-(bar-|dock|panel|attached-panel|notification|desktop-widget-)";
          };
          blur = true;
          ignore_alpha = 0.5;
        }

        # Quickshell floating capsules (overview, themeswitcher, terminal-switcher).
        {
          match = {
            namespace = "^quickshell$";
          };
          blur = true;
          ignore_alpha = 0.5;
        }

        # Noctalia screen corners and hot corners: invisible hitboxes, xray so
        # they don't occlude the blur/cursor-over interactions underneath.
        {
          match = {
            namespace = "^(noctalia-screen-corner|hot_corner_)";
          };
          xray = true;
        }

        # OSDs (noctalia + avizo) should stay sharp: blur defaults off anyway,
        # set it explicitly so nothing re-enables it.
        {
          match = {
            namespace = "^(noctalia-osd|avizo)$";
          };
          blur = false;
        }

        # Wallpaper layers (hyprpaper, swww, sylix): pure backdrops, never blur.
        {
          match = {
            namespace = "^(hyprpaper|swww|sylix)$";
          };
          blur = false;
        }
      ];
    };
  };
}
