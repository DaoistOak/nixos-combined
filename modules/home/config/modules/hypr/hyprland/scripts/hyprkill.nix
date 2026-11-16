{ config, pkgs, lib, ... }:
{
  xdg.configFile."hypr/scripts/hyprkill.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # hyprkill: click-to-kill for Hyprland (xkill-like).
      # Press its keybind (SUPER + SHIFT + C), then move the cursor over a
      # window and the window under the cursor is force-killed, including
      # non-responding ones.
      #
      # Note: `hyprctl kill` kills the FOCUSED window (no address arg in
      # Hyprland 0.56.x), so we focus the target window by address first,
      # then kill it.
      # Requires: hyprctl, jq. notify-send optional (toast).
      LOG="/tmp/hyprkill.log"
      : > "$LOG"

      log() { printf '[hyprkill %s] %s\n' "$(date '+%H:%M:%S')" "$*" >> "$LOG"; }

      POS="$(hyprctl cursorpos 2>/dev/null | grep -oE -- '-?[0-9]+, *-?[0-9]+' | head -n1 | tr -d ' ')" || true
      CX="$(printf '%s' "$POS" | cut -d, -f1)"
      CY="$(printf '%s' "$POS" | cut -d, -f2)"

      log "cursorpos raw: '$POS' -> CX='$CX' CY='$CY'"

      if [[ -z "$CX" || -z "$CY" || ! "$CX" =~ ^-?[0-9]+$ || ! "$CY" =~ ^-?[0-9]+$ ]]; then
        log "ERROR: could not parse cursor position"
        notify-send -a hyprkill "hyprkill" "could not read cursor position" 2>/dev/null || true
        exit 0
      fi

      ADDRESS="$(hyprctl clients -j 2>/dev/null | jq -r --arg cx "$CX" --arg cy "$CY" '
        .[] | select(
          .at[0] <= ($cx|tonumber) and ($cx|tonumber) < .at[0] + .size[0] and
          .at[1] <= ($cy|tonumber) and ($cy|tonumber) < .at[1] + .size[1]
        ) | .address
      ' 2>/dev/null | head -n1)" || true

      log "clients jq -> ADDRESS='$ADDRESS'"

      if [ -n "$ADDRESS" ] && [ "$ADDRESS" != "null" ]; then
        hyprctl dispatch focuswindow "address:$ADDRESS" >> "$LOG" 2>&1 || log "focuswindow failed for $ADDRESS"
        hyprctl kill >> "$LOG" 2>&1 || log "hyprctl kill failed for $ADDRESS"
        log "killed $ADDRESS"
        notify-send -a hyprkill "hyprkill" "killed $ADDRESS" 2>/dev/null || true
      else
        log "no window under cursor"
        notify-send -a hyprkill "hyprkill" "no window under cursor" 2>/dev/null || true
      fi
    '';
  };
}
