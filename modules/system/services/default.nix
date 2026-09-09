{
  config,
  pkgs,
  lib,
  ...
}:

let
  # `|| true` so a failed init (missing ryzen_smu / restricted /dev/mem) is not fatal.
  applyAcPower = pkgs.writeShellScript "apply-ac-power" ''
    set -u
    ONLINE="$(cat /sys/class/power_supply/ACAD/online 2>/dev/null || echo 0)"
    if [ "$ONLINE" = "1" ]; then
      ${pkgs.ryzenadj}/bin/ryzenadj \
        --stapm-limit=54000 --fast-limit=60000 --slow-limit=54000 --tctl-temp=95 \
        2>/dev/null || true
    else
      ${pkgs.ryzenadj}/bin/ryzenadj \
        --stapm-limit=25000 --fast-limit=30000 --slow-limit=25000 --tctl-temp=90 \
        2>/dev/null || true
    fi
  '';
in
{
  powerManagement.powertop.enable = true;
  systemd.services.powertop.wantedBy = lib.mkForce [ ];
  systemd.services.powertop-bg = {
    description = "Apply powertop auto-tune (non-blocking)";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.powertop}/bin/powertop --auto-tune &'";
    };
  };

  security.pam.services.passwd.text = ''
    auth [success=1 default=ignore] pam_fprintd.so
    auth [success=ok default=die] pam_unix.so try_first_pass
    account required pam_unix.so
    password sufficient pam_unix.so nullok yescrypt
    session required pam_env.so conffile=/etc/pam/environment readenv=0
    session required pam_unix.so
    session required pam_limits.so conf=${pkgs.pam}/etc/security/limits.conf
  '';

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
    };

    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
          energy_performance_bias = "powersave";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
          energy_performance_bias = "performance";
        };
      };
    };

    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };

    fstrim.enable = true;
    fprintd.enable = true;
    fwupd.enable = true;
    gpm.enable = true;
    lact.enable = true;
    ollama.enable = true;
    openssh.enable = true;

    syncthing = {
      enable = true;
      user = "zeph";
      dataDir = "/home/zeph/Sync";
      configDir = "/home/zeph/.config/syncthing";
    };

    power-profiles-daemon.enable = false;
    printing.enable = true;

    # NixOS-specific prefixes tell it to treat the immutable /nix/store as the live files
    # (only pruned GC paths are dropped).
    preload-ng = {
      enable = true;
      settings = {
        mapPrefix = "/nix/store/;/run/current-system/;!/";
        exePrefix = "/nix/store/;/run/current-system/;!/";
      };
    };

    resolved.enable = true;

    tlp = {
      enable = false;
      settings = {
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_BOOST_ON_BAT = 0;
        CPU_BOOST_ON_AC = 1;
        WIFI_PWR_ON_BAT = "on";
        RUNTIME_PM_ON_BAT = "auto";
        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth wifi wwan";
        DEVICES_TO_ENABLE_ON_AC = "bluetooth wifi wwan";
      };
    };

    udev.extraRules = ''
      SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="ec:91:61:47:2d:13", NAME="wlan0"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1ea7", ATTR{idProduct}=="0066", ATTR{power/control}="on"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{authorized}=="1", ATTR{power/autosuspend}="1", ATTR{power/control}="auto"
      ACTION=="change", KERNEL=="ACAD", SUBSYSTEM=="power_supply", RUN+="${applyAcPower}"
    '';

    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  networking.networkmanager.wifi.powersave = true;

  # Modes: 0=silent 1=standard 2=dust-cleaning 4=max cooling (not persisted by firmware).
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

  # Powers off BT on battery when nothing is connected; re-enables on AC.
  systemd.services.bluetooth-ac-power = {
    description = "Disable Bluetooth on battery when idle, enable on AC";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '
        BTCTL="${pkgs.bluez}/bin/bluetoothctl"
        while true; do
          ONLINE="$(cat /sys/class/power_supply/ACAD/online 2>/dev/null || echo 0)"
          if [ "$ONLINE" = "1" ]; then
            "$BTCTL" power on 2>/dev/null || true
          elif [ -z "$("$BTCTL" devices Connected 2>/dev/null)" ]; then
            "$BTCTL" power off 2>/dev/null || true
          fi
          sleep 120
        done
        '
      '';
    };
  };

  systemd.services.NetworkManager-wait-online.enable = false;
}
