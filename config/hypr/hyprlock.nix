{ config, lib, pkgs, ... }: {
xdg.configFile."hypr/hyprlock.conf".text = ''
  source = $HOME/.config/hypr/themes/colors
  $font=JetBrains Mono

# GENERAL
general {
  # disable_loading_bar = true
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
 # color = rgba(25, 20, 20, 1.0)
  blur_size = 4
  blur_passes = 3 # 0 disables blurring
  noise = 0.0117
  contrast = 1.3000 # Vibrant!!!
  brightness = 0.8000
  vibrancy = 0.2100
  vibrancy_darkness = 0.0
}
# Hours
label {
    monitor =
    text = cmd[update:1000] echo "<b><big> $(date +"%H") </big></b>"
    color = $accent
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
    color = $accent
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
    color = $overlay1
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
    dots_rouding = -1
    rounding = 14
    outer_color = $accent
    inner_color = $surface0
    font_color = $text
    fade_on_empty = true
    placeholder_text = <i>Password...</i> 
    position = 0, 120
    halign = center
    valign = bottom
}
# Degrees
label {
    monitor =
    text = cmd[update:18000000] echo "<b>Feels like<big> $(curl -s 'wttr.in?format=%t' | tr -d '+') </big></b>"
    color = $overlay0
    font_size = 18
    font_family = $font 

    position = 0, 40
    halign = center
    valign = bottom
}



  # # USER AVATAR
  # image {
  #     monitor =
  #     path = ~/.config/hypr/.face
  #     size = 150
  #
  # }
'';
}
