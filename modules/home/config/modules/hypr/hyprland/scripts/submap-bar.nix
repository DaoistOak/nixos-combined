{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/submap-bar.sh" = {
    executable = true;
    text = ''
            #!/usr/bin/env bash
            # Show the noctalia "Keymap" overlay bar while a Hyprland submap is
            # active, hide it again when we return to the default submap. Listens on
            # Hyprland's socket2 event stream for "submap>>" events.
            set -euo pipefail

            uid="$(id -u)"
            instance="''${HYPRLAND_INSTANCE_SIGNATURE:-}"
            if [[ -z "$instance" ]]; then
              # Fallback for manual runs outside a Hyprland-spawned session.
              instance="$(timeout 5 hyprctl instances -j 2>/dev/null | jq -r '.[0].instance // empty' 2>/dev/null || true)"
            fi
            sock="/run/user/''${uid}/hypr/''${instance}/.socket2.sock"

            # Retry helper: noctalia may still be starting up alongside this script.
            send() {
              local verb="$1" i
              for i in $(seq 1 20); do
                if noctalia msg "bar-$verb" Keymap >/dev/null 2>&1; then
                  return 0
                fi
                sleep 0.25
              done
            }

            # Mirror the current submap on start so the bar is already in the right
            # state even if the socket events were missed.
            current="$(timeout 5 hyprctl submap 2>/dev/null || true)"
            current="$(printf '%s' "$current" | tr -d '\r\n')"

            if [[ -z "$current" || "$current" == "default" || "$current" == "global" ]]; then
              send hide
              last="default"
            else
              send show
              last="submap"
            fi

            while true; do
              if [[ ! -S "$sock" ]]; then
                sleep 2
                continue
              fi
      socat -u "UNIX-CONNECT:$sock" - 2>/dev/null | while IFS= read -r event; do
                case "$event" in
                  submap\>\>*)
                    name="''${event#submap>>}"
                    if [[ -z "$name" || "$name" == "default" || "$name" == "global" ]]; then
                      if [[ "$last" != "default" ]]; then
                        send hide
                        last="default"
                      fi
                    else
                      if [[ "$last" != "submap" ]]; then
                        send show
                        last="submap"
                      fi
                    fi
                    ;;
                esac
              done || true
              sleep 1
            done
    '';
  };
}
