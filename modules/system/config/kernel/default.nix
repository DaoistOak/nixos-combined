{ config, pkgs, lib, ... }:
{
  # The CachyOS bore+BTTF kernel (with LTO). Single point of ownership so a
  # kernel bump is a one-line change in this file.
  boot.kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;

  # Out-of-tree patches for that kernel. These have to go through
  # boot.kernelPatches: nixpkgs re-derives the kernel via
  # `override (args: { ... })`, which *replaces* the whole argument set, so
  # anything set on the kernel derivation directly is silently dropped.
  #
  # Stock 7.2.4 drm/ttm leaves a per-VM bulk_move cursor dangling when a
  # swapped buffer object is closed; the next add on that cursor corrupts the
  # manager LRU and soft-locks the machine in amdgpu_cs_ioctl ~40s after
  # resuming from hibernation.
  boot.kernelPatches = [
    {
      name = "ttm-bulk-move-dangling-cursor";
      patch = ../../../../pkgs/kernel-patches/ttm-bulk-move-dangling-cursor.patch;
    }
  ];
}
