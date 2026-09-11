{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/noctalia-restart.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Restart noctalia: kill the current instance and relaunch it detached
      # (noctalia runs as a Hyprland child, not a systemd service).
      set -euo pipefail

      pkill -f "bin/noctalia" 2>/dev/null || true
      sleep 0.6
      setsid nohup noctalia >/dev/null 2>&1 < /dev/null &
      disown || true
    '';
  };
}
