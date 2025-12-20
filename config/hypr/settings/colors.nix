{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland.settings = {
    general."col.active_border" = lib.mkForce "rgb(${config.lib.stylix.colors.base0E})";
  };
}
