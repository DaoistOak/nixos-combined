{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/gamer-mode.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Toggle gamer mode: opens the noctalia nomadcxx/gamer-mode panel and
      # mirrors its state into a "performance" Hyprland profile (no gaps, no
      # animations, opaque windows, square corners, no shadows). Closing the
      # panel restores the normal profile.
      set -euo pipefail

      PANEL_ID="nomadcxx/gamer-mode:main"

      noctalia msg panel-toggle "$PANEL_ID"
      # The panel open/close animation lags the toggle; wait for the state to
      # settle so the profile matches what the panel actually reports.
      sleep 0.2

      status="$(noctalia msg status)"
      open="$(${pkgs.jq}/bin/jq -r '.panelOpen' <<< "$status")"
      active="$(${pkgs.jq}/bin/jq -r '.activePanelId // ""' <<< "$status")"

      if [ "$open" = "true" ] && [ "$active" = "$PANEL_ID" ]; then
        hyprctl eval 'hl.config({
          general = { gaps_in = 0, gaps_out = 0 },
          decoration = {
            rounding = 0,
            active_opacity = 1,
            inactive_opacity = 1,
            shadow = { enabled = false },
          },
          animations = { enabled = false },
        })'
        # The whitelist transparency (SUPER+W,T) is a runtime window rule, not
        # a plain option; force it off so every window is fully opaque.
        hyprctl eval 'hyprTrans.force(false)'
        ${pkgs.libnotify}/bin/notify-send -i security-high "Gamer mode" "Performance profile enabled"
      else
        hyprctl eval 'hl.config({
          general = { gaps_in = 8, gaps_out = 16 },
          decoration = {
            rounding = 14,
            active_opacity = 1,
            inactive_opacity = 1,
            shadow = { enabled = true },
          },
          animations = { enabled = true },
        })'
        # Restore the transparency choice saved by SUPER+W,T.
        hyprctl eval 'hyprTrans.force(hyprTrans.get())'
        ${pkgs.libnotify}/bin/notify-send "Gamer mode" "Desktop profile restored"
      fi
    '';
  };
}
