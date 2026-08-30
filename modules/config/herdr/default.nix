{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.herdr ];

  xdg.configFile."herdr/config.toml" = {
    text = ''
      [theme]
      name = "catppuccin"

      [theme.custom]
      # Catppuccin Macchiato palette
      accent = "#8aadf4"
      panel_bg = "#1e2030"
      active_row_bg = "#24273a"
      selection_bg = "#363a4f"
      surface0 = "#363a4f"
      surface1 = "#494d64"
      surface_dim = "#24273a"
      overlay0 = "#6e738d"
      overlay1 = "#8087a2"
      text = "#cad3f5"
      subtext0 = "#a5adcb"
      mauve = "#c6a0f6"
      green = "#a6da95"
      yellow = "#eed49f"
      red = "#ed8796"
      blue = "#8aadf4"
      teal = "#8bd5ca"
      peach = "#f5a97f"

      [keys]
      prefix = "ctrl+space"
      new_tab = "prefix+n"
      previous_tab = "alt+p"
      next_tab = "alt+l"
      split_horizontal = "prefix+v"
      split_vertical = "prefix+b"
      detach = "prefix+d"

      [ui]
      sidebar_start_collapsed = true
    '';
    force = true;
  };

  # super+f launcher: open herdr inside kitty and start yazi in a fresh
  # focused workspace, so an already-running agent pane never gets the input.
  xdg.configFile."herdr/scripts/launch-yazi.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      herdr=${pkgs.herdr}/bin/herdr
      jq=${pkgs.jq}/bin/jq

      kitty -e "$herdr" &
      herdr_pid=$!

      ready=0
      for _ in $(seq 1 100); do
        if "$herdr" pane current >/dev/null 2>&1; then
          ready=1
          break
        fi
        sleep 0.1
      done

      if [ "$ready" = "1" ]; then
        "$herdr" workspace create --focus --label yazi >/dev/null 2>&1 || true
        pane_id=$("$herdr" pane current | "$jq" -r '.result.pane.pane_id // empty' 2>/dev/null || true)
        if [ -n "$pane_id" ]; then
          "$herdr" pane run "$pane_id" 'yazi'
        fi
      fi

      wait "$herdr_pid"
    '';
  };
}
