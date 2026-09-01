{
  config,
  pkgs,
  lib,
  ...
}:
let
  isEnabled = (config.wayland.windowManager.hyprland.settings.config.animations.enabled or true);
  gapsIn = (config.wayland.windowManager.hyprland.settings.config.general.gaps_in or 3);
  gapsOut = (config.wayland.windowManager.hyprland.settings.config.general.gaps_out or 4);
in
{
  xdg.configFile."hypr/scripts/toggle-performance.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Toggle performance/gaming mode: disable window animations, gaps and
      # opacity compositor-wide for games/benchmarks. Turning it off restores
      # the values compiled into this NixOS home configuration.
      set -euo pipefail

      if ! command -v hyprctl >/dev/null 2>&1; then
        exit 1
      fi

      STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
      STATE_FILE="$STATE_DIR/performance-mode"
      NOTIFY="${pkgs.libnotify}/bin/notify-send"
      HYPRCTL_BIN="''${HYPRCTL_BIN:-hyprctl}"

      if [[ -f "$STATE_FILE" ]]; then
        # Disable: restore the compiled-in desktop defaults.
        "$HYPRCTL_BIN" eval 'hl.config({
          animations = { enabled = ${lib.boolToString isEnabled} },
          general = { gaps_in = ${toString gapsIn}, gaps_out = ${toString gapsOut} },
          decoration = { active_opacity = 1.0, inactive_opacity = 1.0 },
        })'
        rm -f "$STATE_FILE"
        "$NOTIFY" -i media-playback-stop "Performance mode" "Previous desktop settings restored"
      else
        # Enable: freeze defaults first (contributes to the restore) then
        # force the performance profile.
        mkdir -p "$STATE_DIR"
        : > "$STATE_FILE"
        "$HYPRCTL_BIN" eval 'hl.config({
          animations = { enabled = false },
          general = { gaps_in = 0, gaps_out = 0 },
          decoration = { active_opacity = 1.0, inactive_opacity = 1.0 },
        })'
        "$NOTIFY" -i media-playback-start "Performance mode" "Animations, gaps and transparency disabled"
      fi
    '';
  };
}
