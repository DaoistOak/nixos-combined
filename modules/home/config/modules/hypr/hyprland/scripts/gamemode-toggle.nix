{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/gamemode-toggle.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Manual GameMode toggle: requests/unrequests GameMode via gamemoded -r,
      # which drives programs.gamemode's custom start/end hooks
      # (performance-mode.sh start/end).
      set -euo pipefail

      export PATH="/run/current-system/sw/bin:/run/wrappers/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin:$PATH"

      STATE_FILE="${config.xdg.cacheHome}/hypr/gamemode-manual"
      PID_FILE="${config.xdg.cacheHome}/hypr/gamemode-manual.pid"
      mkdir -p "$(dirname "$STATE_FILE")"

      if [ -f "$STATE_FILE" ] && [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        kill "$(cat "$PID_FILE")" 2>/dev/null || true
        rm -f "$STATE_FILE" "$PID_FILE"
        ${pkgs.libnotify}/bin/notify-send "GameMode" "Manual gamemode stopped"
      else
        rm -f "$STATE_FILE" "$PID_FILE"
        nohup ${pkgs.gamemode}/bin/gamemoded -r >/dev/null 2>&1 &
        echo $! > "$PID_FILE"
        touch "$STATE_FILE"
        ${pkgs.libnotify}/bin/notify-send "GameMode" "Manual gamemode started"
      fi
    '';
  };
}