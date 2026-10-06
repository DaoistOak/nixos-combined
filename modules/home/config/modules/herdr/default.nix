{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.herdr ];

  # herdr writes back to config.toml (e.g. onboarding flag), so it must be a
  # regular writable file, not a read-only Nix-store symlink from xdg.configFile.
  # NOTE: the [theme*] palette block is deliberately NOT seeded here — it is
  # Catppuccin-hardcoded and would never follow the selection. scripts/theme
  # writes it on every switch (gen_herdr_theme), preserving [keys]/[ui].
  home.activation.herdrConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        herdr_cfg="${config.xdg.configHome}/herdr/config.toml"
        if [ ! -f "$herdr_cfg" ]; then
          mkdir -p "$(dirname "$herdr_cfg")"
          cat > "$herdr_cfg" << 'HERDR_CONFIG'
    [keys]
    prefix = "ctrl+b"
    new_tab = "prefix+n"
    previous_tab = "alt+p"
    next_tab = "alt+l"
    split_horizontal = "prefix+v"
    split_vertical = "prefix+b"
    detach = "prefix+d"
    toggle_sidebar = "prefix+shift+b"
    settings = "prefix+shift+s"

    [ui]
    sidebar_start_collapsed = true
    HERDR_CONFIG
        fi
  '';

  # super+f launcher: open herdr inside wezterm and start yazi in a fresh
  # focused workspace, so an already-running agent pane never gets the input.
  xdg.configFile."herdr/scripts/launch-yazi.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      herdr=${pkgs.herdr}/bin/herdr
      jq=${pkgs.jq}/bin/jq

      wezterm start "$herdr" &
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
