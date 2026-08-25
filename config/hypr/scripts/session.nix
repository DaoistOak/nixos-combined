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

      IGNORE_CLASSES='^kitty$|^Alacritty$|^foot$|^wezterm$|^xterm$|^st-|^Ghostty$'

      echo "$CLIENTS" | jq --arg ignore "$IGNORE_CLASSES" '
        [ .[]
          | select(.class | test($ignore; "i") | not)
          | {
              class: .class,
              title: .title,
              workspace: .workspace.id,
              floating: .floating,
              size: .size,
              at: .at
            }
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

      RESTORED=0
      SKIPPED=0

      IGNORE_CLASSES='^kitty$|^Alacritty$|^foot$|^wezterm$|^xterm$|^st-|^Ghostty$'

      $JQ -r --arg ignore "$IGNORE_CLASSES" '.[] | select(.workspace > 0) | select(.class | test($ignore; "i") | not) | "\(.class)\t\(.workspace)\t\(.floating)"' "$SESSION_FILE" | while IFS=$'\t' read -r cls ws floating; do
        cmd="''${APP_MAP[$cls]}"
        if [ -z "$cmd" ]; then
          SKIPPED=$((SKIPPED + 1))
          continue
        fi

        eval "$cmd" &>/dev/null &
        sleep 1.5

        addr=$(hyprctl clients -j | $JQ -r "[.[] | select(.class == \"$cls\")] | sort_by(.focusHistoryID) | last | .address // empty" 2>/dev/null)
        if [ -n "$addr" ] && [ "$addr" != "" ]; then
          hyprctl dispatch focuswindow address:"$addr" &>/dev/null
          sleep 0.1
          hyprctl dispatch movetoworkspace "$ws" &>/dev/null
          sleep 0.2
          if [ "$floating" = "true" ]; then
            hyprctl dispatch togglefloating &>/dev/null
          fi
          RESTORED=$((RESTORED + 1))
        fi
      done

      TOTAL=$($JQ --arg ignore "$IGNORE_CLASSES" '[.[] | select(.workspace > 0) | select(.class | test($ignore; "i") | not)] | length' "$SESSION_FILE")
      ${pkgs.libnotify}/bin/notify-send -i display "Session restored" "$TOTAL apps launched and moved"
    '';
  };
  xdg.configFile."hypr/session-mapping.conf" = {
    text = ''
      # Class=command (one per line)
      # Terminals are excluded automatically
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
}
