{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/submap-timeout.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # submap-timeout.sh - delayed default action for Hyprland submaps.
      #
      # Usage:
      #   submap-timeout.sh <tag> <seconds> <action...>
      #   submap-timeout.sh cancel <tag>
      #
      # <tag> is a unique id per submap entry. The entry key should call this
      # with an action AND then enter the target submap (e.g. via
      # `&& hyprctl dispatch submap <name>`). Any binding inside the submap
      # should `submap-timeout.sh cancel <tag>` first so the delayed default
      # action is suppressed. On timeout the submap is reset and <action>
      # is launched.
      set -euo pipefail

      pid_dir="/tmp/hypr-submap-timeout"
      mkdir -p "$pid_dir"

      cmd="$1"

      if [[ "$cmd" == "cancel" ]]; then
        tag="$2"
pidfile="$pid_dir/''${tag}.pid"
        if [[ -f "$pidfile" ]]; then
          kill "$(cat "$pidfile")" 2>/dev/null || true
          rm -f "$pidfile"
        fi
        exit 0
      fi

      tag="$1"
      seconds="$2"
      shift 2

      pidfile="$pid_dir/''${tag}.pid"

      # Cancel any previous pending timer for this tag
      if [[ -f "$pidfile" ]]; then
        kill "$(cat "$pidfile")" 2>/dev/null || true
      fi

      (
        sleep "$seconds"
        if [[ -f "$pidfile" ]]; then
          rm -f "$pidfile"
          hyprctl dispatch submap reset >/dev/null 2>&1 || true
          "$@" >/dev/null 2>&1 &
        fi
      ) &
      echo $! > "$pidfile"
    '';
  };
}