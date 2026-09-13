{
  config,
  lib,
  ...
}:

{
  wayland.windowManager.hyprland = {
    settings.config = {
      plugin.scrolloverview = {
        # how far is the "max" for the gesture
        gesture_distance = 300;
        # preferred overview scale (niri default zoom ≈ 0.4)
        scale = 0.4;
        # gap between visible workspaces in the overview, in pixels
        workspace_gap = 40;
        # vertical, horizontal, or auto (per-monitor orientation)
        layout = "vertical";
        # 0: global only, 1: per-workspace only, 2: both
        wallpaper = 2;
        # blur only the main overview wallpaper
        blur = true;

        input = {
          # 0: layout-aware default, 1: inverted, 2: vertical scroll = workspace,
          #     horizontal scroll = columns, 3: the reverse
          scrolling_mode = 0;
          # 0: main button drags windows / middle pans, 1: reversed
          drag_mode = 0;
          # movement threshold before a press becomes drag/pan (px)
          drag_threshold = 10;
          touchpad_scroll_factor = 1;
          # delay between scroll events to prevent multiple activation (ms)
          scroll_event_delay = 200;
        };

        shadow = {
          enabled = true;
          range = 50;
        };
      };
    };

    extraConfig = ''
      if hl.plugin.scrolloverview then
        -- niri-style overview gesture: 4 fingers swipe up/down to toggle
        hl.plugin.scrolloverview.gesture({ fingers = 4, direction = "vertical" })

        -- Toggle the overview on all monitors (niri's toggle-overview)
        hl.bind("SUPER + g", function()
          hl.plugin.scrolloverview.overview("toggle all")
        end, { description = "Toggle workspace overview" })

        -- Keybind submap: auto-entered while the overview is open.
        -- closes on select/Escape, arrows navigate, SU+1..0 still switch
        -- workspaces (submap_universal keeps them active inside the submap).
        hl.define_submap("scrolloverview", function()
          hl.bind("left",   hl.plugin.scrolloverview.navigate("left"),   { description = "Overview: focus left" })
          hl.bind("right",  hl.plugin.scrolloverview.navigate("right"),  { description = "Overview: focus right" })
          hl.bind("up",     hl.plugin.scrolloverview.navigate("up"),     { description = "Overview: focus up" })
          hl.bind("down",   hl.plugin.scrolloverview.navigate("down"),   { description = "Overview: focus down" })
          hl.bind("return", hl.plugin.scrolloverview.overview("select"), { description = "Overview: select" })
          hl.bind("escape", hl.plugin.scrolloverview.overview("off"),    { description = "Overview: close" })
          hl.bind("SUPER + g", hl.plugin.scrolloverview.overview("toggle all"), { description = "Overview: toggle" })
          hl.bind("mouse:272", function()
            hl.plugin.scrolloverview.overview("select")
            hl.plugin.scrolloverview.window("select")
            hl.plugin.scrolloverview.overview("off")
          end, { mouse = true, description = "Overview: select clicked window" })
          hl.bind("mouse:274", hl.plugin.scrolloverview.window("close"), { mouse = true, description = "Overview: close clicked window" })
        end)

        for i = 1, 10 do
          local key = i % 10
          hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }), { submap_universal = true })
        end
      end
    '';
  };
}
