{ config, pkgs, lib, ... }:
{
  boot = {
    resumeDevice = "/dev/disk/by-uuid/c90cb3d2-feba-424e-a25b-146d24f9bd0d";
    # kernelParams are owned by ../config/hardware/default.nix (single mkForce).
    extraModulePackages = [ ];
    # systemd-boot bootloader.
    loader.systemd-boot.enable = true;
  };
}
