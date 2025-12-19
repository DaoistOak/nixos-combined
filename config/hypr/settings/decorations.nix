{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    settings = {
      # General settings
      general = {
        "gaps_in" = 3;
        "gaps_out" = 4;
        "border_size" = 2;
      };

      # Decoration settings
      decoration = {
        rounding = 14;
        blur = {
          enabled = true;
          "new_optimizations" = true;
          xray = false;
          size = 4;
          passes = 3;
          noise = 0;
          popups = true;
          # vibrancy = 0.2;
          # vibrancy_darkness = 0.2;
          "ignore_opacity" = true;
        };

        shadow = {
          "enabled" = true;
          "range" = 5;
          "offset" = "4, 4";
          "render_power" = 1;
          "ignore_window" = true;
        };
      };
    };
  };
}
