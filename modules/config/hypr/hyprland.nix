{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./settings/animations.nix
    ./settings/colors.nix
    ./settings/decorations.nix
    ./settings/displays.nix
    ./settings/input.nix
    ./settings/keybinds.nix
    ./settings/plugins.nix
    ./settings/scrolling.nix
    ./settings/misc.nix
    ./settings/startup.nix
    ./settings/windowrules.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./scripts/hyprlock.nix
    ./scripts/media-idle.nix
    ./scripts/performance.nix
    ./scripts/session.nix
    ./scripts/super-tap-launcher.nix
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

}
