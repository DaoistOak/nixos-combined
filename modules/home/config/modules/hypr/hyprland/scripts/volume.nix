{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/volume.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Volume control via wpctl. Unlike Noctalia's built-in volume commands
      # (capped at 100%), wpctl allows overamplification up to 150%. Shows the
      # Noctalia OSD afterwards so the popup still reflects the new level.
      set -euo pipefail

      SINK="@DEFAULT_AUDIO_SINK@"

      case "''${1:-}" in
        up)   wpctl set-volume "$SINK" 5%+ ;;
        down) wpctl set-volume "$SINK" 5%- ;;
        mute) wpctl set-mute "$SINK" toggle ;;
        *)    echo "usage: volume.sh {up|down|mute}" >&2; exit 1 ;;
      esac

      noctalia msg volume-osd
    '';
  };
}