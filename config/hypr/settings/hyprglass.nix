{
  config,
  lib,
  ...
}:

{
  wayland.windowManager.hyprland.extraConfig = ''
    if hl.plugin.hyprglass then
      local hg = hl.plugin.hyprglass
      hg.config({
        default_theme = "dark",
        default_preset = "clear",
        -- Leave layer surfaces (bar/swaync) alone; that hook is the most
        -- version-sensitive part of the plugin.
        layers = { enabled = 0 },
      })
    end
  '';
}
