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
in
{
  boot = {
    resumeDevice = "/dev/disk/by-uuid/c90cb3d2-feba-424e-a25b-146d24f9bd0d";
    kernelParams = [ "zswap.enabled=0" ];
    extraModulePackages = [ ];
    kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;

    loader.systemd-boot.enable = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    algorithm = "zstd";
    priority = 100;
  };

  systemd.services = {
    "systemd-hibernate".serviceConfig = {
      ExecStartPre = [
        "-${pkgs.coreutils}/bin/sync"
        "-${pkgs.runtimeShell} -c 'echo 3 > /proc/sys/vm/drop_caches'"
        "-${pkgs.util-linux}/bin/swapoff /dev/zram0"
      ];
      ExecStartPost = reenableZram;
      ExecStopPost = reenableZram;
    };
    "systemd-suspend-then-hibernate".serviceConfig = {
      ExecStartPre = [
        "-${pkgs.coreutils}/bin/sync"
        "-${pkgs.runtimeShell} -c 'echo 3 > /proc/sys/vm/drop_caches'"
        "-${pkgs.util-linux}/bin/swapoff /dev/zram0"
      ];
      ExecStartPost = reenableZram;
      ExecStopPost = reenableZram;
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
