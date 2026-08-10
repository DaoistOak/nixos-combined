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
    ./settings/dynamic-cursors.nix
    ./settings/edgehover.nix
    ./settings/hyprglass.nix
    ./settings/hyprgrass.nix
    ./settings/hyprspace.nix
    ./settings/input.nix
    ./settings/keybinds.nix
    ./settings/misc.nix
    ./settings/plugins.nix
    ./settings/startup.nix
    ./settings/windowrules.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./scripts/hyprlock.nix
    ./scripts/media-idle.nix
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    # glaze: v0.55.4's start/ subproject fetch-depends glaze via FetchContent
    # (git + network, blocked by the nix sandbox). hyprland's own pinned nixpkgs
    # ships glaze 7.7.1, which satisfies its find_package(glaze 7...<8).
    package =
      (inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland).overrideAttrs
        (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [
            pkgs.git
          ];
          buildInputs = old.buildInputs ++ [
            inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.glaze
          ];
        });
  };
}
