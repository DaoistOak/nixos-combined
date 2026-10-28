{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    hl.bind(mod .. " + CONTROL + ALT + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland" })
  '';
}
