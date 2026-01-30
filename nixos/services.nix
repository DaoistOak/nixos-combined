{
  config,
  pkgs,
  lib,
  ...
}:

{
  powerManagement.powertop.enable = true;

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
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };

    # 🖐️ Fingerprint reader
    fprintd.enable = true;

    # 🔧 Firmware updater
    fwupd.enable = true;

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
    # 🔌 Power Profiles (disabled)
    power-profiles-daemon.enable = false;

    # 🖨️ Printing (CUPS)
    printing.enable = true;

    resolved.enable = true;

    # 🗝️ TLP tuning
    tlp = {
      enable = true;
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
    '';

    # 🎛️ Other services...
    #    xserver.videoDrivers = [ "amdgpu" ];
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  systemd.services.NetworkManager-wait-online.enable = true;
}
