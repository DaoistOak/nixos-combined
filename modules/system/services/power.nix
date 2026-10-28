{ config, pkgs, lib, ... }:
{
  # logind: use the power key (LidSwitch) as hibernate, long-press as poweroff.
  services.logind = {
    settings.Login = {
      HandlePowerKey = "hibernate";
      HandlePowerKeyLongPress = "poweroff";
      HandleLidSwitch = "hibernate";
      HandleLidSwitchExternalPower = "suspend";
    };
  };

  # Hibernation: allow the full image size and re-enable zram swap after
  # hibernate (the swap header is wiped by the sleep cycle).
  systemd.services = {
    "systemd-hibernate".serviceConfig = {
      ExecStartPre = [
        "-${pkgs.runtimeShell} -c '${pkgs.coreutils}/bin/echo 0 > /sys/power/image_size'"
        "-${pkgs.coreutils}/bin/sync"
        "-${pkgs.runtimeShell} -c 'echo 3 > /proc/sys/vm/drop_caches'"
        "-${pkgs.util-linux}/bin/swapoff /dev/zram0"
      ];
      ExecStartPost = [
        "-${pkgs.runtimeShell} -c '${pkgs.util-linux}/bin/swapon -p 100 /dev/zram0 2>/dev/null || { ${pkgs.util-linux}/bin/mkswap /dev/zram0 >/dev/null 2>&1 && ${pkgs.util-linux}/bin/swapon -p 100 /dev/zram0; }'"
      ];
    };
    "systemd-suspend-then-hibernate".serviceConfig = {
      ExecStartPre = [
        "-${pkgs.runtimeShell} -c '${pkgs.coreutils}/bin/echo 0 > /sys/power/image_size'"
        "-${pkgs.coreutils}/bin/sync"
        "-${pkgs.runtimeShell} -c 'echo 3 > /proc/sys/vm/drop_caches'"
        "-${pkgs.util-linux}/bin/swapoff /dev/zram0"
      ];
      ExecStartPost = [
        "-${pkgs.runtimeShell} -c '${pkgs.util-linux}/bin/swapon -p 100 /dev/zram0 2>/dev/null || { ${pkgs.util-linux}/bin/mkswap /dev/zram0 >/dev/null 2>&1 && ${pkgs.util-linux}/bin/swapon -p 100 /dev/zram0; }'"
      ];
    };
  };

  # CPU frequency governor (power-profiles-daemon is disabled, so set directly).
  powerManagement.cpuFreqGovernor = "schedutil";

  # Lenovo IdeaPad Slim 5: force the EC to max-cooling fan mode (not persisted
  # by firmware). The sysfs path is gated by ConditionPathExists so a stock
  # machine without the IDEAPAD ACPI driver simply never creates the service.
  systemd.services.ideapad-fan-max = {
    description = "Set Lenovo IdeaPad EC fan_mode to Efficient Thermal Dissipation";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = [ "/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/fan_mode" ];
    script = ''
      echo 4 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/fan_mode
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # AC/battery power limit management via ryzenadj. Defined once (below) and
  # referenced by both the boot service and the udev ACAD runtime rule.
  applyAcPower = pkgs.writeShellScript "apply-ac-power" ''
    set -u
    ONLINE="$(cat /sys/class/power_supply/ACAD/online 2>/dev/null || echo 0)"
    if [ "$ONLINE" = "1" ]; then
      ${pkgs.ryzenadj}/bin/ryzenadj \
        --stapm-limit=54000 --fast-limit=60000 --slow-limit=54000 --tctl-temp=95 \
        2>/dev/null || true
      echo $((65535 * 60 / 100)) > /sys/class/backlight/amdgpu_bl1/brightness 2>/dev/null || true
    else
      ${pkgs.ryzenadj}/bin/ryzenadj \
        --stapm-limit=25000 --fast-limit=30000 --slow-limit=25000 --tctl-temp=90 \
        2>/dev/null || true
      echo $((65535 * 30 / 100)) > /sys/class/backlight/amdgpu_bl1/brightness 2>/dev/null || true
    fi
  '';

  systemd.services.apply-ac-power = {
    description = "Apply AC/battery tuned power limits (ryzenadj)";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${applyAcPower}";
    };
  };

  # udev: hotplug AC adapter to re-apply AC/battery power limits (ryzenadj).
  # Re-fires the ACAD rule at runtime rather than at boot only.
  services.udev.extraRules = ''
    ACTION=="change", KERNEL=="ACAD", SUBSYSTEM=="power_supply", RUN+="${applyAcPower}"
  '';
}
