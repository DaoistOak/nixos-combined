{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/cava-auto.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Launch cava with a bar count that adapts to the terminal width.
      # cava (noncurses) requires bars <= cols/3, so compute the live window
      # width and run with a temporary config overriding `bars`.
      set -euo pipefail

      CONF="''${XDG_CONFIG_HOME:-$HOME/.config}/cava/config"
      # let the window settle to its final tiled size before measuring, else
      # we compute bars for the transient spawn width and cava dies on resize
      sleep 0.8
      cols=$(tput cols)
      bars=$((cols > 0 ? cols / 3 - 3 : 16))
      [[ $bars -lt 4 ]] && bars=4

      tmp=$(mktemp --tmpdir cava-auto.XXXXXXXX.conf)
      trap 'rm -f "$tmp"' EXIT
      sed "s/^bars = .*/bars = $bars/" "$CONF" > "$tmp"

      exec "${pkgs.cava}/bin/cava" -p "$tmp"
    '';
  };
}
