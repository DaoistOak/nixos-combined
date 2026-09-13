{ inputs, ... }:
{
  flake.nixosConfigurations.Lingnao = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ../boot/default.nix
      ../config/network/default.nix
      ../nix/default.nix
      ../misc/default.nix
      ../services/default.nix
      ../users/zeph/default.nix
      ../config/desktop/default.nix
      ../config/pkgs/default.nix
      ../config/themes/default.nix
      ../config/hardware
      inputs.home-manager.nixosModules.default
      {
        home-manager.extraSpecialArgs = { inherit inputs; };
      }
      inputs.stylix.nixosModules.stylix
      inputs.nixos-hardware.nixosModules.lenovo-ideapad-slim-5
      inputs.preload-ng.nixosModules.default
      {
        nixpkgs.overlays = (import ../../../overlays/overlays.nix { inherit inputs; }).nixos;
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
      ../../home/base/default.nix
      inputs.catppuccin.homeModules.catppuccin
      inputs.stylix.homeModules.stylix
    ];
  };
}