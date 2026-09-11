{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/switch-default-terminal.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Pick the terminal used by launch-terminal.sh (rofi menu).
      set -euo pipefail

      STATE_FILE="''${XDG_CONFIG_HOME:-$HOME/.config}/hypr/.default-terminal"
      CURRENT="$(cat "$STATE_FILE" 2>/dev/null || echo wezterm)"

      CHOICE="$(printf 'wezterm\nalacritty\nkitty\n' |
        ${pkgs.rofi}/bin/rofi -dmenu -p "Default terminal" -mesg "Current: $CURRENT" -lines 3)"
      if [[ -z "$CHOICE" ]]; then
        exit 0
      fi

      echo "$CHOICE" > "$STATE_FILE"
      ${pkgs.libnotify}/bin/notify-send "Default terminal" "Set to $CHOICE"
    '';
  };
}
