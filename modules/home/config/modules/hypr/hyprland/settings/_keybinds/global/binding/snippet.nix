{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    local mod = "SUPER"
    local scripts = "${config.xdg.configHome}/hypr/scripts"
  '';
}
