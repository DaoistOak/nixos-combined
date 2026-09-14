{
  config,
  ...
}:
{
  xdg.configFile."hypr/scripts/border-rotate.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # border-rotate.sh — control the border-angle daemon (on/off/toggle).
      #
      # `Super + S, G` runs performance-mode.sh, which calls `border-rotate.sh
      # off` when performance mode turns on and `on` when it turns off, so the
      # cursor-tracking border rotation is disabled together with the other
      # eye-candy. The daemon is tracked by PID so restarts never double-spawn.
      set -euo pipefail

      DAEMON="${config.xdg.configHome}/hypr/scripts/border-angle.sh"
      PIDFILE="${config.xdg.cacheHome}/hypr/border-rotate.pid"

      is_running() {
        [ -f "$PIDFILE" ] || return 1
        local pid
        pid=$(cat "$PIDFILE" 2>/dev/null) || return 1
        [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
      }

      start() {
        mkdir -p "$(dirname "$PIDFILE")"
        is_running && return 0
        nohup "$DAEMON" >/dev/null 2>&1 &
        echo $! > "$PIDFILE"
      }

      stop() {
        if [ -f "$PIDFILE" ]; then
          kill "$(cat "$PIDFILE")" 2>/dev/null || true
          rm -f "$PIDFILE"
        fi
        # Belt and suspenders: also catch a daemon started outside this helper.
        pkill -f 'hypr/scripts/border-angle\.sh$' >/dev/null 2>&1 || true
      }

      case "''${1:-toggle}" in
        on | start) start ;;
        off | stop) stop ;;
        toggle)
          if is_running; then stop; else start; fi
          ;;
        *)
          echo "usage: $0 on|off|toggle" >&2
          exit 2
          ;;
      esac
    '';
  };
}
