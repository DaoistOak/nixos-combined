{ config, pkgs, lib, ... }:
{
  xdg.configFile."hypr/scripts/hyprkill.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # hyprkill: click-to-kill for Hyprland (xkill-like).
      # Press its keybind, then left-click (or hover) a window to kill it,
      # including non-responding ones. Uses the forceful `hyprctl kill <addr>`.
      # Requires: hyprctl, jq (notify-send optional, for the toast).
      set -euo pipefail

      POS="$(hyprctl cursorpos | grep -oE -- '-?[0-9]+, *-?[0-9]+' | head -n1 | tr -d ' ')"
      CX="$(printf '%s' "$POS" | cut -d, -f1)"
      CY="$(printf '%s' "$POS" | cut -d, -f2)"

      ADDRESS="$(hyprctl clients -j | jq -r --arg cx "$CX" --arg cy "$CY" '
        .[] | select(
          .at[0] <= ($cx|tonumber) and ($cx|tonumber) < .at[0] + .size[0] and
          .at[1] <= ($cy|tonumber) and ($cy|tonumber) < .at[1] + .size[1]
        ) | .address
      ' | head -n1)"

      if [ -n "$ADDRESS" ]; then
        hyprctl kill "$ADDRESS"
        notify-send -a hyprkill "hyprkill" "killed $ADDRESS" 2>/dev/null || true
      else
        notify-send -a hyprkill "hyprkill" "no window under cursor" 2>/dev/null || true
      fi
    '';
  };
}
