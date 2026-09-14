{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/widget-toggle.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Toggle a desktop widget: close if running, launch if not.
      # The widget opens in a fullscreen transparent-background terminal
      # rendered as a live wallpaper via hyprwinwrap.
      # Usage: widget-toggle.sh <class> [COMMAND...]
      set -euo pipefail

      STATE_FILE="''${XDG_CONFIG_HOME:-$HOME/.config}/hypr/.default-terminal"
      DEFAULT_TERMINAL="$(cat "$STATE_FILE" 2>/dev/null || echo ghostty)"

      CLASS="$1"
      shift

      # --- Toggle off: close existing window by class ---
      if hyprctl clients -j 2>/dev/null \
        | jq -e --arg c "$CLASS" '.[] | select(.class == $c)' >/dev/null 2>&1; then
        ADDR="$(hyprctl clients -j \
          | jq -r --arg c "$CLASS" '[.[] | select(.class == $c)][0].address' 2>/dev/null)"
        if [[ -n "$ADDR" && "$ADDR" != "null" ]]; then
          hyprctl dispatch closewindow "$ADDR" >/dev/null 2>&1 || true
        fi
        exit 0
      fi

      # --- Toggle on: launch in default terminal with transparent bg ---
      case "$DEFAULT_TERMINAL" in
        alacritty)
          alacritty --class "$CLASS" \
            -o 'colors.primary.background="#00000000"' \
            -e "$@"
          ;;
        kitty)
          kitty --class "$CLASS" -o background_opacity=0.0 "$@"
          ;;
        wezterm)
          wezterm start --always-new-process --class "$CLASS" \
            --config window_background_opacity=0.0 \
            -- sh -c '"$@"; exec "''${SHELL:-sh}"' sh "$@"
          ;;
        *)
          ghostty --class="$CLASS" --background-opacity=0.0 -e "$@"
          ;;
      esac
    '';
  };
}
