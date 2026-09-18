{
  config,
  lib,
  pkgs,
  ...
}:

{
  wayland.windowManager.hyprland = {
    settings = {
      config = {
        general = {
          "gaps_in" = 8;
          "gaps_out" = 16;
          "border_size" = 2;
        };

        decoration = {
          rounding = 14;
          # Global default: fully opaque. The 0.90 transparency for the
          # whitelisted apps is applied via a runtime window rule in keybinds.nix,
          # so SUPER+W,T can flip ALL windows to opaque and persist that choice.
          active_opacity = 1.0;
          inactive_opacity = 1.0;
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
            # Keep shadows dark regardless of theme. The catppuccin module
            # derives shadow.color from the flavor's base, giving light themes
            # a near-invisible pale shadow; pin a fixed near-black instead.
            "color" = lib.mkForce "rgba(1a1a1aee)";
          };
        };
      };
    };
  };
}
