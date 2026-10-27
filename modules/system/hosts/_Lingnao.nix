{ inputs, ... }:
{
  flake.nixosConfigurations.Lingnao = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    # Dendritic: every .nix under modules/system/ is auto-discovered by
    # import-tree, so aspect modules must NOT be listed here. The leading `_`
    # in this file's name is what keeps it (a flake-parts module, not a NixOS
    # module) out of that tree -- import-tree skips any path containing `/_`.
    # What stays listed: modules/shared (outside the tree, shared with the
    # home config) and the upstream module sets, which are flake inputs and
    # not files.
    modules = [
      # `../.` because a bare `../` is not a valid Nix path literal.
      (inputs.import-tree ../.)
      ../../shared/var.nix
      inputs.home-manager.nixosModules.default
      {
        # Home Manager NixOS integration is imported but not actively configured.
        # Primary home config is standalone via flake.homeConfigurations."zeph"
        # (see below) for use with `home-manager switch --flake .#zeph`.
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

  # homeConfigurations must have type = "homeManagerConfiguration" (string)
  # for `nh home build` to work. Older home-manager versions set this automatically;
  # home-manager 4.4.2 does not, so we set it here.
  flake.homeConfigurations."zeph" =
    let
      cfg = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = (import ../../../overlays/overlays.nix { inherit inputs; }).home;
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [
          (inputs.import-tree ../../home)
          ../../shared/var.nix
          inputs.catppuccin.homeModules.catppuccin
          inputs.stylix.homeModules.stylix
        ];
      };
    in
    builtins.removeAttrs cfg [ "type" ] // { type = "homeManagerConfiguration"; };
}
