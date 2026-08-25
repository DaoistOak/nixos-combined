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

let
  # Recursively collect all files under a directory as { "rel/path" = <path>; }
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

  # Windows boot files (bootmgfw.efi + BCD etc.) staged for the NixOS ESP,
  # so systemd-boot can chainload the Windows Boot Manager (dual-boot).
  winBootDir = ./efi/windows/Boot;
  winExtraFiles = lib.mapAttrs' (k: v: {
    name = "EFI/Microsoft" + (lib.removePrefix "." k);
    value = v;
  }) (collectFiles "." winBootDir);
in
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

    loader.systemd-boot = {
      extraFiles = winExtraFiles;
      extraEntries."windows.conf" = ''
        title Windows
        efi /EFI/Microsoft/bootmgfw.efi
        sort-key z_windows
      '';
    };
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

  system.stateVersion = "26.05";

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
      substituters = [
        "https://hyprland.cachix.org"
        "https://noctalia.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspc1gZ5Q="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
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
  # Use the stock xwayland build so it comes from the binary cache instead of
  # compiling locally (NixOS otherwise injects default_font_path, changing the
  # hash away from cache.nixos.org's build).
  programs.xwayland.package = pkgs.xwayland;
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
    # Stylix's gtksourceview override changes the package hash, forcing
    # gtksourceview, inkscape, virt-manager and catppuccin-cursors to compile
    # locally on every nixpkgs bump. No gtksourceview-based editor is used.
    targets.gtksourceview.enable = false;
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
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
