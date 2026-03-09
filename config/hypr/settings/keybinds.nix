{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    $mod = SUPER
    $upr = SHIFT
    $workspaceSwipeFingers = 3
    $gestureFingers = 3

    bindm = SUPER, mouse:272, movewindow
    bindm = SUPER, mouse:273, resizewindow

    # --------------------
    # Gestures configuration
    # --------------------
    gestures {
      workspace_swipe_distance = 700
      workspace_swipe_cancel_ratio = 0.15
      workspace_swipe_min_speed_to_force = 5
      workspace_swipe_direction_lock = true
      workspace_swipe_direction_lock_threshold = 10
      workspace_swipe_create_new = true
    }

    gesture = $workspaceSwipeFingers, horizontal, workspace
    gesture = $gestureFingers, up, special, special
    gesture = $gestureFingers, down, dispatcher, exec, caelestia toggle specialws
  ''
  + (builtins.concatStringsSep "\n" [
    ""
    "# Show Keybinds"
    "bind = $mod $upr, K, exec, noctalia-shell ipc call plugin:keybind-cheatsheet toggle"
    ""
    "# Scroll through workspaces with super+scroll wheel"
    "bind = $mod, mouse_down, workspace, e-1"
    "bind = $mod, mouse_up, workspace, e+1"
    ""
    "# 1.Basic actions"
    "bind = $mod, C, killactive"
    "bind = $mod $upr, C, exec, hyprctl kill"
    "bind = $mod $upr, F, fullscreen"
    "bind = $mod CONTROL, F, togglefloating"
    "bind = $mod $upr, P, pseudo"
    ""
    "# 2.Change focus with super+arrows"
    "bind = $mod, left, movefocus, l"
    "bind = $mod, right, movefocus, r"
    "bind = $mod, up, movefocus, u"
    "bind = $mod, down, movefocus, d"
    ""
    "# Change window orientation with supershift+arrows"
    "bind = $mod $upr, left, movewindow, l"
    "bind = $mod $upr, right, movewindow, r"
    "bind = $mod $upr, up, movewindow, u"
    "bind = $mod $upr, down, movewindow, d"
    ""
    "# Change active window size with superctrl+arrows"
    "bind = $mod CONTROL, left, resizeactive, -50 0"
    "bind = $mod CONTROL, right, resizeactive, 50 0"
    "bind = $mod CONTROL, up, resizeactive, 0 -50"
    "bind = $mod CONTROL, down, resizeactive, 0 50"
    ""
    "# Media and volume controls"
    "bind = , XF86PowerOff, exec, hyprpanel t powermenu"
    "bind = , XF86AudioRaiseVolume, exec, volumectl -du up"
    "bind = , XF86AudioLowerVolume, exec, volumectl -du down"
    "bind = , XF86AudioMute, exec, volumectl -d toggle-mute"
    "bind = , XF86AudioMicMute, exec, volumectl -m toggle-mute"
    "bind = , XF86MonBrightnessUp, exec, lightctl -d up"
    "bind = , XF86MonBrightnessDown, exec, lightctl -d down"
    "bind = , XF86AudioNext, exec, playerctl next"
    "bind = , XF86AudioPlay, exec, playerctl play-pause"
    "bind = , XF86AudioPrev, exec, playerctl previous"
    ""
    "# Screenshot"
    "bind = , Print, exec, ~/bin/screenshot"
    ""
    "# Colorpicker"
    "bind = $mod ALT, P, exec, ~/bin/colorpicker"
    ""
    "# Clipboard"
    "bind = $mod, V, exec, copyq menu"
    ""
    "# Launch programs"
    "bind = $mod, RETURN, exec, kitty tmux"
    "bind = $mod, F, exec, pcmanfm"
    "bind = $mod, H, exec, kitty htop"
    "bind = $mod ALT, H, exec, kitty btop"
    "bind = $mod ALT, RETURN, exec, alacritty"
    "bind = $mod, W, exec, zen"
    "bind = $mod CONTROL, W, exec, firefox -P minimalfox"
    "bind = $mod ALT, W, exec, qutebrowser"
    "bind = $mod $upr, W, exec, firefox --private-window"
    "bind = $mod, E, exec, cursor"
    "bind = $mod ALT, E, exec, featherpad"
    "bind = $mod ALT, F, exec, pcmanfm"
    "bind = $mod ALT, M, exec, cantata"
    "bind = $mod, Z, exec, zathura"
    "bind = $mod, P, exec, keepassxc"
    "bind = $mod, G, exec, steam"
    ""
    "# Other applications"
    "bind = $mod ALT, D, exec, noctalia-shell ipc call controlCenter toggle"
    "bind = $mod ALT, N, exec,  noctalia-shell ipc call notifications toggleHistory"
    "bind = $mod, SUPER_L, exec, noctalia-shell ipc call launcher toggle"
    "bind = $mod, B, exec, hyprpanel t bluetoothmenu"
    "bind = $mod, Period, exec, plasma-emojier"
    "bind = $mod, X, exec, noctalia-shell ipc call sessionMenu toggle"
    "bind = $mod, D, exec, noctalia-shell ipc call wallpaper toggle"
    "bind = $mod, S, exec, noctalia-shell ipc call plugin:clipper toggle"
    "bind = $mod ALT, S, exec, hyprpanel t settings-dialog"
    "bind = $mod, Q, exec, hyprpanel t dashboardmenu"
    "bind = $mod, M, exec, hyprpanel t mediamenu"
    "bind = $mod, N, exec, hyprpanel t networkmenu"
    ""
    "# Passthrough"
    "bind = $mod $upr, Escape, submap, passthru"
    "bind = $mod, Escape, submap, reset"
    ""
    "# Special workspace bindings"
    "bind = $mod $upr, S, movetoworkspace, special"
    "bind = $mod, SPACE, togglespecialworkspace, special"
  ])
  + "\n"
  + (builtins.concatStringsSep "\n" (
    builtins.concatLists (
      builtins.genList (
        i:
        let
          ws = i + 1;
        in
        [
          "bind = $mod, code:1${toString i}, workspace, ${toString ws}"
          "bind = $mod $upr, code:1${toString i}, movetoworkspace, ${toString ws}"
        ]
      ) 9
    )
  ));
}
