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
      # Apply/restore the "performance mode" (gaps/corners/transparency/border
      # rotate/makima) profile. Invoked by GameMode's custom start/end hooks
      # (see pkgs/system-programs.nix -> programs.gamemode.settings.custom),
      # not by a Hyprland keybind anymore. Args: start | end
      set -euo pipefail

      # gamemoded forces a minimal PATH (pkexec only); restore a usable one.
      export PATH="/run/current-system/sw/bin:/run/wrappers/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin:$PATH"

      # Hyprland env may be missing when run from the gamemoded user service.
      if [ -z "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        _his="$(ls -1 /run/user/$(id -u)/hypr 2>/dev/null | head -n1)"
        [ -n "$_his" ] && export HYPRLAND_INSTANCE_SIGNATURE="$_his"
      fi

      NOCTALIA_SETTINGS="${config.xdg.stateHome}/noctalia/settings.toml"
      NOCTALIA_BAK="${config.xdg.cacheHome}/hypr/noctalia-settings.perf-bak"

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
        hyprctl eval 'hyprTrans.force(hyprTrans.get())'
      }

      apply_noctalia() {
        [ -f "$NOCTALIA_SETTINGS" ] || return 0
        cp "$NOCTALIA_SETTINGS" "$NOCTALIA_BAK"
        local tmp
        tmp="$(mktemp)"
        ${pkgs.gawk}/bin/awk '
          function emit_section(    sec, target, in_opacity_sec, has_rc, has_radius, has_tl, has_tr, has_bl, has_br, line, i) {
            if (header == "")
              return
            sec = current_sec
            target = (sec == "dock" || sec ~ /^bar\./)
            in_opacity_sec = target || sec == "notification" || sec == "osd"
            has_rc = 0; has_radius = 0; has_tl = 0; has_tr = 0; has_bl = 0; has_br = 0
            for (i = 1; i <= nb; i++) {
              line = body[i]
              if (line ~ /^[ \t]*concave_edge_corners[ \t]*=/) has_rc = 1
              if (line ~ /^[ \t]*radius[ \t]*=/) has_radius = 1
              if (line ~ /^[ \t]*radius_top_left[ \t]*=/) has_tl = 1
              if (line ~ /^[ \t]*radius_top_right[ \t]*=/) has_tr = 1
              if (line ~ /^[ \t]*radius_bottom_left[ \t]*=/) has_bl = 1
              if (line ~ /^[ \t]*radius_bottom_right[ \t]*=/) has_br = 1
            }
            print header
            if (target) {
              if (!has_rc) print "concave_edge_corners = false"
              if (!has_radius) print "radius = 0"
              if (!has_tl) print "radius_top_left = 0"
              if (!has_tr) print "radius_top_right = 0"
              if (!has_bl) print "radius_bottom_left = 0"
              if (!has_br) print "radius_bottom_right = 0"
            }
            for (i = 1; i <= nb; i++) {
              line = body[i]
              if (sec == "shell.screen_corners" && line ~ /^[ \t]*enabled[ \t]*=/) {
                sub(/=.*/, "= false", line)
                print line
                continue
              }
              if (target && line ~ /^[ \t]*(radius|radius_top_left|radius_top_right|radius_bottom_left|radius_bottom_right|concave_edge_corners)[ \t]*=/) {
                if (line ~ /concave_edge_corners/)
                  sub(/=.*/, "= false", line)
                else
                  sub(/=.*/, "= 0", line)
                print line
                continue
              }
              if (in_opacity_sec && line ~ /^[ \t]*background_opacity[ \t]*=/) {
                sub(/=.*/, "= 1.0", line)
                print line
                continue
              }
              print line
            }
          }
          /^\s*\[/ {
            emit_section()
            header = $0
            current_sec = header
            gsub(/^\s*\[|\]$/, "", current_sec)
            nb = 0
            delete body
            next
          }
          { body[++nb] = $0 }
          END { emit_section() }
        ' "$NOCTALIA_SETTINGS" > "$tmp"
        cp "$tmp" "$NOCTALIA_SETTINGS"
        rm -f "$tmp"
      }

      restore_noctalia() {
        [ -f "$NOCTALIA_BAK" ] || return 0
        cp "$NOCTALIA_BAK" "$NOCTALIA_SETTINGS"
        rm -f "$NOCTALIA_BAK"
      }

      case "''${1:-}" in
        start)
          apply_hyprland
          apply_noctalia
          "${config.xdg.configHome}/hypr/scripts/border-rotate.sh" off
          systemctl --user stop makima.service || true
          ${pkgs.libnotify}/bin/notify-send -i security-high "Performance mode" "Transparency, gaps and corners disabled; makima off"
          ;;
        end)
          restore_hyprland
          restore_noctalia
          "${config.xdg.configHome}/hypr/scripts/border-rotate.sh" on
          systemctl --user start makima.service || true
          ${pkgs.libnotify}/bin/notify-send "Performance mode" "Desktop profile restored; makima on"
          ;;
        *)
          echo "usage: $0 {start|end}" >&2
          exit 2
          ;;
      esac
    '';
  };
}