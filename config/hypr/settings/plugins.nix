{
  config,
  pkgs,
  inputs,
  ...
}:

{
  wayland.windowManager.hyprland = {
    plugins = [
    ];

    settings = {
      plugin = {
      };
    };
  };
}
