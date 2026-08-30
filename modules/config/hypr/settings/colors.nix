{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  # Runtime-swappable colors: dofile the theme file (like wezterm) and override
  # the border colors via hl.settings. hyprctl reload re-runs the whole
  # Lua config, which re-dofiles this, so ./theme + reload switches in place.
  # settings.source has been removed (hl.source is unsupported by config_builder).
  # Build-time defaults are set in the generated hyprland-theme.lua via the CLI,
  # which the dofile reads on every hyprctl reload.
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
