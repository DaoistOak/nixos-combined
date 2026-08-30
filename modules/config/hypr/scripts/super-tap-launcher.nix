{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."hypr/scripts/super-tap-launcher.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Open the noctalia run launcher from the bare-Super tap and keep its
      # keyboard focus. Noctalia maps the launcher with layer keyboard
      # interactivity "exclusive", then relaxes it to "on-demand" ~100ms later;
      # Hyprland then refocuses whatever surface the pointer is over, so on a
      # workspace with a window under the cursor the launcher loses keystrokes
      # until it is hovered. Warping the pointer onto the launcher (top-center,
      # just below the top edge) keeps Hyprland's focus on it on every workspace.
      noctalia msg panel-toggle launcher

      coord=$(${pkgs.jq}/bin/jq -rn \
        --argjson monitors "$(hyprctl monitors -j)" \
        '[$monitors[] | select(.focused)] | .[0]
         | "\((.x + .width / 2) | floor) \((.y + 120) | floor)"')
      if [ -n "$coord" ]; then
        read -r cx cy <<< "$coord"
        hyprctl dispatch "hl.cursor.move({ x = $cx, y = $cy })"
      fi
    '';
  };
}
