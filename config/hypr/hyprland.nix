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
    ./settings/misc.nix
    ./settings/startup.nix
    ./settings/windowrules.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./scripts/hyprlock.nix
    ./scripts/media-idle.nix
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    # Use the plain pinned package: cachix stores the exact builds uploaded by
    # Hyprland CI for the github: fetcher, so this path hits the cache without
    # any overrideAttrs (which would change the hash and force a local compile).
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };
}
