{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/launch-bluetooth.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Bluetooth helper: open | close | auto.
      #   open  — power the adapter on
      #   close — power the adapter off
      #   auto  — power on and try connecting the first paired device, else off
      set -euo pipefail

      notify() { ${pkgs.libnotify}/bin/notify-send "Bluetooth" "$1"; }

      case "''${1:-}" in
        open)
          bluetoothctl power on
          notify "adapter on"
          ;;
        close)
          bluetoothctl power off
          notify "adapter off"
          ;;
        auto)
          bluetoothctl power on >/dev/null 2>&1 || true
          dev="$(bluetoothctl devices Paired | head -n1 | awk '{print $2}')"
          if [[ -z "$dev" ]]; then
            bluetoothctl power off
            notify "no paired device — adapter off"
            exit 0
          fi
          if timeout 20 bluetoothctl connect "$dev" 2>/dev/null | grep -qi successful; then
            notify "connected"
          else
            bluetoothctl power off >/dev/null 2>&1 || true
            notify "connection failed — adapter off"
          fi
          ;;
        *)
          echo "usage: launch-bluetooth.sh {open|close|auto}" >&2
          exit 1
          ;;
      esac
    '';
  };
}
