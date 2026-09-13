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
      # Volume control via wpctl + avizo OSD. Unlike Noctalia's built-in volume
      # commands (capped at 100%), wpctl allows over-amplification up to 150%;
      # avizo shows the resulting level with a themed icon and progress bar.
      set -euo pipefail

      SINK="@DEFAULT_AUDIO_SINK@"

      case "''${1:-}" in
        up)   wpctl set-volume "$SINK" 5%+ ;;
        down) wpctl set-volume "$SINK" 5%- ;;
        mute) wpctl set-mute "$SINK" toggle ;;
        *)    echo "usage: volume.sh {up|down|mute}" >&2; exit 1 ;;
      esac

      # wpctl get-volume prints: "Volume: 0.35" or "Volume: 0.35 [MUTED]"
      set -- $(wpctl get-volume "$SINK")
      vol="''${2:-0.0}"
      muted="''${3:-}"

      # avizo progress is 0..1; clamp the (possible >1) over-amplified level.
      progress=$(awk -v v="$vol" 'BEGIN { if (v > 1) v = 1; printf "%.2f", v }')
      if [ -n "$muted" ]; then
        res=volume_muted
      elif awk -v v="$vol" 'BEGIN { exit !(v < 0.35) }'; then
        res=volume_low
      elif awk -v v="$vol" 'BEGIN { exit !(v < 0.70) }'; then
        res=volume_medium
      else
        res=volume_high
      fi

      avizo-client --image-resource "''${res}_dark" --progress "$progress"
    '';
  };
}