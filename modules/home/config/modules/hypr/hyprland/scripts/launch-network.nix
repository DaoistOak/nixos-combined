{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/launch-network.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Network helper: open | close (wifi radio toggle).
      set -euo pipefail

      case "''${1:-}" in
        open)
          nmcli radio wifi on
          ${pkgs.libnotify}/bin/notify-send "Network" "wifi on"
          ;;
        close)
          nmcli radio wifi off
          ${pkgs.libnotify}/bin/notify-send "Network" "wifi off"
          ;;
        *)
          echo "usage: launch-network.sh {open|close}" >&2
          exit 1
          ;;
      esac
    '';
  };
}
