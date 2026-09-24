# Shared machine/user variables, imported by BOTH the NixOS host and the
# standalone home-manager config so every module reads one source of truth.
# Single-host setup: the defaults are the actual values; a future host file
# can override them in its own module scope.
{
  config,
  lib,
  ...
}:
{
  options.var = {
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "Lingnao";
      description = "NixOS hostname (matches the flake's nixosConfigurations name).";
    };

    username = lib.mkOption {
      type = lib.types.str;
      default = "zeph";
      description = "Primary user account (matches the flake's homeConfigurations name).";
    };

    configDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/home/${config.var.username}/.config/nixos";
      description = "Absolute path of this NixOS configuration repository.";
    };
  };
}
