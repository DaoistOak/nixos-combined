{
  config,
  pkgs,
  lib,
  ...
}:

let
  collectFiles =
    base: dir:
    let
      entries = builtins.readDir dir;
    in
    lib.foldl' (
      acc: name:
      let
        path = dir + "/${name}";
        type = entries.${name};
      in
      if type == "directory" then
        acc // collectFiles "${base}/${name}" path
      else if type == "regular" then
        acc
        // {
          "${base}/${name}" = path;
        }
      else
        acc
    ) { } (builtins.attrNames entries);

  # Windows boot files for dual-boot chainload via systemd-boot.
  winBootDir = ../../../nixos/efi/windows/Boot;
  winExtraFiles = lib.mapAttrs' (k: v: {
    name = "EFI/Microsoft" + (lib.removePrefix "." k);
    value = v;
  }) (collectFiles "." winBootDir);
in
{
  boot = {
    resumeDevice = "/dev/disk/by-uuid/c90cb3d2-feba-424e-a25b-146d24f9bd0d";
    extraModulePackages = [ ];
    kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;

    loader.systemd-boot = {
      extraFiles = winExtraFiles;
      extraEntries."windows.conf" = ''
        title Windows
        efi /EFI/Microsoft/bootmgfw.efi
        sort-key z_windows
      '';
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    algorithm = "zstd";
    priority = 100;
  };

  systemd.services = {
    "systemd-hibernate".serviceConfig = {
      ExecStartPre = "-${pkgs.coreutils}/bin/sync; -sh -c 'echo 3 > /proc/sys/vm/drop_caches'; -${pkgs.util-linux}/bin/swapoff /dev/zram0";
      ExecStartPost = "-${pkgs.util-linux}/bin/swapon /dev/zram0";
      ExecStopPost = "-${pkgs.util-linux}/bin/swapon /dev/zram0";
    };
    "systemd-suspend-then-hibernate".serviceConfig = {
      ExecStartPre = "-${pkgs.coreutils}/bin/sync; -sh -c 'echo 3 > /proc/sys/vm/drop_caches'; -${pkgs.util-linux}/bin/swapoff /dev/zram0";
      ExecStartPost = "-${pkgs.util-linux}/bin/swapon /dev/zram0";
      ExecStopPost = "-${pkgs.util-linux}/bin/swapon /dev/zram0";
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
