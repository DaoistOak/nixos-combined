{
   config,
   pkgs,
   lib,
   inputs,
   ...
}:
let
# Guard: ignore failures when ryzen_smu is missing or /dev/mem is restricted.
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

  # Active theme selection (single source of truth, same as sddm/themer).
  themeMod = import ../../../home/config/themes/colors/themes.nix { inherit lib; };
  themeSel = themeMod.readSelection ../../../home/config/themes/colors/src/selection;

  # NixOS snowflake plymouth theme, recolored to match the theme-changer
  # accent. The "white" variant ships transparent-bg PNG frames of the wordmark
  # + lambda arms; -colorize swaps white → accent while keeping the anti-aliased
  # luminance ramp (and the theme's own dark gradient background).
  nixosLoadingTheme = pkgs.runCommand "plymouth-nixos-loading-${themeSel.r.accent}" { } ''
    themeDir="$out/share/plymouth/themes/nixos-loading-white"
    mkdir -p "$themeDir"
    cp -r ${inputs.nixos-loading-plymouth.packages.${pkgs.stdenv.hostPlatform.system}.nixos-loading-white}/share/plymouth/themes/nixos-loading-white/* "$themeDir/"
    for f in "$themeDir"/frame-*.png; do
      chmod u+w "$f"
      ${pkgs.imagemagick}/bin/magick "$f" -fill '#${themeSel.r.accent}' -colorize 100 "$f"
    done
  '';
in
{
  imports = [ ./hardware-configuration.nix ];

  # Do not power on bluetooth adapter at boot; user toggles it manually via keybind.
  hardware.bluetooth.powerOnBoot = false;

  # Single owner of boot.kernelParams (mkForce): previously this module and
  # boot/default.nix both mkForced it, so they *merged* rather than overriding,
  # silently dropping hw-config params (amd_pstate, amdgpu.dpm, kvm.ignore_msrs,
  # nvme latency, etc.) from the actual cmdline. Restored here EXPLICITLY to the
  # set that has been verified to boot (the old union) + kvm.ignore_msrs=1.
  #
  # NOTE: amd_pstate=active was tried and caused an early-boot hang (no journal
  # got written) — this IdeaPad never had it applied before. Leave it out.
  #
  # Fix GPU soft lockups: enable runtime PM, disable recovery loop, disable unsafe MMIO
  # The previous config had runpm=0 (GPU never sleeps) and gpu_recovery=1 (lockup→recovery→lockup loop)
  # which caused progressive soft lockups escalating 26s→48s→74s→82s until system freeze.
  boot.kernelParams = lib.mkForce [
    "quiet"
    "splash"
    "rd.systemd.show_status=auto"
    "amdgpu.runpm=1"
    "amdgpu.gpu_recovery=0"
    "amdgpu.dcdebugmask=0"
    "kvm.ignore_msrs=1"
    "kvm.allow_unsafe_mmio_access=0"
    "zswap.enabled=0"
    "amdgpu.sg_display=0"
  ];

  # Plymouth boot splash (enabled in hardware-configuration.nix). NixOS
  # snowflake/wordmark theme recolored to the theme-changer accent.
  boot.plymouth = {
    theme = "nixos-loading-white";
    themePackages = [ nixosLoadingTheme ];
  };
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;

  # Lenovo IdeaPad Slim 5 hardware tweaks
  #
  # Set EC fan_mode to Efficient Thermal Dissipation (4). Modes: 0=silent
  # 1=standard 2=dust-cleaning 4=max cooling. Not persisted by firmware.
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

  # AC/battery power limit management via ryzenadj.
  # Runtime AC plug/unplug is handled by the udev rule below; this service
  # applies the initial state at boot.
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

  # USB device-specific power management + MAC-based interface naming.
  # The AC change trigger (last rule) calls apply-ac-power from the service above.
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="ec:91:61:47:2d:13", NAME="wlan0"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1ea7", ATTR{idProduct}=="0066", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{authorized}=="1", ATTR{power/autosuspend}="1", ATTR{power/control}="auto"
    ACTION=="change", KERNEL=="ACAD", SUBSYSTEM=="power_supply", RUN+="${applyAcPower}"
  '';
}
