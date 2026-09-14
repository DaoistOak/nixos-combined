{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/border-angle.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # border-angle.sh — rotate the active window's gradient border so it
      # points at the cursor (end-4's dots style). Background daemon launched
      # from hyprland.start; it lives for the whole session.
      #
      # The active border is a 2-colour gradient (theme secondary -> primary)
      # written to ~/.config/theme-switcher/hyprland-theme.lua by scripts/theme
      # and applied by colors.nix. While the cursor moves we poll it at ~20 Hz,
      # normalise its offset to the focused window's half-size (so the angle
      # reflects the cursor's position *within* the active window rather than
      # absolute screen pixels) and push a new gradient angle via hl.config.
      # The existing `border` fade animation eases each small change, so the
      # border rotates smoothly instead of snapping.
      #
      # The built-in `borderangle` animation is intentionally NOT used: with
      # `loop` the gradient never stops spinning even when the cursor is idle,
      # and `once` adds a full turn on every push — both fight the cursor
      # tracking. Using hl.config for the partial `general.col` update keeps the
      # inactive border and every other general option untouched.
      set -euo pipefail

      POLL_MOVE=0.05   # seconds between polls while the cursor moves (~20 Hz)
      POLL_IDLE=0.5    # seconds between polls while the cursor is still
      EPS=4            # push only when the angle changed by more than EPS degrees
      GEOM_EVERY=4     # re-read focused-window geometry every N move-polls (~0.2 s)

      THEME_FILE="''${XDG_CONFIG_HOME:-$HOME/.config}/theme-switcher/hyprland-theme.lua"

      HYPRCTL=hyprctl
      JQ='${pkgs.jq}/bin/jq'
      AWK='${pkgs.gawk}/bin/awk'

      # Read the primary/secondary gradient colors from the theme lua file.
      # Falls back to the catppuccin macchiato teal->blue pair if unreadable.
      read_gradient() {
        local c1 c2 sc
        c1=$(grep -oE 'c1 *= *"0x[0-9a-fA-F]{6}"' "$THEME_FILE" 2>/dev/null | head -n1 | grep -oE '0x[0-9a-fA-F]{6}' || true)
        c2=$(grep -oE 'c2 *= *"0x[0-9a-fA-F]{6}"' "$THEME_FILE" 2>/dev/null | head -n1 | grep -oE '0x[0-9a-fA-F]{6}' || true)
        # Old scalar format { active_border = "0x..." }: use it for both ends.
        if [[ -z "$c1" || -z "$c2" ]]; then
          sc=$(grep -oE 'active_border *= *"0x[0-9a-fA-F]{6}"' "$THEME_FILE" 2>/dev/null | head -n1 | grep -oE '0x[0-9a-fA-F]{6}' || true)
          c1=''${c1:-$sc}
          c2=''${c2:-$sc}
        fi
        c1=''${c1:-8bd5ca}
        c2=''${c2:-8aadf4}
        GRAD_C1="rgb(''${c1#0x})"
        GRAD_C2="rgb(''${c2#0x})"
      }

      # Refresh the focused window's geometry. NONE=1 when nothing is focused.
      read_geometry() {
        local aw
        aw=$("$HYPRCTL" activewindow -j 2>/dev/null || echo '{}')
        NONE=1
        if "$JQ" -e '.at and .size' >/dev/null 2>&1 <<<"$aw"; then
          read -r WX WY WW WH < <("$JQ" -r '[.at[0], .at[1], .size[0], .size[1]] | @tsv' <<<"$aw" 2>/dev/null || echo '0 0 0 0')
          NONE=0
        fi
      }

      WX=0; WY=0; WW=0; WH=0; NONE=1
      last_x=-1; last_y=-1; pushed=-1; polls=0
      GRAD_C1="rgb(8bd5ca)"; GRAD_C2="rgb(8aadf4)"

      while :; do
        pos=$("$HYPRCTL" cursorpos -j 2>/dev/null || echo '{"x":-1,"y":-1}')
        read -r cx cy < <("$JQ" -r '[.x, .y] | @tsv' <<<"$pos" 2>/dev/null || echo '-1 -1')

        if [[ "$cx" != "$last_x" || "$cy" != "$last_y" ]]; then
          last_x=$cx; last_y=$cy
          polls=$((polls + 1))
          if (( polls % GEOM_EVERY == 0 )); then
            read_geometry
          fi

          if (( NONE == 0 )); then
            angle=$("$AWK" -v cx="$cx" -v cy="$cy" -v wx="$WX" -v wy="$WY" -v ww="$WW" -v wh="$WH" 'BEGIN {
              # Normalise the cursor offset to the active window half-size so
              # the angle depends on where the cursor sits *inside* the window
              # (aspect-correct, 45 deg at the corners) rather than on absolute
              # screen pixels.
              hx = (ww > 0) ? ww / 2 : 1
              hy = (wh > 0) ? wh / 2 : 1
              ux = (cx - (wx + hx)) / hx
              uy = (cy - (wy + hy)) / hy
              a = (ux == 0 && uy == 0) ? 0 : atan2(uy, ux) * 57.29577951308232
              a = a - int(a / 360) * 360
              if (a < 0) a += 360
              printf "%d", int(a + 0.5)
            }')
            # Rotate the diff into [-180, 180) so angular wrap doesn't spam pushes.
            diff=$((angle - pushed))
            if (( diff < -180 )); then diff=$((diff + 360)); fi
            if (( diff > 180 )); then diff=$((diff - 360)); fi
            adiff=$((diff < 0 ? -diff : diff))
            if (( pushed < 0 || adiff > EPS )); then
              read_gradient
              "$HYPRCTL" eval "hl.config({ general = { col = { active_border = { colors = { \"$GRAD_C1\", \"$GRAD_C2\" }, angle = $angle } } } })" >/dev/null 2>&1 || true
              pushed=$angle
            fi
          else
            pushed=-1
          fi
          sleep "$POLL_MOVE"
        else
          polls=0
          sleep "$POLL_IDLE"
        fi
      done
    '';
  };
}
