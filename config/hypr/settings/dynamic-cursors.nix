{
  config,
  lib,
  ...
}:

{
  wayland.windowManager.hyprland.settings.config = {
    plugin.dynamic_cursors = {
      enabled = true;
      # Only shake-to-find; no cursor simulation (tilt/rotate/stretch)
      mode = "none";
      shake = {
        enabled = true;
        timeout = 2000;
      };
    };
  };
}
