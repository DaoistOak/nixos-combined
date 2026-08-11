{
  config,
  lib,
  ...
}:

{
  wayland.windowManager.hyprland = {
    settings.config = {
      plugin.hyprgrass = {
        # Touchscreens report jittery positions; raise the default sensitivity
        sensitivity = 4.0;
        long_press_delay = 400;
        resize_on_border_long_press = true;
      };
      gestures = {
        workspace_swipe_touch = true;
        workspace_swipe_cancel_ratio = 0.15;
      };
    };

    extraConfig = ''
      if hl.plugin.hyprgrass then
        -- workspace swipe: 3 fingers up = previous, down = next
        hl.plugin.hyprgrass.gesture {
          pattern = { kind = "swipe", fingers = 3, direction = "up" },
          action = hl.dsp.focus({ workspace = "e-1" }),
        }
        hl.plugin.hyprgrass.gesture {
          pattern = { kind = "swipe", fingers = 3, direction = "down" },
          action = hl.dsp.focus({ workspace = "e+1" }),
        }

        -- top edge swipe down: launcher
        hl.plugin.hyprgrass.bind {
          pattern = { kind = "edge", origin = "up", direction = "down" },
          action = hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"),
        }

        -- long press with 3 fingers: drag window
        hl.plugin.hyprgrass.bind {
          pattern = { kind = "longpress", fingers = 3 },
          action = hl.dsp.window.drag(),
          mouse = true,
        }
      end
    '';
  };
}
