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
          kb_options = "";
          kb_rules = "";
          follow_mouse = 1;

          touchpad = {
            natural_scroll = true;
            tap-to-click = true;
            scroll_factor = 0.6;
          };

          sensitivity = 0;
        };
      };
    };
  };
}
