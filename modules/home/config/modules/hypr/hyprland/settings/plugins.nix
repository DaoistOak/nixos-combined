{
  config,
  pkgs,
  inputs,
  ...
}:

{
  wayland.windowManager.hyprland = {
    plugins = [
      inputs.hyprland-scroll-overview.packages.${pkgs.stdenv.hostPlatform.system}.scrolloverview
      (import ../../../../../../../pkgs/hypr-edgehover.nix { inherit inputs; })
    ];
  };
}
