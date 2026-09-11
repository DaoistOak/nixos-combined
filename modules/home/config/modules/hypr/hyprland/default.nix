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
    ./scripts/airplane-mode.nix
    ./scripts/hyprlock.nix
    ./scripts/launch-bluetooth.nix
    ./scripts/launch-network.nix
    ./scripts/launch-terminal.nix
    ./scripts/media-idle.nix
    ./scripts/noctalia-restart.nix
    ./scripts/session.nix
    ./scripts/super-tap-launcher.nix
    ./scripts/switch-default-terminal.nix
    ./scripts/submap-bar.nix
    ./scripts/volume.nix
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

}
