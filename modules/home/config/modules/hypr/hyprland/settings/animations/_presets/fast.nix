# Fast animation preset: snappy and responsive, minimal motion.
# Tuned for the scrolling layout — quick column-by-column tape scrolling.
# Based on mylinuxforwork/dotfiles "animations-fast".
{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    settings = {
      config = {
        animations = {
          enabled = true;
        };
      };

      # Animation curves (beziers)
      curve = [
        {
          _args = [
            "linear"
            {
              type = "bezier";
              points = [
                [
                  0
                  0
                ]
                [
                  1
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "md3_standard"
            {
              type = "bezier";
              points = [
                [
                  0.2
                  0
                ]
                [
                  0
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "md3_decel"
            {
              type = "bezier";
              points = [
                [
                  0.05
                  0.7
                ]
                [
                  0.1
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "md3_accel"
            {
              type = "bezier";
              points = [
                [
                  0.3
                  0
                ]
                [
                  0.8
                  0.15
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeOutExpo"
            {
              type = "bezier";
              points = [
                [
                  0.16
                  1
                ]
                [
                  0.3
                  1
                ]
              ];
            }
          ];
        }
      ];

      # Animation configurations
      animation = [
        # Layer animations
        {
          leaf = "layersIn";
          enabled = true;
          speed = 2;
          bezier = "md3_decel";
          style = "slide";
        }
        {
          leaf = "layersOut";
          enabled = true;
          speed = 1;
          bezier = "md3_accel";
          style = "slide";
        }
        {
          leaf = "fadeLayers";
          enabled = true;
          speed = 1;
          bezier = "md3_decel";
        }

        # Window animations
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 2;
          bezier = "md3_decel";
          style = "popin 60%";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 1;
          bezier = "md3_accel";
          style = "popin 60%";
        }
        {
          leaf = "windowsMove";
          enabled = true;
          speed = 2.5;
          bezier = "md3_standard";
        }

        # Workspace animations
        {
          leaf = "workspaces";
          enabled = true;
          speed = 3;
          bezier = "easeOutExpo";
          style = "slidevert";
        }
        {
          leaf = "specialWorkspace";
          enabled = true;
          speed = 2;
          bezier = "md3_decel";
          style = "slidevert";
        }

        # Misc animations
        {
          leaf = "fade";
          enabled = true;
          speed = 2;
          bezier = "md3_decel";
        }
        {
          leaf = "fadeDim";
          enabled = true;
          speed = 2;
          bezier = "md3_decel";
        }
        {
          leaf = "fadePopups";
          enabled = true;
          speed = 1;
          bezier = "md3_decel";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 8;
          bezier = "md3_decel";
        }
        {
          leaf = "zoomFactor";
          enabled = true;
          speed = 2;
          bezier = "md3_standard";
        }
      ];
    };
  };
}
