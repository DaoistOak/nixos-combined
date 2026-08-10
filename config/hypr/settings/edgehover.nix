{
  config,
  lib,
  ...
}:

{
  wayland.windowManager.hyprland.settings.config = {
    plugin.hypr_edgehover = {
      enabled = 1;
      edges = "lrtb";
      inset = 1;
      # default pass sets from upstream README
      gap_pass = "hover,click,scroll,keyboard";
      layer_pass = "hover,keyboard";
      overhang_pass = "hover,keyboard";
      keyboard_focus = -1;
    };
  };
}
