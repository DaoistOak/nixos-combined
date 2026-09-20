{
  config,
  pkgs,
  lib,
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
in
{
  imports = [ ./hardware-configuration.nix ];

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
