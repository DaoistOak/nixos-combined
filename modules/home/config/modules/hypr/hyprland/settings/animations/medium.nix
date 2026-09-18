# Medium animation preset: balanced and unobtrusive, a happy middle ground
# between fast and smooth. Modelled after MyLinuxForWork's "Standard" preset.
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
            "standard"
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
            "emphasizedDecel"
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
            "emphasizedAccel"
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
      ];

      # Animation configurations
      animation = [
        # Layer animations
        {
          leaf = "layersIn";
          enabled = true;
          speed = 5;
          bezier = "emphasizedDecel";
          style = "slide";
        }
        {
          leaf = "layersOut";
          enabled = true;
          speed = 4;
          bezier = "emphasizedAccel";
          style = "slide";
        }
        {
          leaf = "fadeLayers";
          enabled = true;
          speed = 5;
          bezier = "standard";
        }

        # Window animations
        {
          leaf = "windows";
          enabled = true;
          speed = 5;
          bezier = "emphasizedDecel";
          style = "popin 80%";
        }
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 5;
          bezier = "emphasizedDecel";
          style = "popin 80%";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 3;
          bezier = "emphasizedAccel";
          style = "popin 80%";
        }
        {
          leaf = "windowsMove";
          enabled = true;
          speed = 6;
          bezier = "standard";
          style = "slide";
        }

        # Workspace animations
        {
          leaf = "workspaces";
          enabled = true;
          speed = 6;
          bezier = "easeOutExpo";
          style = "slide";
        }
        {
          leaf = "specialWorkspace";
          enabled = true;
          speed = 4;
          bezier = "emphasizedDecel";
          style = "slidefadevert 15%";
        }

        # Misc animations
        {
          leaf = "fade";
          enabled = true;
          speed = 6;
          bezier = "standard";
        }
        {
          leaf = "fadeDim";
          enabled = true;
          speed = 6;
          bezier = "standard";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 8;
          bezier = "emphasizedDecel";
        }
      ];
    };
  };
}
