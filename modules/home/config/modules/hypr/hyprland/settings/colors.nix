{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  # Runtime-swappable colors: dofile the theme file (like wezterm) and override
  # border colors via hl.config. hyprctl reload re-runs the Lua config, which
  # re-dofiles this, so ./theme + reload switches in place.
  wayland.windowManager.hyprland.extraConfig = ''
    local th_file = os.getenv("HOME") .. "/.config/theme-switcher/hyprland-theme.lua"
    local ok, th = pcall(dofile, th_file)
    if ok and type(th) == "table" then
      local function to_hypr_color(v)
        -- Table form { c1, c2, angle } becomes a gradient; scalar -> flat color.
        if type(v) == "table" then
          return {
            colors = { to_hypr_color(v.c1), to_hypr_color(v.c2) },
            angle = v.angle or 0,
          }
        end
        return "rgb(" .. v:gsub("^0x", "") .. ")"
      end

      -- Use the nested { general.col.active_border = ... } shape (the gradient
      -- type in the Lua config requires it). The border-angle daemon pushes
      -- only active_border via the same table, so these fields don't clash.
      hl.config({
        general = {
          col = {
            active_border = to_hypr_color(th.active_border),
            inactive_border = to_hypr_color(th.inactive_border or th.active_border),
          },
        },
      })
    end
  '';
}
