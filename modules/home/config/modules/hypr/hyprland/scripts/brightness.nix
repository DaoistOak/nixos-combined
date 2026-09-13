{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/brightness.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Brightness control via brightnessctl + avizo OSD.
      set -euo pipefail

      case "''${1:-}" in
        up)   brightnessctl set 5%+ ;;
        down) brightnessctl set 5%- ;;
        *)    echo "usage: brightness.sh {up|down}" >&2; exit 1 ;;
      esac

      progress=$(awk -v g="$(brightnessctl get)" -v m="$(brightnessctl max)" \
        'BEGIN { if (m <= 0) m = 1; v = g / m; if (v > 1) v = 1; printf "%.2f", v }')
      if awk -v v="$progress" 'BEGIN { exit !(v < 0.35) }'; then
        res=brightness_low
      elif awk -v v="$progress" 'BEGIN { exit !(v < 0.70) }'; then
        res=brightness_medium
      else
        res=brightness_high
      fi

      avizo-client --image-resource "$res" --progress "$progress"
    '';
  };
}