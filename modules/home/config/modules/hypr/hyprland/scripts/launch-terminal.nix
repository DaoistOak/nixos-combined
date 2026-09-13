{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/launch-terminal.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Launch a command in the selected default terminal (see
      # switch-default-terminal.sh). Defaults to wezterm when unset.
      # Usage: launch-terminal.sh [--cwd DIR] [--hold] [--] [COMMAND]
      set -euo pipefail

      STATE_FILE="''${XDG_CONFIG_HOME:-$HOME/.config}/hypr/.default-terminal"
      DEFAULT_TERMINAL="$(cat "$STATE_FILE" 2>/dev/null || echo wezterm)"

      CWD=""
      HOLD=0
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --cwd) CWD="$2"; shift 2 ;;
          --hold) HOLD=1; shift ;;
          --) shift; break ;;
          *) break ;;
        esac
      done

      run_wezterm() {
        local args=()
        [[ -n "$CWD" ]] && args+=(--cwd "$CWD")
        # no --hold: wezterm start has no such flag; commands are wrapped in a
        # shell below so the window always stays open.
        # --always-new-process: without it `wezterm start` reuses the running
        # GUI instance and silently opens a tab inside an existing window,
        # so the bound launch appears to do nothing. Commands are wrapped in
        # a shell so short ones (fastfetch, cava) don't close the window
        # the moment they exit.
        if [[ $# -eq 0 ]]; then
          wezterm start --always-new-process "''${args[@]}"
        else
          wezterm start --always-new-process "''${args[@]}" -- sh -c '"$@"; exec "''${SHELL:-sh}"' sh "$@"
        fi
      }

      run_alacritty() {
        local args=()
        [[ -n "$CWD" ]] && args+=(--working-directory "$CWD")
        if [[ $# -eq 0 ]]; then
          alacritty "''${args[@]}"
        elif [[ "$HOLD" == 1 ]]; then
          alacritty "''${args[@]}" -e sh -c '"$@" ; exec "''${SHELL:-sh}"' sh "$@"
        else
          alacritty "''${args[@]}" -e "$@"
        fi
      }

      run_kitty() {
        local args=()
        [[ -n "$CWD" ]] && args+=(--directory "$CWD")
        if [[ $# -eq 0 ]]; then
          kitty "''${args[@]}"
        else
          kitty "''${args[@]}" "$@"
        fi
      }

      case "$DEFAULT_TERMINAL" in
        alacritty) run_alacritty "$@" ;;
        kitty) run_kitty "$@" ;;
        *) run_wezterm "$@" ;;
      esac
    '';
  };
}
