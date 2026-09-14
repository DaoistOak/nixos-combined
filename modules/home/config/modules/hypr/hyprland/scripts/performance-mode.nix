{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/performance-mode.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Toggle performance mode (SUPER+S, G). A plain state flip — no noctalia
      # panel dependency. When enabled: Hyprland runs with no gaps/animations
      # and fully opaque square windows, and Noctalia stops drawing any
      # transparency or rounded corners (screen corners off, concave edge
      # corners off, radius 0, every background_opacity forced to 1.0).
      # Noctalia changes go through ~/.local/state/noctalia/settings.toml,
      # which the shell watches for external edits and hot-applies.
      # Disabling restores both profiles.
      set -euo pipefail

      NOCTALIA_SETTINGS="${config.xdg.stateHome}/noctalia/settings.toml"
      NOCTALIA_BAK="${config.xdg.cacheHome}/hypr/noctalia-settings.perf-bak"
      STATE_FILE="${config.xdg.cacheHome}/hypr/performance-mode"

      mkdir -p "$(dirname "$NOCTALIA_BAK")" "$(dirname "$STATE_FILE")"

      apply_hyprland() {
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
      }

      restore_hyprland() {
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
      }

      apply_noctalia() {
        [ -f "$NOCTALIA_SETTINGS" ] || return 0
        cp "$NOCTALIA_SETTINGS" "$NOCTALIA_BAK"
        local tmp
        tmp="$(mktemp)"
        ${pkgs.gawk}/bin/awk '
          /^\s*\[/ {
            section = $0
            gsub(/^\s*\[|\]$/, "", section)
            in_corners = (section == "shell.screen_corners")
            in_opacity = (section == "dock" || section ~ /^bar\./ ||
                          section == "notification" || section == "osd")
            print
            if (section == "dock") {
              print "concave_edge_corners = false"
              print "radius = 0"
              print "radius_top_left = 0"
              print "radius_top_right = 0"
              print "radius_bottom_left = 0"
              print "radius_bottom_right = 0"
            }
            next
          }
          in_corners && $1 == "enabled" { sub(/=.*/, "= false"); print; next }
          in_opacity && $1 == "background_opacity" { sub(/=.*/, "= 1.0"); print; next }
          { print }
        ' "$NOCTALIA_SETTINGS" > "$tmp"
        cp "$tmp" "$NOCTALIA_SETTINGS"
        rm -f "$tmp"
      }

      restore_noctalia() {
        [ -f "$NOCTALIA_BAK" ] || return 0
        cp "$NOCTALIA_BAK" "$NOCTALIA_SETTINGS"
        rm -f "$NOCTALIA_BAK"
      }

      if [ ! -f "$STATE_FILE" ]; then
        apply_hyprland
        apply_noctalia
        touch "$STATE_FILE"
        ${pkgs.libnotify}/bin/notify-send -i security-high "Performance mode" "Transparency, gaps and corners disabled"
      else
        restore_hyprland
        restore_noctalia
        rm -f "$STATE_FILE"
        ${pkgs.libnotify}/bin/notify-send "Performance mode" "Desktop profile restored"
      fi
    '';
  };
}