{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    local mod = "SUPER"
    local workspaceSwipeFingers = 3
    local gestureFingers = 3
    local scripts = "${config.xdg.configHome}/hypr/scripts"
    -- Super tap handler state; shared with the mouse binds below so that
    -- using the mouse while SUPER is held never triggers the launcher.
    local superTap = { armed = false }

    -- Triple-space tap detector: three quick SUPER+SPACE presses open the
    -- window switcher (the "tab" gesture). Single/double presses stay silent.
    local spaceTap = { count = 0 }
    local spaceTapTimer = hl.timer(function()
      spaceTap.count = 0
      spaceTapTimer:set_enabled(false)
    end, { timeout = 600, type = "repeat" })
    spaceTapTimer:set_enabled(false)

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

    -- 1. GLOBAL DIRECT
    hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("wezterm start tmux"))
    hl.bind(mod .. " + C", hl.dsp.window.close())
    hl.bind(mod .. " + X", hl.dsp.exec_cmd("noctalia msg panel-toggle session"))
    hl.bind(mod .. " + K", hl.dsp.exec_cmd("noctalia msg panel-toggle kenn/keybind-cheatsheet:cheatsheet"))
    hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd("qs ipc -c themeswitcher call themeswitcher toggle"))
    hl.bind(mod .. " + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))
    hl.bind(mod .. " + D", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
    hl.bind(mod .. " + SHIFT + W", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center weather"))
    -- tab (window switcher) lives on the space gestures: SUPER+SHIFT+SPACE
    -- and three quick SUPER+SPACE taps.
    hl.bind(mod .. " + SHIFT + SPACE", hl.dsp.exec_cmd("noctalia msg window-switcher"))
    hl.bind(mod .. " + SPACE", function()
      spaceTap.count = spaceTap.count + 1
      if spaceTap.count >= 3 then
        spaceTap.count = 0
        spaceTapTimer:set_enabled(false)
        hl.dispatch(hl.dsp.exec_cmd("noctalia msg window-switcher"))
        return
      end
      spaceTapTimer:set_timeout(600)
      spaceTapTimer:set_enabled(true)
    end)

    -- 2. MODE ENTERS
    hl.bind(mod .. " + T", hl.dsp.submap("terminal-apps"))
    hl.bind(mod .. " + S", hl.dsp.submap("shell"))
    hl.bind(mod .. " + E", hl.dsp.submap("apps"))
    hl.bind(mod .. " + M", hl.dsp.submap("messaging"))
    hl.bind(mod .. " + W", hl.dsp.submap("windows"))

    -- 3. WORKSPACE NAVIGATION
    for i = 1, 9 do
      hl.bind(mod .. " + code:1" .. (i - 1), hl.dsp.focus({ workspace = i }))
      hl.bind(mod .. " + SHIFT + code:1" .. (i - 1), hl.dsp.window.move({ workspace = i }))
    end
    hl.bind(mod .. " + code:19", hl.dsp.focus({ workspace = 10 }))
    hl.bind(mod .. " + SHIFT + code:19", hl.dsp.window.move({ workspace = 10 }))
    hl.bind(mod .. " + mouse_down", function()
      superTap.armed = false
      hl.dispatch(hl.dsp.focus({ workspace = "e-1" }))
    end)
    hl.bind(mod .. " + mouse_up", function()
      superTap.armed = false
      hl.dispatch(hl.dsp.focus({ workspace = "e+1" }))
    end)

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
    hl.bind("XF86PowerOff", hl.dsp.exec_cmd("noctalia msg panel-toggle session"), { locked = true })
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volumectl -bdu up"), { locked = true, repeating = true })
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volumectl -bdu down"), { locked = true, repeating = true })
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("volumectl -d toggle-mute"), { locked = true, repeating = true })
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("volumectl -m toggle-mute"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("lightctl -d up"), { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("lightctl -d down"), { locked = true, repeating = true })
    hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
    hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
    hl.bind("XF86RFKill", hl.dsp.exec_cmd(scripts .. "/airplane-mode.sh"), { locked = true })
    hl.bind("XF86SelectiveScreenshot", hl.dsp.exec_cmd("noctalia msg screenshot-region"), { locked = true })

    -- 8. TOOLS
    hl.bind(mod .. " + ALT + P", hl.dsp.exec_cmd("~/bin/colorpicker"))

    -- 9. LAUNCHER (bare SUPER tap only, not part of a chord)
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
        hl.exec_cmd(scripts .. "/super-tap-launcher.sh")
      end
      superTap.armed = false
    end, { release = true })

    -- 10. SYSTEM
    hl.bind(mod .. " + CONTROL + ALT + R", hl.dsp.exec_cmd("hyprctl reload"))

    -- 11. PASSTHROUGH SUBMAP
    hl.bind(mod .. " + SHIFT + escape", hl.dsp.submap("passthru"))
    hl.define_submap("passthru", "reset", function()
      hl.bind("escape", hl.dsp.submap("reset"))
    end)

    -- 12. TERMINAL-APPS MODE (SUPER+T)
    hl.define_submap("terminal-apps", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("wezterm start tmux"))
      hl.bind("B", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh btop"))
      hl.bind("C", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh cava"))
      hl.bind("N", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh tmux new-session -A -s nvim nvim"))
      hl.bind("H", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh tmux new-session -A -s herdr herdr"))
      hl.bind("D", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh"))
      hl.bind("S", hl.dsp.exec_cmd(scripts .. "/switch-default-terminal.sh"))
      hl.bind("F", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh fastfetch"))
      hl.bind("O", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh --cwd $HOME/.config/nixos"))
      hl.bind("A", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh --cwd $HOME opencode"))
      hl.bind("I", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh --hold hyprctl info"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)

    -- 13. SHELL MODE (SUPER+S)
    hl.define_submap("shell", "reset", function()
      hl.bind("B", hl.dsp.submap("shell-bluetooth"))
      hl.bind("N", hl.dsp.submap("shell-network"))
      hl.bind("SHIFT + N", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center notifications"))
      hl.bind("S", hl.dsp.exec_cmd("noctalia msg screenshot-region"))
      hl.bind("SHIFT + S", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call plugin:screen-recorder toggle"))
      hl.bind("Q", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
      hl.bind("M", hl.dsp.exec_cmd("noctalia msg media toggle"))
      hl.bind("W", hl.dsp.exec_cmd("noctalia msg panel-toggle wallpaper"))
      hl.bind("R", hl.dsp.exec_cmd("systemctl --user restart noctalia-shell"))
      hl.bind("P", hl.dsp.exec_cmd("~/bin/colorpicker"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)
    hl.define_submap("shell-bluetooth", "reset", function()
      hl.bind("o", hl.dsp.exec_cmd(scripts .. "/launch-bluetooth.sh open"))
      hl.bind("c", hl.dsp.exec_cmd(scripts .. "/launch-bluetooth.sh close"))
      hl.bind("a", hl.dsp.exec_cmd(scripts .. "/launch-bluetooth.sh auto"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)
    hl.define_submap("shell-network", "reset", function()
      hl.bind("o", hl.dsp.exec_cmd(scripts .. "/launch-network.sh open"))
      hl.bind("c", hl.dsp.exec_cmd(scripts .. "/launch-network.sh close"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)

    -- 14. APPS MODE (SUPER+E)
    hl.define_submap("apps", "reset", function()
      hl.bind("W", hl.dsp.submap("apps-web"))
      hl.bind("E", hl.dsp.submap("apps-editor"))
      hl.bind("F", hl.dsp.submap("apps-file"))
      hl.bind("M", hl.dsp.submap("apps-media"))
      hl.bind("G", hl.dsp.submap("apps-games"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)
    hl.define_submap("apps-web", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("zen"))
      hl.bind("B", hl.dsp.exec_cmd("brave"))
      hl.bind("Z", hl.dsp.exec_cmd("zen"))
      hl.bind("F", hl.dsp.exec_cmd("firefox"))
      hl.bind("SHIFT + F", hl.dsp.exec_cmd("firefox --private-window"))
      hl.bind("Q", hl.dsp.exec_cmd("qutebrowser"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)
    hl.define_submap("apps-editor", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("cursor --classic"))
      hl.bind("C", hl.dsp.exec_cmd("cursor --classic"))
      hl.bind("K", hl.dsp.exec_cmd("kate"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)
    hl.define_submap("apps-file", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi"))
      hl.bind("D", hl.dsp.exec_cmd("dolphin"))
      hl.bind("Y", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi"))
      hl.bind("P", hl.dsp.exec_cmd("pcmanfm"))
      hl.bind("C", hl.dsp.submap("apps-file-open"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)
    hl.define_submap("apps-file-open", "reset", function()
      hl.bind("H", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME"))
      hl.bind("D", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME/Downloads"))
      hl.bind("P", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME/Pictures"))
      hl.bind("C", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME/Documents"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)
    hl.define_submap("apps-media", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("cantata"))
      hl.bind("C", hl.dsp.exec_cmd("cantata"))
      hl.bind("m", hl.dsp.exec_cmd("mpv"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)
    hl.define_submap("apps-games", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("lutris"))
      hl.bind("S", hl.dsp.exec_cmd("steam"))
      hl.bind("L", hl.dsp.exec_cmd("lutris"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)

    -- 15. MESSAGING MODE (SUPER+M)
    hl.define_submap("messaging", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("viber"))
      hl.bind("V", hl.dsp.submap("messaging-viber"))
      hl.bind("T", hl.dsp.exec_cmd("telegram-desktop"))
      hl.bind("D", hl.dsp.exec_cmd("vesktop"))
      hl.bind("W", hl.dsp.submap("messaging-whatsapp"))
      hl.bind("M", hl.dsp.exec_cmd("messenger"))
      hl.bind("A", hl.dsp.exec_cmd("sh -c 'viber & vesktop & zapzap &'"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)
    hl.define_submap("messaging-viber", "reset", function()
      hl.bind("D", hl.dsp.exec_cmd("xdg-open $HOME/Downloads"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)
    hl.define_submap("messaging-whatsapp", "reset", function()
      hl.bind("D", hl.dsp.exec_cmd("xdg-open $HOME/Downloads"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)

    -- 16. WINDOWS MODE (SUPER+W)
    hl.define_submap("windows", "reset", function()
      hl.bind("F", hl.dsp.window.fullscreen())
      hl.bind("T", hl.dsp.window.float({ action = "toggle" }))
      hl.bind("K", hl.dsp.window.close())
      hl.bind("P", hl.dsp.window.pseudo())
      hl.bind("S", hl.dsp.workspace.toggle_special("scratchpad"))
      hl.bind("SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))
      hl.bind("G", hl.dsp.exec_cmd(scripts .. "/toggle-performance.sh"))
      hl.bind("escape", hl.dsp.submap("reset"))
    end)
  '';
}
