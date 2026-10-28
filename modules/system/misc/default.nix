{ config, pkgs, lib, ... }:
{
  # All the functionality that lived here has been split out:
  #   services/containers.nix      - docker, podman, waydroid, libvirtd
  #   services/filesharing.nix     - samba
  #   services/devices.nix         - uinput + makima udev rules
  #   services/udev.nix            - USB device ownership + power rules
  #
  # This module is intentionally empty so the legacy file stays a shim.
}
