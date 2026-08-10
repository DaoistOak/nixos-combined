{
  config,
  pkgs,
  inputs,
  ...
}:

{
  wayland.windowManager.hyprland = {
    plugins = [
      inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
      inputs.hyprspace.packages.${pkgs.stdenv.hostPlatform.system}.Hyprspace
      inputs.hyprgrass.packages.${pkgs.stdenv.hostPlatform.system}.default
      (import ../../../pkgs/hypr-edgehover.nix { inherit inputs; })
    ];
  };
}
