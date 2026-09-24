{
  config,
  pkgs,
  lib,
  ...
}:
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

    flatpak.enable = true;
    fstrim.enable = true;
    fprintd.enable = true;
    fwupd.enable = true;
    gpm.enable = true;
    gvfs.enable = true;
    lact.enable = true;
    ollama.enable = true;
    openssh.enable = true;

    syncthing = {
      enable = true;
      user = config.var.username;
      dataDir = "/home/${config.var.username}/Sync";
      configDir = "/home/${config.var.username}/.config/syncthing";
    };

    power-profiles-daemon.enable = false;
    printing.enable = true;
    upower.enable = true;

    # NixOS-specific prefixes: treat /nix/store as live files (only pruned
    # GC paths are dropped).
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
        DEVICES_TO_ENABLE_ON_AC = "wifi wwan";
      };
    };

    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  networking.networkmanager.wifi.powersave = true;

  systemd.services.NetworkManager-wait-online.enable = false;
}
