{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    -- Gestures configuration
    local workspaceSwipeFingers = 3
    local gestureFingers = 4
    hl.gesture({ fingers = workspaceSwipeFingers, direction = "vertical", action = "workspace" })
    hl.gesture({ fingers = gestureFingers, direction = "horizontal", action = "scroll_move", scale = 1.2 })
  '';
}
