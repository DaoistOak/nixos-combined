{
  config,
  pkgs,
  inputs,
  ...
}:

{
  wayland.windowManager.hyprland = {
    plugins = [
      inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.hyprland-scroll-overview.packages.${pkgs.stdenv.hostPlatform.system}.scrolloverview

      (import ../../../../../../../pkgs/hypr-edgehover.nix { inherit inputs; })
      (import ../../../../../../../pkgs/hyprwinwrap.nix { inherit inputs; })
    ];
  };
}
