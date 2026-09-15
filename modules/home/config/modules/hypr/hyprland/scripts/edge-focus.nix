{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/edge-focus.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # edge-focus.sh — hover the left/right edge of the active scrolling-layout
      # column to step focus to the neighbouring column. Holding the cursor in
      # the edge strip repeats the step every REPEAT_MS. Columns are stepped one
      # at a time: at the tape ends nothing happens (no wrap, so it never jumps
      # to the far-left / far-right window). Background daemon launched from
      # hyprland.start; it lives for the whole session.
      set -euo pipefail

      POLL=0.12            # main poll interval (seconds)
      REPEAT_MS=2000       # focus-step cadence while the cursor stays in the zone
      EDGE_PCT=15          # edge strip = % of the active window's width
      EDGE_MIN=30          #   ...but at least EDGE_MIN px
      EDGE_MAX=150         #   ...and at most EDGE_MAX px
      LAYOUT_CHECK_EVERY=40  # re-check general:layout every N polls (~5 s)

      HYPRCTL=hyprctl
      JQ='${pkgs.jq}/bin/jq'

      # Read the active window's geometry + workspace and the cursor position.
      # NONE=1 when nothing tiled is focused.
      read_active() {
        local aw cp
        aw=$("$HYPRCTL" activewindow -j 2>/dev/null || echo '{}')
        cp=$("$HYPRCTL" cursorpos -j 2>/dev/null || echo '{"x":-99999,"y":-99999}')
        NONE=1
        if "$JQ" -e '.at and .size and .workspace.id' >/dev/null 2>&1 <<<"$aw"; then
          read -r WX WY WW WH WS < <("$JQ" -r '[.at[0], .at[1], .size[0], .size[1], .workspace.id] | @tsv' <<<"$aw" 2>/dev/null || true)
          NONE=0
        fi
        read -r CX CY < <("$JQ" -r '[.x, .y] | @tsv' <<<"$cp" 2>/dev/null || true)
      }

      # 0 when a same-workspace, non-background column exists strictly to the
      # left ("l") or right ("r") of the active window; 1 otherwise.
      has_neighbor() {
        local dir="$1"
        if [[ "$dir" == "l" ]]; then
          "$JQ" -e --argjson wx "$WX" --argjson ws "$WS" '
            [ .[] | select(.workspace.id == $ws)
                | select(("*\(.class // "")*" | test("window-bg|com.widget.metro|com.widget.cava")) | not)
                | select(.at[0] + .size[0] <= $wx + 8) ] | length > 0' \
              <<<"$clients" >/dev/null 2>&1
        else
          "$JQ" -e --argjson wx "$WX" --argjson ww "$WW" --argjson ws "$WS" '
            [ .[] | select(.workspace.id == $ws)
                | select(("*\(.class // "")*" | test("window-bg|com.widget.metro|com.widget.cava")) | not)
                | select(.at[0] >= $wx + $ww - 8) ] | length > 0' \
              <<<"$clients" >/dev/null 2>&1
        fi
      }

      # 0 when the active layout is scrolling, 1 otherwise (e.g. monocle toggle).
      is_scrolling() {
        local cfg
        cfg=$("$HYPRCTL" getoption general:layout -j 2>/dev/null || echo '{}')
        [[ "$("$JQ" -r '.str // empty' <<<"$cfg" 2>/dev/null || true)" == "scrolling" ]]
      }

      WX=0; WY=0; WW=0; WH=0; WS=-1; CX=-99999; CY=-99999; NONE=1
      clients='[]'
      last_fire=0; zone=NONE; layout_ok=0; polls=0

      while :; do
        polls=$((polls + 1))
        if (( polls % LAYOUT_CHECK_EVERY == 0 || polls == 1 )); then
          if is_scrolling; then layout_ok=1; else layout_ok=0; fi
        fi

        if (( layout_ok == 0 )); then
          zone=NONE; last_fire=0
          sleep 1
          continue
        fi

        read_active

        z=NONE
        if (( NONE == 0 && WW > 0 )); then
          if (( CY >= WY && CY <= WY + WH + 8 )); then
            edge=$(( WW * EDGE_PCT / 100 ))
            if (( edge < EDGE_MIN )); then edge=$EDGE_MIN; fi
            if (( edge > EDGE_MAX )); then edge=$EDGE_MAX; fi
            if (( CX <= WX + edge )); then
              z=L
            elif (( CX >= WX + WW - edge )); then
              z=R
            fi
          fi
        fi

        if [[ "$z" == "NONE" ]]; then
          zone=NONE; last_fire=0
          sleep "$POLL"
          continue
        fi

        # Freshly entering a zone fires immediately; staying in it repeats on
        # the REPEAT_MS cadence.
        if [[ "$z" != "$zone" ]]; then
          last_fire=0
        fi
        zone=$z

        now=$(date +%s%3N)
        if (( now - last_fire >= REPEAT_MS )); then
          clients=$("$HYPRCTL" clients -j 2>/dev/null || echo '[]')
          if has_neighbor "$zone"; then
            dir=$([[ "$zone" == "L" ]] && echo l || echo r)
            "$HYPRCTL" dispatch "hl.dsp.focus({ direction = '$dir' })" >/dev/null 2>&1 || true
            last_fire=$now
          fi
        fi
        sleep "$POLL"
      done
    '';
  };
}