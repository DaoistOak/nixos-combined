{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    -- Gestures configuration
    local workspaceSwipeFingers = 3
    local gestureFingers = 3
    hl.gesture({ fingers = workspaceSwipeFingers, direction = "vertical", action = "workspace" })
    -- horizontal swipe: drag the scrolling layout tape (no-op on other layouts)
    hl.gesture({ fingers = gestureFingers, direction = "horizontal", action = "scroll_move", scale = 3.5 })
  '';
}
