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
          # 0 = center the focused column, 1 = only scroll far enough to fit it.
          # Keep 0 so deliberate input (click, keybind) recenters the window.
          focus_fit_method = 0;
          follow_focus = true;
          # Only gates INPUT_MODE_SOFT focus, i.e. focus that arrives without a
          # click or keybind -- which is exactly what follow_mouse produces
          # (FOCUS_REASON_FFM is not a "hard" input reason). At 1.0 a hovered
          # window never moves the tape unless it is 100% off-screen, while
          # clicks and keybinds bypass this check entirely and still center.
          follow_min_visible = 1.0;
          explicit_column_widths = "0.2 ,0.4, 0.5, 0.8, 1.0";
          wrap_focus = false;
          wrap_swapcol = true;
          direction = "right";
        };
      };
    };
  };
}
