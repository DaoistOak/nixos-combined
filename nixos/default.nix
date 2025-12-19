{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  flake.nixosConfigurations."Overlord" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    modules = [
      {
        nixpkgs.overlays = (import ../overlays/overlays.nix { inherit inputs; }).nixos;
      }
      ../nixos/configuration.nix
      inputs.home-manager.nixosModules.default
      inputs.chaotic.nixosModules.default
      inputs.stylix.nixosModules.stylix
      inputs.nixos-hardware.nixosModules.lenovo-ideapad-slim-5
    ];
  };
}
