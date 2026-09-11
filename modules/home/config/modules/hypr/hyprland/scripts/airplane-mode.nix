{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/airplane-mode.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Toggle airplane mode: cut all radios (wifi + bluetooth) or restore them.
      set -euo pipefail

      wifi_enabled="$(nmcli radio wifi 2>/dev/null || echo missing)"
      bt_powered="$(bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2}' || echo no)"

      if [[ "$wifi_enabled" == enabled || "$bt_powered" == yes ]]; then
        nmcli radio wifi off
        bluetoothctl power off
        ${pkgs.libnotify}/bin/notify-send "Airplane mode" "on"
      else
        nmcli radio wifi on
        bluetoothctl power on
        ${pkgs.libnotify}/bin/notify-send "Airplane mode" "off"
      fi
    '';
  };
}
