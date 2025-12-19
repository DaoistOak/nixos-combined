{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    settings = {
      input = {
        kb_file = "";
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        follow_mouse = 1;

        touchpad = {
          natural_scroll = "yes";
          tap-to-click = "yes";
          scroll_factor = 0.6;
        };

        sensitivity = 0;
      };

      # # Gesture settings
      # gestures = {
      #   workspace_swipe = "yes";
      #   workspace_swipe_fingers = 3;
      # };
    };
  };
}
