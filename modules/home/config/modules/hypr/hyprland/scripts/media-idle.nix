{ config, pkgs, ... }:

let
  mediaIdleScript = ''
    #!/usr/bin/env bash

    # hypridle condition_cmd: media-aware idle suppression.
    # Exit 0 -> no media playing, allow the on-timeout to fire (idle normally).
    # Exit 1 -> a media player is actively playing, defer the on-timeout
    #           (no dim / lock / screen-off / hibernate while watching).

    if ! command -v playerctl &>/dev/null; then
      # playerctl missing: never block idle as a safety default.
      exit 0
    fi

    if playerctl --no-messages -a status 2>/dev/null | grep -q "Playing"; then
      exit 1
    fi

    exit 0
  '';
in
{
  home.file.".config/hypr/scripts/media-idle-check.sh" = {
    text = mediaIdleScript;
    executable = true;
  };
}
