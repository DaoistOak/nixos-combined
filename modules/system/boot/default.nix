{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Re-enable zram swap after hibernate; the swap header is wiped by the
  # sleep cycle, so recreate it when swapon fails.
  reenableZram = "-${pkgs.runtimeShell} -c '${pkgs.util-linux}/bin/swapon -p 100 /dev/zram0 2>/dev/null || { ${pkgs.util-linux}/bin/mkswap /dev/zram0 >/dev/null 2>&1 && ${pkgs.util-linux}/bin/swapon -p 100 /dev/zram0; }'";
  # The kernel caps the hibernation image at /sys/power/image_size (default
  # 2/5 of RAM, ~5.3G here). Under memory pressure the snapshot needs more
  # preallocated pages than that, so hibernation dies with "Error -12 creating
  # image". Unset the cap so the kernel sizes the image to what is actually
  # needed (the 30G swap partition has room to spare).
  allowFullImage = "-${pkgs.runtimeShell} -c '${pkgs.coreutils}/bin/echo 0 > /sys/power/image_size'";
  hibernatePre = [
    allowFullImage
    "-${pkgs.coreutils}/bin/sync"
    "-${pkgs.runtimeShell} -c 'echo 3 > /proc/sys/vm/drop_caches'"
    "-${pkgs.util-linux}/bin/swapoff /dev/zram0"
  ];
  hibernatePost = [ reenableZram ];
in
{
  boot = {
    resumeDevice = "/dev/disk/by-uuid/c90cb3d2-feba-424e-a25b-146d24f9bd0d";
    kernelParams = lib.mkForce [ "zswap.enabled=0" "amdgpu.sg_display=0" ];
    extraModulePackages = [ ];
    kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;

    loader.systemd-boot.enable = true;
  };

  zramSwap = {
    enable = true;
    # Keep zram small: compressed swap lives in RAM, so everything swapped to
    # zram is folded into the hibernation image. With a 30G disk swap
    # partition available, a 1.3G zram still absorbs bursty swap pressure
    # without inflating the image from under-pressure sleep cycles.
    memoryPercent = 10;
    algorithm = "zstd";
    priority = 100;
  };

  systemd.services = {
    "systemd-hibernate".serviceConfig = {
      ExecStartPre = hibernatePre;
      ExecStartPost = hibernatePost;
    };
    "systemd-suspend-then-hibernate".serviceConfig = {
      ExecStartPre = hibernatePre;
      ExecStartPost = hibernatePost;
    };
  };

  services.logind = {
    settings.Login = {
      HandlePowerKey = "hibernate";
      HandlePowerKeyLongPress = "poweroff";
      HandleLidSwitch = "hibernate";
      HandleLidSwitchExternalPower = "suspend";
    };
  };

  powerManagement.cpuFreqGovernor = "schedutil";
}
