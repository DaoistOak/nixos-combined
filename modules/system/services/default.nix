{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Conservative ryzenadj power limits on battery (24W STAPM), full limits on AC.
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

    # 🌐 Avahi (local network discovery)
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
    };

    # 🧠 Auto CPU freq
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

    # 🧹 Btrfs monthly scrub
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };

    # 💾 SSD TRIM (weekly), keeps bloated Btrfs/SSD cells fresh
    fstrim.enable = true;

    # 🖐️ Fingerprint reader
    fprintd.enable = true;

    # 🔧 Firmware updater
    fwupd.enable = true;

    # 🖱️ General Purpose Mouse: mouse cursor in the TTY console
    gpm.enable = true;

    # 🖥️ Lact (AMD GPU tuning)
    lact = {
      enable = true;
    };

    # ✔️ Ollama Service
    ollama = {
      enable = true;
    };
    # openssh
    openssh.enable = true;

    # 🔄 Syncthing (file sync daemon)
    syncthing = {
      enable = true;
      user = "Daoist-Oak";
      dataDir = "/home/Daoist-Oak/Sync";
      configDir = "/home/Daoist-Oak/.config/syncthing";
    };

    # 🔌 Power Profiles (disabled)
    power-profiles-daemon.enable = false;

    # 🖨️ Printing (CUPS)
    printing.enable = true;

    # ⚡ preload-ng: tracks frequently-used binaries/libraries and prefetches
    # them into RAM at idle for faster cold starts. NixOS-specific prefixes:
    # map/exePrefix tell it to treat the immutable /nix/store as the live files
    # (only pruned GC paths are dropped). Conservative memory/minsize cycle so it
    # doesn't starve the zram/hibernation image reserve on this 13GiB box.
    preload-ng = {
      enable = true;
      settings = {
        mapPrefix = "/nix/store/;/run/current-system/;!/";
        exePrefix = "/nix/store/;/run/current-system/;!/";
      };
    };

    resolved.enable = true;

    # 🗝️ TLP tuning
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

    # 🧩 Custom udev rules
    udev.extraRules = ''
      SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="ec:91:61:47:2d:13", NAME="wlan0"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1ea7", ATTR{idProduct}=="0066", ATTR{power/control}="on"

      # ⚡ USB autosuspend for the rest of the bus
      ACTION=="add", SUBSYSTEM=="usb", ATTR{authorized}=="1", ATTR{power/autosuspend}="1", ATTR{power/control}="auto"

      # 🔌 Re-apply power limits when the power supply state changes
      ACTION=="change", KERNEL=="ACAD", SUBSYSTEM=="power_supply", RUN+="${applyAcPower}"
    '';

    # 🎛️ Other services...
    #    xserver.videoDrivers = [ "amdgpu" ];
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  # 📶 Allow WiFi NIC to enter low-power states
  networking.networkmanager.wifi.powersave = true;

  # 🌀 IdeaPad fan: force "Efficient Thermal Dissipation" EC profile on boot.
  # Not persisted by firmware; modes: 0=silent 1=standard 2=dust-cleaning 4=max cooling.
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

  # ⚡ Apply AC/battery power limits once at boot; react to AC changes via udev.
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

  # 🔵 Bluetooth: keep it on when a device is connected; on battery with nothing
  # paired/connected, power the controller off. Comes back on when on AC.
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
