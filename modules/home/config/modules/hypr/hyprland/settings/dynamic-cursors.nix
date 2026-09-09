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
        # lower than upstream default 6.0 -> shakes are detected sooner
        threshold = 4.0;
        timeout = 2000;
      };
    };
  };
}
