{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    "$upr" = "SHIFT";
    "$workspaceSwipeFingers" = "3";
    "$gestureFingers" = "3";

    bindm = [
      "SUPER, mouse:272, movewindow"
      "SUPER, mouse:273, resizewindow"
    ];

    # --------------------
    # Gestures configuration
    # --------------------
    gestures = {
      workspace_swipe_distance = 700;
      workspace_swipe_cancel_ratio = 0.15;
      workspace_swipe_min_speed_to_force = 5;
      workspace_swipe_direction_lock = true;
      workspace_swipe_direction_lock_threshold = 10;
      workspace_swipe_create_new = true;
    };

    gesture = [
      "$workspaceSwipeFingers, horizontal, workspace"
      "$gestureFingers, up, special, special"
      "$gestureFingers, down, dispatcher, exec, caelestia toggle specialws"
    ];

    bind = [
      # Show Keybinds
      "$mod $upr, K, exec, nocatalia-shell ipc call plugin:keybind-cheatsheet toggle"

      # Scroll through workspaces with super+scroll wheel
      "$mod, mouse_down, workspace, e-1"
      "$mod, mouse_up, workspace, e+1"

      # Basic actions
      "$mod, C, killactive"
      "$mod $upr, C, exec, hyprctl kill"
      "$mod $upr, F, fullscreen"
      "$mod CONTROL, F, togglefloating"
      "$mod $upr, P, pseudo"

      # Change focus with super+arrows
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"

      # Change window orientation with supershift+arrows
      "$mod $upr, left, movewindow, l"
      "$mod $upr, right, movewindow, r"
      "$mod $upr, up, movewindow, u"
      "$mod $upr, down, movewindow, d"

      # Change active window size with superctrl+arrows
      "$mod CONTROL, left, resizeactive, -50 0"
      "$mod CONTROL, right, resizeactive, 50 0"
      "$mod CONTROL, up, resizeactive, 0 -50"
      "$mod CONTROL, down, resizeactive, 0 50"

      # Media and volume controls
      ", XF86PowerOff, exec, hyprpanel t powermenu"
      ", XF86AudioRaiseVolume, exec, volumectl -du up"
      ", XF86AudioLowerVolume, exec, volumectl -du down"
      ", XF86AudioMute, exec, volumectl -d toggle-mute"
      ", XF86AudioMicMute, exec, volumectl -m toggle-mute"
      ", XF86MonBrightnessUp, exec, lightctl -d up"
      ", XF86MonBrightnessDown, exec, lightctl -d down"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"

      # Screenshot
      ", Print, exec, ~/bin/screenshot"

      # Colorpicker
      "$mod ALT, P, exec, ~/bin/colorpicker"

      # Clipboard
      "$mod, V, exec, copyq menu"

      # Launch programs
      "$mod, RETURN, exec, kitty tmux"
      "$mod, F, exec, pcmanfm"
      "$mod, H, exec, kitty htop"
      "$mod ALT, H, exec, kitty btop"
      "$mod ALT, RETURN, exec, alacritty"
      "$mod, W, exec, zen"
      "$mod CONTROL, W, exec, firefox -P minimalfox"
      "$mod ALT, W, exec, qutebrowser"
      "$mod $upr, W, exec, firefox --private-window"
      "$mod, E, exec, cursor"
      "$mod ALT, E, exec, featherpad"
      "$mod ALT, F, exec, pcmanfm"
      "$mod ALT, M, exec, cantata"
      "$mod, Z, exec, zathura"
      "$mod, P, exec, keepassxc"
      "$mod, G, exec, steam"

      # Other applications
      "$mod ALT, D, exec, noctalia-shell ipc call controlCenter toggle"
      "$mod ALT, N, exec,  noctalia-shell ipc call notifications toggleHistory"
      "$mod, SUPER_L, exec, noctalia-shell ipc call launcher toggle"
      "$mod, B, exec, noctalia-shell ipc call bluetooth toggle"
      "$mod, Period, exec, noctalia-shell ipc call laucher emoji"
      "$mod, X, exec, noctalia-shell ipc call sessionMenu toggle"
      "$mod, D, exec, noctalia-shell ipc call wallpaper toggle"
      "$mod, S, exec, noctalia-shell ipc call plugin:clipper toggle"
      "$mod ALT, S, exec, noctalia-shell ipc call settings toggle"
      "$mod, Q, exec, "
      "$mod, M, exec, nocatalia-shell ipc call media toggle"
      "$mod, N, exec, noctalia-shell ipc call wifi toggle"

      # Passthrough
      "$mod $upr, Escape, submap, passthru"
      "$mod, Escape, submap, reset"

      # Special workspace bindings
      "$mod $upr, S, movetoworkspace, special"
      "$mod, SPACE, togglespecialworkspace, special"
    ]
    ++ (builtins.concatLists (
      builtins.genList (
        i:
        let
          ws = i + 1;
        in
        [
          "$mod, code:1${toString i}, workspace, ${toString ws}"
          "$mod $upr, code:1${toString i}, movetoworkspace, ${toString ws}"
        ]
      ) 9
    ));
  };
}
