{ config, pkgs, ... }:

{
  # Display setup for laptop

  wayland.windowManager.hyprland.extraConfig = ''
    monitor=eDP-1,1920x1200@60,0x0,1
  '';
}
