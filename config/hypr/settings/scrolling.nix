{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    settings = {
      config = {
        general = {
          layout = "scrolling";
        };

        scrolling = {
          fullscreen_on_one_column = true;
          column_width = 0.47;
          focus_fit_method = 1;
          follow_focus = true;
          follow_min_visible = 0;
          explicit_column_widths = "0.4, 0.5, 0.8, 1.0";
          wrap_focus = true;
          wrap_swapcol = true;
          direction = "right";
        };
      };
    };
  };
}
