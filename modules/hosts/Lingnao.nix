{ inputs, ... }:
{
  flake.nixosConfigurations.Lingnao = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ../../modules/system/boot/default.nix
      ../../modules/system/config/network/default.nix
      ../../modules/system/nix/default.nix
      ../../modules/system/misc/default.nix
      ../../modules/system/services/default.nix
      ../../modules/system/users/zeph/default.nix
      ../../modules/system/config/desktop/default.nix
      ../../modules/system/config/pkgs/default.nix
      ../../modules/system/config/themes/default.nix
      ../../nixos/hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      {
        home-manager.extraSpecialArgs = { inherit inputs; };
      }
      inputs.stylix.nixosModules.stylix
      inputs.nixos-hardware.nixosModules.lenovo-ideapad-slim-5
      inputs.preload-ng.nixosModules.default
      {
        nixpkgs.overlays = (import ../../overlays/overlays.nix { inherit inputs; }).nixos;
      }
    ];
  };

  flake.homeConfigurations."zeph" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      overlays = [ inputs.nur.overlays.default ];
    };
    extraSpecialArgs = { inherit inputs; };
    modules = [
      ../../modules/home/base/default.nix
      inputs.catppuccin.homeModules.catppuccin
      inputs.stylix.homeModules.stylix
    ];
  };
}
