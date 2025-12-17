{config, inputs, pkgs, ...}: 
{
  imports = [
    ./themes/catppuccin-macchiato-mauve.nix
  ];
  wayland.windowManager.hyprland.settings = {
  source = [
      "~/.config/hypr/themes/colors"
    ];
  };
}
