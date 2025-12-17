
{ config, pkgs, ... }:

let
  hyprlockScript = ''
    #!/usr/bin/env bash

    # ensure /tmp/hyprlock exists
    mkdir -p /tmp/hyprlock

    # grab a screenshot, lock, then kill duplicate locks
    grim /tmp/hyprlock/screenshot.png
    killall hyprlock
    hyprlock &
  '';
in {
  home.file.".config/hypr/scripts/hyprlock.sh" = {
    text       = hyprlockScript;
    executable = true;
  };
}


