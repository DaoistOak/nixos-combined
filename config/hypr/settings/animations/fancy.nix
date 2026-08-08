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
            "specialWorkSwitch"
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
          leaf = "windowsIn";
          enabled = true;
          speed = 5;
          bezier = "emphasizedDecel";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 3;
          bezier = "emphasizedAccel";
        }
        {
          leaf = "windowsMove";
          enabled = true;
          speed = 6;
          bezier = "standard";
        }

        # Workspace animations
        {
          leaf = "workspaces";
          enabled = true;
          speed = 5;
          bezier = "standard";
        }
        {
          leaf = "specialWorkspace";
          enabled = true;
          speed = 4;
          bezier = "specialWorkSwitch";
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
          speed = 6;
          bezier = "standard";
        }
      ];
    };
  };
}
