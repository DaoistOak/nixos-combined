{
  config,
  pkgs,
  lib,
  ...
}:
{
  xdg.configFile."hypr/scripts/session-save.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      CACHE_DIR="$HOME/.cache/hypr"
      mkdir -p "$CACHE_DIR"

      CLIENTS=$(hyprctl clients -j)
      COUNT=$(echo "$CLIENTS" | jq length)

      IGNORE_CLASSES='^(kitty|org\.wezfurlong\.wezterm|Alacritty|foot|Ghostty|xterm|st-)$'
      SHELL_TITLES='^(zsh|bash|sh|dash|fish|tmux|wezterm|nu|nushell|pwsh|powershell|ksh|elvish|xonsh)$'

      echo "$CLIENTS" | ${pkgs.jq}/bin/jq --arg ignore "$IGNORE_CLASSES" --arg shellTitles "$SHELL_TITLES" '
        [ .[]
          | if (.class | test($ignore; "i")) then
              (.title | sub("\\s+$"; "") | ascii_downcase) as $app
              | if ($app | test($shellTitles)) or ($app | test("[^a-z0-9._-]")) then
                  empty
                else
                  { class: .class, title: .title, workspace: .workspace.id, floating: .floating, tui: $app }
                end
            else
              { class: .class, title: .title, workspace: .workspace.id, floating: .floating, tui: null }
            end
        ]' > "$CACHE_DIR/session.json"

      if [ $? -eq 0 ] && [ -f "$CACHE_DIR/session.json" ]; then
        ${pkgs.libnotify}/bin/notify-send -i dialog-save "Session saved" "$COUNT clients remembered"
      else
        ${pkgs.libnotify}/bin/notify-send -u critical -i dialog-error "Session save failed" "Could not write to $CACHE_DIR/session.json"
      fi
    '';
  };
  xdg.configFile."hypr/scripts/session-restore.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      SESSION_FILE="$HOME/.cache/hypr/session.json"
      MAPPING_FILE="$HOME/.config/hypr/session-mapping.conf"
      TUI_MAP_FILE="$HOME/.config/hypr/session-tui-map.conf"
      SCRIPTS="$HOME/.config/hypr/scripts"

      [ ! -f "$SESSION_FILE" ] && exit 0
      [ ! -f "$MAPPING_FILE" ] && exit 0
      [ "$(${pkgs.jq}/bin/jq length "$SESSION_FILE")" -eq 0 ] && exit 0

      ${pkgs.libnotify}/bin/notify-send -i display "Restoring session..."

      JQ="${pkgs.jq}/bin/jq"

      declare -A APP_MAP
      while IFS='=' read -r cls cmd; do
        cls="''${cls#"''${cls%%[![:space:]]*}"}"
        cls="''${cls%"''${cls##*[![:space:]]}"}"
        [[ "$cls" =~ ^#.*$ || -z "$cls" ]] && continue
        APP_MAP["$cls"]="$cmd"
      done < "$MAPPING_FILE"

      declare -A TUI_MAP
      if [[ -f "$TUI_MAP_FILE" ]]; then
        while IFS='=' read -r app cmd; do
          app="''${app#"''${app%%[![:space:]]*}"}"
          app="''${app%"''${app##*[![:space:]]}"}"
          [[ "$app" =~ ^#.*$ || -z "$app" ]] && continue
          TUI_MAP["$app"]="$cmd"
        done < "$TUI_MAP_FILE"
      fi

      RESTORED=0
      SKIPPED=0

      IGNORE_CLASSES='^(kitty|org\.wezfurlong\.wezterm|Alacritty|foot|Ghostty|xterm|st-)$'

      CACHE_DIR="$HOME/.cache/hypr"
      BEFORE_FILE="$CACHE_DIR/.session-before.json"
      MAX_WAIT=20

      while IFS=$'\t' read -r cls ws floating tui; do
        if [[ -n "$tui" && "$tui" != "-" ]]; then
          cmd="''${TUI_MAP[$tui]:-$SCRIPTS/launch-terminal.sh $tui}"
        else
          cmd="''${APP_MAP[$cls]}"
        fi
        if [ -z "$cmd" ]; then
          SKIPPED=$((SKIPPED + 1))
          continue
        fi

        hyprctl clients -j | "$JQ" -c '[.[].address]' > "$BEFORE_FILE"

        eval "$cmd" &>/dev/null &

        addr=""
        for i in $(seq 1 "$MAX_WAIT"); do
          sleep 0.5
          addr=$(hyprctl clients -j | "$JQ" -r \
            --arg cls "$cls" \
            --slurpfile prev "$BEFORE_FILE" \
            '([ .[]
               | select(.class == $cls and (.address as $a | $prev[0] | index($a) | not))
             ] | sort_by(.focusHistoryID)) | if length > 0 then .[0].address // empty else "" end')
          [ -n "$addr" ] && break
        done

        if [ -n "$addr" ]; then
          hyprctl dispatch "hl.dsp.window.move({ workspace = $ws, follow = false, window = 'address:$addr' })" &>/dev/null
          sleep 0.2
          if [ "$floating" = "true" ]; then
            hyprctl dispatch "hl.dsp.window.float({ action = 'toggle', window = 'address:$addr' })" &>/dev/null
          fi
          RESTORED=$((RESTORED + 1))
        else
          SKIPPED=$((SKIPPED + 1))
        fi
      done < <("$JQ" -r --arg ignore "$IGNORE_CLASSES" '.[] | select(.workspace > 0) | if (.class | test($ignore; "i")) then (if (.tui // null) != null then "\(.class)\t\(.workspace)\t\(.floating)\t\(.tui)" else empty end) else "\(.class)\t\(.workspace)\t\(.floating)\t-" end' "$SESSION_FILE")

      ${pkgs.libnotify}/bin/notify-send -i display "Session restored" "''${RESTORED} apps restored to their workspaces, ''${SKIPPED} skipped"
    '';
  };
  xdg.configFile."hypr/session-mapping.conf" = {
    text = ''
      # Class=command (one per line)
      # TUI apps in terminals are handled by session-tui-map.conf
      # Run hyprctl clients -j | jq '.[].class' to discover window classes
      neovide=neovide
      zen=zen
      firefox=firefox
      vesktop=vesktop
      viber=viber
      com.rtosta.zapzap=com.rtosta.zapzap
      pcmanfm=pcmanfm
      org.kde.okular=okular
      Code=code
      Nautilus=nautilus
      Thunar=thunar
      Zathura=zathura
      mpv=mpv
      imv=imv
      Pavucontrol=pavucontrol
      Lxappearance=lxappearance
      Nm-connection-editor=nm-connection-editor
      Gimp=gimp
      Inkscape=inkscape
      Steam=steam
    '';
  };
  xdg.configFile."hypr/session-tui-map.conf" = {
    text = ''
      # TUI apps: app=launch command. App is taken from the terminal window
      # title (tmux reports the window name, other TUI apps report themselves).
      # Apps started inside tmux should use `tmux new-session -A` so they
      # re-attach to the same session. Pure tmux-only sessions are ignored.
      herdr=$HOME/.config/hypr/scripts/launch-terminal.sh tmux new-session -A -s herdr herdr
      nvim=$HOME/.config/hypr/scripts/launch-terminal.sh tmux new-session -A -s nvim nvim
      btop=$HOME/.config/hypr/scripts/launch-terminal.sh btop
      cava=$HOME/.config/hypr/scripts/launch-terminal.sh cava
      fastfetch=$HOME/.config/hypr/scripts/launch-terminal.sh fastfetch
    '';
  };
}
