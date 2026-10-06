{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Colors are declared as hyprlock variables sourced from the shared theme DB,
  # so a light/dark switch is a one-line change here instead of 7 hardcoded
  # Catppuccin hexes. scripts/theme rewrites just the `$\w+=` lines at runtime,
  # so `theme <name> <variant>` recolors the lock screen without a rebuild.
  xdg.configFile."hypr/hyprlock.conf".text = ''
      $font=JetBrains Mono
      $hl_text=${config.colors.active.text}
      $hl_sub=${config.colors.active.subtext1}
      $hl_faint=${config.colors.active.overlay0}
      $hl_surface=${config.colors.active.surface0}

    # GENERAL
    general {
      hide_cursor = true
    }

    auth {
      fingerprint {
        enabled = true
        ready_message = Scan fingerprint to unlock
        present_message = Scanning...
        retry_delay = 250 # in milliseconds
      }
    }

    # BACKGROUND
    background {
      monitor =
      path = /tmp/hyprlock/screenshot.png
      blur_size = 4
      blur_passes = 3 # 0 disables blurring
      noise = 0.0117
      contrast = 1.3000
      brightness = 0.8000
      vibrancy = 0.2100
      vibrancy_darkness = 0.0
    }
    # Hours
    label {
        monitor =
        text = cmd[update:1000] echo "<b><big> $(date +"%H") </big></b>"
        color = rgb($hl_text)
        font_size = 112
        font_family = $font
        shadow_passes = 3
        shadow_size = 4

        position = 0, 300
        halign = center
        valign = center
    }

    # Minutes
    label {
        monitor =
        text = cmd[update:1000] echo "<b><big> $(date +"%M") </big></b>"
        color = rgb($hl_text)
        font_size = 112
        font_family = $font
        shadow_passes = 3
        shadow_size = 4

        position = 0, 160
        halign = center
        valign = center
    }

    # Today
    label {
        monitor =
        text = cmd[update:18000000] echo "<b><big> "$(date +'%A')" </big></b>"
        color = rgb($hl_sub)
        font_size = 22
        font_family = $font

        position = 0, 80
        halign = center
        valign = center
    }


    input-field {
        monitor =
        size = 250, 50
        outline_thickness = 3
        dots_size = 0.26 # Scale of input-field height, 0.2 - 0.8
        dots_spacing = 0.64 # Scale of dots' absolute size, 0.0 - 1.0
        dots_center = true
        dots_rounding = -1
        rounding = 14
        outer_color = rgb($hl_text)
        inner_color = rgb($hl_surface)
        font_color = rgb($hl_text)
        fade_on_empty = true
        placeholder_text = <i>Password...</i>
        position = 0, 120
        halign = center
        valign = bottom
    }
    # Feels like
    label {
        monitor =
        text = cmd[update:18000000] echo "<b>Feels like<big> $(curl -s 'wttr.in?format=%t' | tr -d '+') </big></b>"
        color = rgb($hl_faint)
        font_size = 18
        font_family = $font

        position = 0, 40
        halign = center
        valign = bottom
    }
  '';
}
