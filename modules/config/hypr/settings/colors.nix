{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  # Build-time default border colors (from the centralized themes DB) so a how
  # fresh build looks right before the first ./theme run. scripts/theme rewrites
  # hyprland-theme.lua and hyprctl reload re-applies it (extraConfig below), so
  # switching needs no rebuild.
  wayland.windowManager.hyprland.settings.config = {
    general.col = {
      active_border = "0x${config.colors.active.accent}";
      inactive_border = "0x${config.colors.active.overlay1}";
    };
  };

  # Runtime-swappable colors: dofile the theme file (like wezterm) and override
  # the border colors via hl.settings. hyprctl reload re-runs the whole
  # Lua config, which re-dofiles this, so ./theme + reload switches in place.
  # settings.source has been removed (hl.source is unsupported by config_builder).
  wayland.windowManager.hyprland.extraConfig = ''
    local th_file = os.getenv("HOME") .. "/.config/theme-switcher/hyprland-theme.lua"
    local ok, th = pcall(dofile, th_file)
    if ok and type(th) == "table" then
      hl.settings({
        general = {
          col = {
            active_border = th.active_border,
            inactive_border = th.inactive_border or th.active_border,
          },
        },
      })
    end
  '';
}
