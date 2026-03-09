{
  config,
  pkgs,
  inputs,
  ...
}:

{
  wayland.windowManager.hyprland = {
    plugins = [
      # pkgs.hyprlandPlugins.hyprgrass # inputs.Hyprspace.packages.${pkgs.system}.Hyprspace
      # pkgs.hyprlandPlugins.hyprscrolling
    ];
  };
}
