{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    local mod = "SUPER"
    local workspaceSwipeFingers = 3
    local gestureFingers = 3
    -- Super tap handler state; shared with the mouse binds below so that
    -- using the mouse while SUPER is held never triggers the launcher.
    local superTap = { armed = false }

    -- Mouse binds
    hl.bind(mod .. " + mouse:272", function()
      superTap.armed = false
      hl.dispatch(hl.dsp.window.drag())
    end, { mouse = true })
    hl.bind(mod .. " + mouse:273", function()
      superTap.armed = false
      hl.dispatch(hl.dsp.window.resize())
    end, { mouse = true })

    -- --------------------
    -- Gestures configuration
    -- --------------------
    hl.gesture({ fingers = workspaceSwipeFingers, direction = "vertical", action = "workspace" })
    -- horizontal swipe: drag the scrolling layout tape (no-op on other layouts)
    hl.gesture({ fingers = gestureFingers, direction = "horizontal", action = "scroll_move", scale = 3.5 })
    -- hl.gesture({ fingers = gestureFingers, direction = "up", action = function()
    --    hl.dispatch(hl.dsp.focus({ workspace = "e-1" }))
    -- end })
    -- hl.gesture({ fingers = gestureFingers, direction = "down", action = function()
    --     hl.dispatch(hl.dsp.focus({ workspace = "e+1" }))
    -- end })

    -- 2. WORKSPACE NAVIGATION
    hl.bind(mod .. " + mouse_down", function()
      superTap.armed = false
      hl.dispatch(hl.dsp.focus({ workspace = "e-1" }))
    end)
    hl.bind(mod .. " + mouse_up", function()
      superTap.armed = false
      hl.dispatch(hl.dsp.focus({ workspace = "e+1" }))
    end)

    -- 3. WINDOW MANAGEMENT
    hl.bind(mod .. " + C", hl.dsp.window.close())
    hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl kill"))
    hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen())
    hl.bind(mod .. " + CONTROL + F", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mod .. " + SHIFT + P", hl.dsp.window.pseudo())

    -- 4. FOCUS NAVIGATION
    hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }))
    hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }))
    hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }))
    hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }))

    -- 5. WINDOW MOVEMENT
    hl.bind(mod .. " + SHIFT + left", hl.dsp.layout("swapcol l"))
    hl.bind(mod .. " + SHIFT + right", hl.dsp.layout("swapcol r"))
    hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
    hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))
    hl.bind(mod .. " + SHIFT + ALT + left", hl.dsp.window.move({ direction = "l" }))
    hl.bind(mod .. " + SHIFT + ALT + right", hl.dsp.window.move({ direction = "r" }))

    -- 6. WINDOW RESIZING
    hl.bind(mod .. " + CONTROL + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
    hl.bind(mod .. " + CONTROL + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
    hl.bind(mod .. " + CONTROL + up", hl.dsp.layout("colresize +conf"))
    hl.bind(mod .. " + CONTROL + down", hl.dsp.layout("colresize -conf"))

    -- 7. MEDIA CONTROLS
    hl.bind("XF86PowerOff", hl.dsp.exec_cmd("hyprpanel t powermenu"))
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volumectl -bdu up"), { locked = true, repeating = true })
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volumectl -bdu down"), { locked = true, repeating = true })
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("volumectl -d toggle-mute"), { locked = true, repeating = true })
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("volumectl -m toggle-mute"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("lightctl -d up"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("lightctl -d down"), { locked = true, repeating = true })
    hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
    hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

    -- 8. SCREENSHOT AND TOOLS
    hl.bind(mod .. " + S", hl.dsp.exec_cmd("env QT_QPA_PLATFORM=wayland flameshot gui"))
    hl.bind(mod .. " + ALT + P", hl.dsp.exec_cmd("~/bin/colorpicker"))

    -- 9. APPLICATION LAUNCHERS
    hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("kitty tmux"))
    hl.bind(mod .. " + F", hl.dsp.exec_cmd("pcmanfm"))
    hl.bind(mod .. " + H", hl.dsp.exec_cmd("kitty htop"))
    hl.bind(mod .. " + ALT + H", hl.dsp.exec_cmd("kitty btop"))
    hl.bind(mod .. " + ALT + RETURN", hl.dsp.exec_cmd("alacritty"))
    hl.bind(mod .. " + W", hl.dsp.exec_cmd("zen"))
    hl.bind(mod .. " + CONTROL + W", hl.dsp.exec_cmd("firefox -P minimalfox"))
    hl.bind(mod .. " + ALT + W", hl.dsp.exec_cmd("qutebrowser"))
    hl.bind(mod .. " + SHIFT + W", hl.dsp.exec_cmd("firefox --private-window"))
    hl.bind(mod .. " + E", hl.dsp.exec_cmd("cursor --classic"))
    hl.bind(mod .. " + ALT + E", hl.dsp.exec_cmd("kate"))
    hl.bind(mod .. " + ALT + F", hl.dsp.exec_cmd("dolphin"))
    hl.bind(mod .. " + ALT + M", hl.dsp.exec_cmd("cantata"))
    hl.bind(mod .. " + Z", hl.dsp.exec_cmd("zathura"))
    hl.bind(mod .. " + P", hl.dsp.exec_cmd("keepassxc"))
    hl.bind(mod .. " + G", hl.dsp.exec_cmd("lutris"))

    -- 10. SYSTEM CONTROLS
    hl.bind(mod .. " + CONTROL + ALT + R", hl.dsp.exec_cmd("hyprctl reload"))
    hl.bind(mod .. " + ALT + D", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
    hl.bind(mod .. " + ALT + N", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center notifications"))
    -- 1. LAUNCHER (bare SUPER tap only, not part of a chord)
    hl.bind(mod .. " + SUPER_L", function()
      superTap.armed = true
    end)
    hl.on("input.keyboard.key", function(keycode, _, state)
      if state == 1 and keycode ~= 133 and keycode ~= 134 and superTap.armed then
        superTap.armed = false
      end
    end)
    hl.bind(mod .. " + SUPER_L", function()
      if superTap.armed then
        hl.exec_cmd("noctalia msg panel-toggle launcher")
      end
      superTap.armed = false
    end, { release = true })
    hl.bind(mod .. " + TAB", hl.dsp.exec_cmd("noctalia msg window-switcher"))
    hl.bind(mod .. " + B", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center bluetooth"))
    hl.bind(mod .. " + Period", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher /emo"))
    hl.bind(mod .. " + X", hl.dsp.exec_cmd("noctalia msg panel-toggle session"))
    hl.bind(mod .. " + D", hl.dsp.exec_cmd("noctalia msg panel-toggle wallpaper"))
    hl.bind(mod .. " + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))
    hl.bind(mod .. " + ALT + S", hl.dsp.exec_cmd("noctalia msg settings-open"))
    -- hl.bind(mod .. " + Q", hl.dsp.exec_cmd("hyprctl dispatch overview:toggle"))
    hl.bind(mod .. " + M", hl.dsp.exec_cmd("noctalia msg media toggle"))
    hl.bind(mod .. " + N", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center network"))

    -- 11. SUBMAPS
    hl.bind(mod .. " + SHIFT + escape", hl.dsp.submap("passthru"))
    hl.bind(mod .. " + escape", hl.dsp.submap("reset"))

    -- 12. SCRATCHPAD (special workspace)
    hl.bind(mod .. " + SHIFT + SPACE", hl.dsp.window.move({ workspace = "special:scratchpad" }))
    hl.bind(mod .. " + SPACE", hl.dsp.workspace.toggle_special("scratchpad"))
    hl.bind(mod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("[workspace special:scratchpad] kitty tmux"))

    -- Workspace navigation
    for i = 1, 9 do
      hl.bind(mod .. " + code:1" .. (i - 1), hl.dsp.focus({ workspace = i }))
      hl.bind(mod .. " + SHIFT + code:1" .. (i - 1), hl.dsp.window.move({ workspace = i }))
    end

    -- Passthrough submap
    hl.define_submap("passthru", "reset", function()
      hl.bind("escape", hl.dsp.submap("reset"))
    end)
  '';
}
