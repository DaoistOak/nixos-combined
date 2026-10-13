{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    settings = {
      config = {
        input = {
          kb_file = "";
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "caps:escape_shifted_capslock";
          kb_rules = "";
          # 0 = disabled, 1 = full, 2 = loose. Focussing on hover is a *soft*
          # focus reason (FOCUS_REASON_FFM is not in Desktop::isHardInputFocusReason),
          # so scrolling:follow_focus / follow_min_visible decide whether the
          # scrolling view reacts to it -- see settings/scrolling.nix.
          follow_mouse = 1;

          touchpad = {
            natural_scroll = true;
            tap_to_click = true;
            scroll_factor = 0.6;
          };

          sensitivity = 0;
        };
      };
    };
  };
}
