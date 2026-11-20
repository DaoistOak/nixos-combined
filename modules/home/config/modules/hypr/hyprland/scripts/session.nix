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
      set -o pipefail

      CACHE_DIR="$HOME/.cache/hypr"
      mkdir -p "$CACHE_DIR"

      CLIENTS=$(hyprctl clients -j 2>/dev/null) || exit 1
      [ -z "$CLIENTS" ] && exit 0

      IGNORE_CLASSES='^(kitty|org\.wezfurlong\.wezterm|Alacritty|foot|Ghostty|xterm|st-)$'

      TUI_MAP_FILE="$HOME/.config/hypr/session-tui-map.conf"
      if [ -f "$TUI_MAP_FILE" ]; then
        TUI_APPS=$(sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$TUI_MAP_FILE" | cut -d= -f1 | tr '\n' '|' | sed 's/|$//')
      else
        TUI_APPS=""
      fi

      TMP_FILE="$CACHE_DIR/.session.json.tmp"
      if ! printf '%s\n' "$CLIENTS" | ${pkgs.jq}/bin/jq --arg ignore "$IGNORE_CLASSES" --arg tuiApps "$TUI_APPS" '
        [ .[]
          | select((.class // "") != "")
          | ((.title // "") | sub("\\s+$"; "") | ascii_downcase) as $rawTitle
          | if (.class | test($ignore; "i")) then
              (if $rawTitle == "" then
                 empty
               elif $tuiApps != "" and ($rawTitle | test(("^(" + $tuiApps + ")$"))) then
                 { class: .class, title: (.title // ""), workspace: (.workspace.id // 0), floating: (.floating // false), tui: $rawTitle }
               else
                 empty
               end)
            else
              { class: .class, title: (.title // ""), workspace: (.workspace.id // 0), floating: (.floating // false), tui: null }
            end
        ]' > "$TMP_FILE"; then
        ${pkgs.libnotify}/bin/notify-send -u critical -i dialog-error "Session save failed" "jq processing failed"
        rm -f "$TMP_FILE"
        exit 1
      fi

      if [ ! -s "$TMP_FILE" ]; then
        rm -f "$TMP_FILE"
        exit 0
      fi

      mv -f "$TMP_FILE" "$CACHE_DIR/session.json"
      SAVED=$(${pkgs.jq}/bin/jq 'length' "$CACHE_DIR/session.json")
      ${pkgs.libnotify}/bin/notify-send -i dialog-save "Session saved" "$SAVED clients remembered"
    '';
  };

  xdg.configFile."hypr/scripts/session-restore.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -o pipefail

      SESSION_FILE="$HOME/.cache/hypr/session.json"
      MAPPING_FILE="$HOME/.config/hypr/session-mapping.conf"
      TUI_MAP_FILE="$HOME/.config/hypr/session-tui-map.conf"
      SCRIPTS="$HOME/.config/hypr/scripts"

      [ ! -f "$SESSION_FILE" ] && exit 0
      [ ! -f "$MAPPING_FILE" ] && exit 0

      JQ="${pkgs.jq}/bin/jq"
      [ "$("$JQ" 'length' "$SESSION_FILE" 2>/dev/null)" = "0" ] && exit 0

      ${pkgs.libnotify}/bin/notify-send -i display "Restoring session..."

      declare -A APP_MAP
      while IFS='=' read -r cls cmd; do
        cls="''${cls#''${cls%%[![:space:]]*}}"
        cls="''${cls%''${cls##*[![:space:]]}}"
        [[ "$cls" =~ ^#.*$ || -z "$cls" ]] && continue
        APP_MAP["$cls"]="$cmd"
      done < "$MAPPING_FILE"

      declare -A TUI_MAP
      if [[ -f "$TUI_MAP_FILE" ]]; then
        while IFS='=' read -r app cmd; do
          app="''${app#''${app%%[![:space:]]*}}"
          app="''${app%''${app##*[![:space:]]}}"
          [[ "$app" =~ ^#.*$ || -z "$app" ]] && continue
          TUI_MAP["$app"]="$cmd"
        done < "$TUI_MAP_FILE"
      fi

      RESTORED=0
      SKIPPED=0

      IGNORE_CLASSES='^(kitty|org\.wezfurlong\.wezterm|Alacritty|foot|Ghostty|xterm|st-)$'

      mapfile -t ENTRIES < <("$JQ" -r --arg ignore "$IGNORE_CLASSES" '
        .[] | select(.workspace > 0) |
        if (.class | test($ignore; "i")) then
          (if (.tui // null) != null and (.tui | tostring) != "" then "\(.class)\t\(.workspace)\t\(.floating)\t\(.tui)" else empty end)
        else
          "\(.class)\t\(.workspace)\t\(.floating)\t-"
        end' "$SESSION_FILE")

      CLASSES=()
      WORKSPACES=()
      FLOATINGS=()
      CMDS=()
      for entry in "''${ENTRIES[@]}"; do
        IFS=$'\t' read -r cls ws floating tui <<< "$entry"
        if [[ -n "$tui" && "$tui" != "-" ]]; then
          cmd="''${TUI_MAP[$tui]:-$SCRIPTS/launch-terminal.sh $tui}"
        else
          cmd="''${APP_MAP[$cls]:-}"
        fi
        if [ -z "$cmd" ]; then
          SKIPPED=$((SKIPPED + 1))
          continue
        fi
        CLASSES+=("$cls")
        WORKSPACES+=("$ws")
        FLOATINGS+=("$floating")
        CMDS+=("$cmd")
      done

      N=''${#CMDS[@]}
      if [ "$N" -eq 0 ]; then
        ${pkgs.libnotify}/bin/notify-send -i display "Session restored" "0 apps restored to their workspaces, $SKIPPED skipped"
        exit 0
      fi

      CACHE_DIR="$HOME/.cache/hypr"
      mkdir -p "$CACHE_DIR"
      BEFORE_FILE="$CACHE_DIR/.session-before.json"
      BEFORE_JSON=$(hyprctl clients -j 2>/dev/null)
      printf '%s' "$BEFORE_JSON" | "$JQ" -c '[.[].address]' > "$BEFORE_FILE" 2>/dev/null

      LAUNCH=()
      for ((i=0;i<N;i++)); do LAUNCH+=(1); done
      USED=""
      for ((i=0;i<N;i++)); do
        cls="''${CLASSES[$i]}"
        ws="''${WORKSPACES[$i]}"
        floating="''${FLOATINGS[$i]}"
        addr=""
        while IFS= read -r a; do
          [ -z "$a" ] && continue
          if [[ " $USED " != *" $a "* ]]; then addr="$a"; break; fi
        done < <(printf '%s' "$BEFORE_JSON" | "$JQ" -r --arg cls "$cls" '.[] | select(.class == $cls) | .address')
        if [ -n "$addr" ]; then
          hyprctl dispatch "hl.dsp.window.move({ workspace = $ws, follow = false, window = 'address:$addr' })" &>/dev/null
          if [ "$floating" = "true" ]; then
            hyprctl dispatch "hl.dsp.window.float({ action = 'toggle', window = 'address:$addr' })" &>/dev/null
          fi
          RESTORED=$((RESTORED + 1))
          USED="$USED $addr"
          LAUNCH[$i]=0
        fi
      done

      PENDING=()
      for ((i=0;i<N;i++)); do
        if [ "''${LAUNCH[$i]}" = "1" ]; then
          eval "''${CMDS[$i]}" &>/dev/null &
          PENDING+=("$i")
        fi
      done

      CLAIMED=""
      MAX_WAIT=25
      POLL_INTERVAL=0.2

      for tick in $(seq 1 "$MAX_WAIT"); do
        [ ''${#PENDING[@]} -eq 0 ] && break
        CLIENTS_JSON=$(hyprctl clients -j 2>/dev/null)
        NEW_PENDING=()
        for i in "''${PENDING[@]}"; do
          cls="''${CLASSES[$i]}"
          ws="''${WORKSPACES[$i]}"
          floating="''${FLOATINGS[$i]}"
          addr=$(printf '%s' "$CLIENTS_JSON" | "$JQ" -r \
            --arg cls "$cls" \
            --arg claimed "$CLAIMED" \
            --slurpfile prev "$BEFORE_FILE" \
            '([ .[] | select(.class == $cls and (.address as $a | ($prev[0] // []) | index($a) | not) and ($claimed == "" or (($claimed | split(" ")) | index($a)) | not)) ] | sort_by(.focusHistoryID // 0)) | if length > 0 then .[0].address // empty else "" end')
          if [ -n "$addr" ]; then
            hyprctl dispatch "hl.dsp.window.move({ workspace = $ws, follow = false, window = 'address:$addr' })" &>/dev/null
            if [ "$floating" = "true" ]; then
              hyprctl dispatch "hl.dsp.window.float({ action = 'toggle', window = 'address:$addr' })" &>/dev/null
            fi
            RESTORED=$((RESTORED + 1))
            CLAIMED="$CLAIMED $addr"
          else
            NEW_PENDING+=("$i")
          fi
        done
        PENDING=("''${NEW_PENDING[@]}")
        [ ''${#PENDING[@]} -eq 0 ] && break
        sleep "$POLL_INTERVAL"
      done

      SKIPPED=$((SKIPPED + ''${#PENDING[@]}))

      ${pkgs.libnotify}/bin/notify-send -i display "Session restored" "$RESTORED apps restored to their workspaces, $SKIPPED skipped"
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
      btop=$HOME/.config/hypr/scripts/launch-terminal.sh tmux new-session -A -s btop btop
      cava=$HOME/.config/hypr/scripts/launch-terminal.sh tmux new-session -A -s cava cava
      fastfetch=$HOME/.config/hypr/scripts/launch-terminal.sh fastfetch
    '';
  };

  systemd.user.services.hypr-session-save = {
    Unit = {
      Description = "Save Hyprland session before logout/sleep/lock";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
      ExecStop = "${config.home.homeDirectory}/.config/hypr/scripts/session-save.sh";
      Environment = [ "PATH=/run/current-system/sw/bin:/run/wrappers/bin:${config.home.profileDirectory}/bin" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}