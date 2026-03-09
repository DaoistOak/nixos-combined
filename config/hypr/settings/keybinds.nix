{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    $mod = SUPER
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

    # 1. KEYBIND CHEATSHEET
    bind = $mod SHIFT, K, exec, noctalia-shell ipc call plugin:keybind-cheatsheet toggle #"Show Keybinds"

    # 2. WORKSPACE NAVIGATION
    bind = $mod, mouse_down, workspace, e-1 #"Previous workspace (scroll down)"
    bind = $mod, mouse_up, workspace, e+1 #"Next workspace (scroll up)"

    # 3. WINDOW MANAGEMENT
    bind = $mod, C, killactive #"Close active window"
    bind = $mod SHIFT, C, exec, hyprctl kill #"Force kill active window"
    bind = $mod SHIFT, F, fullscreen #"Toggle fullscreen"
    bind = $mod CONTROL, F, togglefloating #"Toggle floating"
    bind = $mod SHIFT, P, pseudo #"Toggle pseudo mode"

    # 4. FOCUS NAVIGATION
    bind = $mod, left, movefocus, l #"Focus left"
    bind = $mod, right, movefocus, r #"Focus right"
    bind = $mod, up, movefocus, u #"Focus up"
    bind = $mod, down, movefocus, d #"Focus down"

    # 5. WINDOW MOVEMENT
    bind = $mod SHIFT, left, movewindow, l #"Move window left"
    bind = $mod SHIFT, right, movewindow, r #"Move window right"
    bind = $mod SHIFT, up, movewindow, u #"Move window up"
    bind = $mod SHIFT, down, movewindow, d #"Move window down"

    # 6. WINDOW RESIZING
    bind = $mod CONTROL, left, resizeactive, -50 0 #"Shrink width left"
    bind = $mod CONTROL, right, resizeactive, 50 0 #"Grow width right"
    bind = $mod CONTROL, up, resizeactive, 0 -50 #"Shrink height up"
    bind = $mod CONTROL, down, resizeactive, 0 50 #"Grow height down"

    # 7. MEDIA CONTROLS
    bind = , XF86PowerOff, exec, hyprpanel t powermenu #"Power menu"
    bind = , XF86AudioRaiseVolume, exec, volumectl -du up #"Volume up"
    bind = , XF86AudioLowerVolume, exec, volumectl -du down #"Volume down"
    bind = , XF86AudioMute, exec, volumectl -d toggle-mute #"Toggle mute"
    bind = , XF86AudioMicMute, exec, volumectl -m toggle-mute #"Toggle mic mute"
    bind = , XF86MonBrightnessUp, exec, lightctl -d up #"Brightness up"
    bind = , XF86MonBrightnessDown, exec, lightctl -d down #"Brightness down"
    bind = , XF86AudioNext, exec, playerctl next #"Next track"
    bind = , XF86AudioPlay, exec, playerctl play-pause #"Play/pause"
    bind = , XF86AudioPrev, exec, playerctl previous #"Previous track"

    # 8. SCREENSHOT AND TOOLS
    bind = , Print, exec, ~/bin/screenshot #"Take screenshot"
    bind = $mod ALT, P, exec, ~/bin/colorpicker #"Color picker"
    bind = $mod, V, exec, copyq menu #"Clipboard menu"

    # 9. APPLICATION LAUNCHERS
    bind = $mod, RETURN, exec, kitty tmux #"Terminal (Kitty + Tmux)"
    bind = $mod, F, exec, pcmanfm #"File manager"
    bind = $mod, H, exec, kitty htop #"System monitor (Htop)"
    bind = $mod ALT, H, exec, kitty btop #"System monitor (Btop)"
    bind = $mod ALT, RETURN, exec, alacritty #"Terminal (Alacritty)"
    bind = $mod, W, exec, zen #"Web browser (Zen)"
    bind = $mod CONTROL, W, exec, firefox -P minimalfox #"Web browser (Firefox Minimal)"
    bind = $mod ALT, W, exec, qutebrowser #"Web browser (Qutebrowser)"
    bind = $mod SHIFT, W, exec, firefox --private-window #"Private browser"
    bind = $mod, E, exec, cursor #"Text editor (Cursor)"
    bind = $mod ALT, E, exec, featherpad #"Text editor (Featherpad)"
    bind = $mod ALT, F, exec, pcmanfm #"File manager (alt)"
    bind = $mod ALT, M, exec, cantata #"Music player"
    bind = $mod, Z, exec, zathura #"PDF viewer"
    bind = $mod, P, exec, keepassxc #"Password manager"
    bind = $mod, G, exec, steam #"Game launcher"

    # 10. SYSTEM CONTROLS
    bind = $mod ALT, D, exec, noctalia-shell ipc call controlCenter toggle #"Control center"
    bind = $mod ALT, N, exec,  noctalia-shell ipc call notifications toggleHistory #"Notifications history"
    bind = $mod, SUPER_L, exec, noctalia-shell ipc call launcher toggle #"Launcher"
    bind = $mod, B, exec, hyprpanel t bluetoothmenu #"Bluetooth menu"
    bind = $mod, Period, exec, noctalia-shell ipc call launcher emoji #"Emoji picker"
    bind = $mod, X, exec, noctalia-shell ipc call sessionMenu toggle #"Session menu"
    bind = $mod, D, exec, noctalia-shell ipc call wallpaper toggle #"Wallpaper selector"
    bind = $mod, S, exec, noctalia-shell ipc call plugin:clipper toggle #"Clipboard manager"
    bind = $mod ALT, S, exec, noctalia-shell ipc call settings open #"Settings dialog"
    bind = $mod, Q, exec,  #"Dashboard menu"
    bind = $mod, M, exec, noctalia-shell ipc call media toggle #"Media menu"
    bind = $mod, N, exec, noctalia-shell ipc call wifi toggle #"Network menu"

    # 11. SUBMAPS
    bind = $mod SHIFT, Escape, submap, passthru #"Enter passthrough mode"
    bind = $mod, Escape, submap, reset #"Reset submap"

    # 12. SPECIAL WORKSPACE
    bind = $mod SHIFT, S, movetoworkspace, special #"Move to special workspace"
    bind = $mod, SPACE, togglespecialworkspace, special #"Toggle special workspace"
  ''
  + "\n"
  + (builtins.concatStringsSep "\n" (
    builtins.concatLists (
      builtins.genList (
        i:
        let
          ws = i + 1;
        in
        [
          "bind = $mod, code:1${toString i}, workspace, ${toString ws} #\"Workspace ${toString ws}\""
          "bind = $mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws} #\"Move to workspace ${toString ws}\""
        ]
      ) 9
    )
  ));
}
