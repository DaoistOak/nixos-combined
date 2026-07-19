# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./pkgs-config.nix
    ./services.nix
    ./users.nix
    ./gui.nix
  ];

  # Hibernation settings
  boot = {
    resumeDevice = "/dev/disk/by-uuid/c90cb3d2-feba-424e-a25b-146d24f9bd0d";
    kernelParams = [ "resume=UUID=c90cb3d2-feba-424e-a25b-146d24f9bd0d" ];
    kernelModules = [ "ryzen_smu" ];
  };

  # Enable hibernation
  services.logind = {
    settings.Login = {
      HandlePowerKey = "hibernate";
      HandlePowerKeyLongPress = "poweroff";
      HandleLidSwitch = "suspend-then-hibernate";
    };
  };
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30m";
  };

  # System settings
  powerManagement.cpuFreqGovernor = "schedutil";

  system.stateVersion = "25.11";

  # Nix Settings
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = "auto";
      min-free = 3221225472;
      max-free = 6442450944;
    };
  };

  # Networking settings
  networking = {
    hostName = "Overlord";
    networkmanager = {
      enable = true;
    };
    nftables = {
      enable = true;
    };
    firewall = {
      enable = true;
      trustedInterfaces = [
        "virbr0"
        "virbr1"
      ];
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
    };
  };
  # Localization settings
  time.timeZone = "Asia/Kathmandu";
  i18n.defaultLocale = "en_US.UTF-8";
  # Virtualization
  virtualisation = {
    docker.enable = true;
    podman.enable = true;
    waydroid.enable = true;
    libvirtd = {
      enable = true;
      extraConfig = ''
        virtiofsd_path = "${pkgs.qemu}/bin/virtiofsd"
      '';
    };
  };
  systemd.services.libvirtd.postStart = ''
    ${pkgs.libvirt}/bin/virsh net-start default 2>/dev/null || true
    ${pkgs.libvirt}/bin/virsh net-autostart default 2>/dev/null || true
  '';
  systemd.services.virtqemud.postStart = ''
    ${pkgs.libvirt}/bin/virsh net-start default 2>/dev/null || true
    ${pkgs.libvirt}/bin/virsh net-autostart default 2>/dev/null || true
  '';
  systemd.services."drkonqi-coredump-processor@".enable = false;
  programs.xwayland.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries =
      with pkgs;
      [
        libtheora
        speex
        libgudev
        libvdpau
      ]
      ++ (with pkgs.pkgsi686Linux; [
        libtheora
        speex
        libgudev
        libvdpau
      ]);
  };
  # Console settings
  # /run/current-system/sw/share/consolefonts/ter-u16n.psfu.gz
  console.font = "/run/current-system/sw/share/consolefonts/ter-u18n.psf.gz";

  # Stylix theming
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    image = null;
    targets.console.enable = true;
    targets.plymouth.enable = true;
  };

  nixpkgs.config = {
    allowAliases = false;
    permittedInsecurePackages = [
      "electron-40.10.5"
      "pnpm-10.29.2"
    ];
  };

  environment.systemPackages = with pkgs; [
    base16-schemes
  ];

}
