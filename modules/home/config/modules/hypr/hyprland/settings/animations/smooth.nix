# Smooth animation preset: fluid and organic with a subtle overshoot.
# Based on mylinuxforwork/dotfiles "animations-smooth".
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
            "overshot"
            {
              type = "bezier";
              points = [
                [
                  0.05
                  0.9
                ]
                [
                  0.1
                  1.05
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
        {
          _args = [
            "easeOutBack"
            {
              type = "bezier";
              points = [
                [
                  0.34
                  1.56
                ]
                [
                  0.64
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeInBack"
            {
              type = "bezier";
              points = [
                [
                  0.36
                  0
                ]
                [
                  0.66
                  (-0.56)
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeInOutBack"
            {
              type = "bezier";
              points = [
                [
                  0.68
                  (-0.6)
                ]
                [
                  0.32
                  1.6
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
          speed = 4;
          bezier = "easeOutBack";
          style = "slide";
        }
        {
          leaf = "layersOut";
          enabled = true;
          speed = 3;
          bezier = "easeInBack";
          style = "slide";
        }
        {
          leaf = "fadeLayersIn";
          enabled = true;
          speed = 5;
          bezier = "easeOutExpo";
        }
        {
          leaf = "fadeLayersOut";
          enabled = true;
          speed = 4;
          bezier = "easeOutExpo";
        }

        # Window animations
        {
          leaf = "windows";
          enabled = true;
          speed = 3;
          bezier = "overshot";
          style = "slide";
        }
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 7;
          bezier = "easeOutBack";
          style = "popin 80%";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 2;
          bezier = "easeOutExpo";
          style = "popin 80%";
        }
        {
          leaf = "windowsMove";
          enabled = true;
          speed = 6;
          bezier = "easeInOutBack";
          style = "slide";
        }

        # Workspace animations
        {
          leaf = "workspaces";
          enabled = true;
          speed = 10;
          bezier = "easeOutExpo";
          style = "slide";
        }
        {
          leaf = "specialWorkspace";
          enabled = true;
          speed = 6;
          bezier = "easeOutBack";
          style = "slidevert";
        }

        # Misc animations
        {
          leaf = "fade";
          enabled = true;
          speed = 5;
          bezier = "easeOutBack";
        }
        {
          leaf = "fadeDim";
          enabled = true;
          speed = 5;
          bezier = "easeOutBack";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 5;
          bezier = "easeOutExpo";
        }
      ];
    };
  };
}
