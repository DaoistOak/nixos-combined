{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/mic-mute.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Toggle the default microphone mute + avizo OSD.
      set -euo pipefail

      SOURCE="@DEFAULT_AUDIO_SOURCE@"

      wpctl set-mute "$SOURCE" toggle

      set -- $(wpctl get-volume "$SOURCE")
      if [ -n "''${3:-}" ]; then
        res=mic_muted
      else
        res=mic_unmuted
      fi

      avizo-client --image-resource "$res" --progress 0
    '';
  };
}