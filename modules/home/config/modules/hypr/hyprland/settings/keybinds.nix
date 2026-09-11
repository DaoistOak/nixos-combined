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
    end, { mouse = true, description = "Drag window" })
    hl.bind(mod .. " + mouse:273", function()
      superTap.armed = false
      hl.dispatch(hl.dsp.window.resize())
    end, { mouse = true, description = "Resize window" })

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
    hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("wezterm start tmux"), { description = "Terminal (wezterm + tmux)" })
    hl.bind(mod .. " + C", hl.dsp.window.close(), { description = "Close window" })
    hl.bind(mod .. " + X", hl.dsp.exec_cmd("noctalia msg panel-toggle session"), { description = "Session menu" })
    hl.bind(mod .. " + K", hl.dsp.exec_cmd("noctalia msg panel-toggle kenn/keybind-cheatsheet:cheatsheet"), { description = "Toggle keybind cheatsheet" })
    hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd("qs ipc -c themeswitcher call themeswitcher toggle"), { description = "Cycle theme" })
    hl.bind(mod .. " + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"), { description = "Clipboard menu" })
    hl.bind(mod .. " + D", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"), { description = "Control center" })
    hl.bind(mod .. " + SHIFT + W", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center weather"), { description = "Weather panel" })
    -- tab (window switcher) lives on the space gestures: SUPER+SHIFT+SPACE
    -- and three quick SUPER+SPACE taps.
    hl.bind(mod .. " + SHIFT + SPACE", hl.dsp.exec_cmd("noctalia msg window-switcher"), { description = "Window switcher (tab)" })
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
    end, { description = "Window switcher (triple tap)" })

    -- 2. MODE ENTERS
    hl.bind(mod .. " + T", hl.dsp.submap("terminal-apps"), { description = "Enter terminal-apps mode" })
    hl.bind(mod .. " + S", hl.dsp.submap("shell"), { description = "Enter shell mode" })
    hl.bind(mod .. " + E", hl.dsp.submap("apps"), { description = "Enter apps mode" })
    hl.bind(mod .. " + M", hl.dsp.submap("messaging"), { description = "Enter messaging mode" })
    hl.bind(mod .. " + W", hl.dsp.submap("windows"), { description = "Enter windows mode" })

    -- 3. WORKSPACE NAVIGATION
    for i = 1, 9 do
      hl.bind(mod .. " + code:1" .. (i - 1), hl.dsp.focus({ workspace = i }), { description = "Workspace " .. i })
      hl.bind(mod .. " + SHIFT + code:1" .. (i - 1), hl.dsp.window.move({ workspace = i }), { description = "Move window to workspace " .. i })
    end
    hl.bind(mod .. " + code:19", hl.dsp.focus({ workspace = 10 }), { description = "Workspace 10" })
    hl.bind(mod .. " + SHIFT + code:19", hl.dsp.window.move({ workspace = 10 }), { description = "Move window to workspace 10" })
    hl.bind(mod .. " + mouse_down", function()
      superTap.armed = false
      hl.dispatch(hl.dsp.focus({ workspace = "e-1" }))
    end, { description = "Previous workspace" })
    hl.bind(mod .. " + mouse_up", function()
      superTap.armed = false
      hl.dispatch(hl.dsp.focus({ workspace = "e+1" }))
    end, { description = "Next workspace" })

    -- 4. FOCUS NAVIGATION
    hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }), { description = "Focus left" })
    hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }), { description = "Focus right" })
    hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }), { description = "Focus up" })
    hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }), { description = "Focus down" })

    -- 5. WINDOW MOVEMENT
    hl.bind(mod .. " + SHIFT + left", hl.dsp.layout("swapcol l"), { description = "Move window left" })
    hl.bind(mod .. " + SHIFT + right", hl.dsp.layout("swapcol r"), { description = "Move window right" })
    hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }), { description = "Move window up" })
    hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }), { description = "Move window down" })
    hl.bind(mod .. " + SHIFT + ALT + left", hl.dsp.window.move({ direction = "l" }), { description = "Move window left (keep column)" })
    hl.bind(mod .. " + SHIFT + ALT + right", hl.dsp.window.move({ direction = "r" }), { description = "Move window right (keep column)" })

    -- 6. WINDOW RESIZING
    hl.bind(mod .. " + CONTROL + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { description = "Resize window smaller" })
    hl.bind(mod .. " + CONTROL + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { description = "Resize window larger" })
    hl.bind(mod .. " + CONTROL + up", hl.dsp.layout("colresize +conf"), { description = "Resize column taller" })
    hl.bind(mod .. " + CONTROL + down", hl.dsp.layout("colresize -conf"), { description = "Resize column shorter" })

    -- 7. MEDIA CONTROLS
    hl.bind("XF86PowerOff", hl.dsp.exec_cmd("noctalia msg panel-toggle session"), { locked = true, description = "Power menu" })
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volumectl -bdu up"), { locked = true, repeating = true, description = "Volume up" })
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volumectl -bdu down"), { locked = true, repeating = true, description = "Volume down" })
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("volumectl -d toggle-mute"), { locked = true, repeating = true, description = "Toggle mute" })
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("volumectl -m toggle-mute"), { locked = true, repeating = true, description = "Toggle mic mute" })
    hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("lightctl -d up"), { locked = true, repeating = true, description = "Brightness up" })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("lightctl -d down"), { locked = true, repeating = true, description = "Brightness down" })
    hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "Next track" })
    hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/pause" })
    hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "Previous track" })
    hl.bind("XF86RFKill", hl.dsp.exec_cmd(scripts .. "/airplane-mode.sh"), { locked = true, description = "Toggle airplane mode" })
    hl.bind("XF86SelectiveScreenshot", hl.dsp.exec_cmd("noctalia msg screenshot-region"), { locked = true, description = "Screenshot region" })

    -- 8. TOOLS
    hl.bind(mod .. " + ALT + P", hl.dsp.exec_cmd("~/bin/colorpicker"), { description = "Color picker" })

    -- 9. LAUNCHER (bare SUPER tap only, not part of a chord)
    hl.bind(mod .. " + SUPER_L", function()
      superTap.armed = true
    end, { description = "Launcher (hold SUPER)" })
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
    end, { release = true, description = "Launcher (hold SUPER)" })

    -- 10. SYSTEM
    hl.bind(mod .. " + CONTROL + ALT + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland" })

    -- 11. PASSTHROUGH SUBMAP
    hl.bind(mod .. " + SHIFT + escape", hl.dsp.submap("passthru"), { description = "Enter passthrough mode" })
    hl.define_submap("passthru", "reset", function()
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit passthrough mode" })
    end)

    -- 12. TERMINAL-APPS MODE (SUPER+T)
    hl.define_submap("terminal-apps", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("wezterm start tmux"), { description = "Terminal (wezterm + tmux)" })
      hl.bind("B", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh btop"), { description = "btop monitor" })
      hl.bind("C", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh cava"), { description = "cava visualizer" })
      hl.bind("N", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh tmux new-session -A -s nvim nvim"), { description = "Neovim" })
      hl.bind("H", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh tmux new-session -A -s herdr herdr"), { description = "herdr" })
      hl.bind("D", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh"), { description = "Default terminal" })
      hl.bind("S", hl.dsp.exec_cmd(scripts .. "/switch-default-terminal.sh"), { description = "Switch default terminal" })
      hl.bind("F", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh fastfetch"), { description = "fastfetch" })
      hl.bind("O", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh --cwd $HOME/.config/nixos"), { description = "Shell in nixos config" })
      hl.bind("A", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh --cwd $HOME opencode"), { description = "OpenCode" })
      hl.bind("I", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh --hold hyprctl info"), { description = "Hyprland info" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)

    -- 13. SHELL MODE (SUPER+S)
    hl.define_submap("shell", "reset", function()
      hl.bind("B", hl.dsp.submap("shell-bluetooth"), { description = "Bluetooth submenu" })
      hl.bind("N", hl.dsp.submap("shell-network"), { description = "Network submenu" })
      hl.bind("SHIFT + N", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center notifications"), { description = "Notifications" })
      hl.bind("S", hl.dsp.exec_cmd("noctalia msg screenshot-region"), { description = "Screenshot region" })
      hl.bind("SHIFT + S", hl.dsp.exec_cmd("qs -c noctalia-shell ipc call plugin:screen-recorder toggle"), { description = "Toggle screen recorder" })
      hl.bind("Q", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"), { description = "Control center" })
      hl.bind("M", hl.dsp.exec_cmd("noctalia msg media toggle"), { description = "Media menu" })
      hl.bind("W", hl.dsp.exec_cmd("noctalia msg panel-toggle wallpaper"), { description = "Wallpaper picker" })
      hl.bind("R", hl.dsp.exec_cmd("systemctl --user restart noctalia-shell"), { description = "Restart noctalia-shell" })
      hl.bind("P", hl.dsp.exec_cmd("~/bin/colorpicker"), { description = "Color picker" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)
    hl.define_submap("shell-bluetooth", "reset", function()
      hl.bind("o", hl.dsp.exec_cmd(scripts .. "/launch-bluetooth.sh open"), { description = "Open bluetooth panel" })
      hl.bind("c", hl.dsp.exec_cmd(scripts .. "/launch-bluetooth.sh close"), { description = "Close bluetooth panel" })
      hl.bind("a", hl.dsp.exec_cmd(scripts .. "/launch-bluetooth.sh auto"), { description = "Toggle bluetooth auto" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)
    hl.define_submap("shell-network", "reset", function()
      hl.bind("o", hl.dsp.exec_cmd(scripts .. "/launch-network.sh open"), { description = "Open network panel" })
      hl.bind("c", hl.dsp.exec_cmd(scripts .. "/launch-network.sh close"), { description = "Close network panel" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)

    -- 14. APPS MODE (SUPER+E)
    hl.define_submap("apps", "reset", function()
      hl.bind("W", hl.dsp.submap("apps-web"), { description = "Web browsers submenu" })
      hl.bind("E", hl.dsp.submap("apps-editor"), { description = "Editors submenu" })
      hl.bind("F", hl.dsp.submap("apps-file"), { description = "Files submenu" })
      hl.bind("M", hl.dsp.submap("apps-media"), { description = "Media submenu" })
      hl.bind("G", hl.dsp.submap("apps-games"), { description = "Games submenu" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)
    hl.define_submap("apps-web", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("zen"), { description = "Zen browser" })
      hl.bind("B", hl.dsp.exec_cmd("brave"), { description = "Brave browser" })
      hl.bind("Z", hl.dsp.exec_cmd("zen"), { description = "Zen browser" })
      hl.bind("F", hl.dsp.exec_cmd("firefox"), { description = "Firefox" })
      hl.bind("SHIFT + F", hl.dsp.exec_cmd("firefox --private-window"), { description = "Firefox private window" })
      hl.bind("Q", hl.dsp.exec_cmd("qutebrowser"), { description = "Qutebrowser" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)
    hl.define_submap("apps-editor", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("cursor --classic"), { description = "Cursor" })
      hl.bind("C", hl.dsp.exec_cmd("cursor --classic"), { description = "Cursor" })
      hl.bind("K", hl.dsp.exec_cmd("kate"), { description = "Kate" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)
    hl.define_submap("apps-file", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi"), { description = "Yazi (home)" })
      hl.bind("D", hl.dsp.exec_cmd("dolphin"), { description = "Dolphin" })
      hl.bind("Y", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi"), { description = "Yazi (home)" })
      hl.bind("P", hl.dsp.exec_cmd("pcmanfm"), { description = "PCManFM" })
      hl.bind("C", hl.dsp.submap("apps-file-open"), { description = "Open folder submenu" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)
    hl.define_submap("apps-file-open", "reset", function()
      hl.bind("H", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME"), { description = "Open home folder" })
      hl.bind("D", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME/Downloads"), { description = "Open Downloads" })
      hl.bind("P", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME/Pictures"), { description = "Open Pictures" })
      hl.bind("C", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME/Documents"), { description = "Open Documents" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)
    hl.define_submap("apps-media", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("cantata"), { description = "Cantata player" })
      hl.bind("C", hl.dsp.exec_cmd("cantata"), { description = "Cantata player" })
      hl.bind("m", hl.dsp.exec_cmd("mpv"), { description = "mpv player" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)
    hl.define_submap("apps-games", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("lutris"), { description = "Lutris" })
      hl.bind("S", hl.dsp.exec_cmd("steam"), { description = "Steam" })
      hl.bind("L", hl.dsp.exec_cmd("lutris"), { description = "Lutris" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)

    -- 15. MESSAGING MODE (SUPER+M)
    hl.define_submap("messaging", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("viber"), { description = "Viber" })
      hl.bind("V", hl.dsp.submap("messaging-viber"), { description = "Viber submenu" })
      hl.bind("T", hl.dsp.exec_cmd("telegram-desktop"), { description = "Telegram" })
      hl.bind("D", hl.dsp.exec_cmd("vesktop"), { description = "Vesktop (Discord)" })
      hl.bind("W", hl.dsp.submap("messaging-whatsapp"), { description = "WhatsApp submenu" })
      hl.bind("M", hl.dsp.exec_cmd("messenger"), { description = "Messenger" })
      hl.bind("A", hl.dsp.exec_cmd("sh -c 'viber & vesktop & zapzap &'"), { description = "Launch all messengers" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)
    hl.define_submap("messaging-viber", "reset", function()
      hl.bind("D", hl.dsp.exec_cmd("xdg-open $HOME/Downloads"), { description = "Open Downloads" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)
    hl.define_submap("messaging-whatsapp", "reset", function()
      hl.bind("D", hl.dsp.exec_cmd("xdg-open $HOME/Downloads"), { description = "Open Downloads" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)

    -- 16. WINDOWS MODE (SUPER+W)
    hl.define_submap("windows", "reset", function()
      hl.bind("F", hl.dsp.window.fullscreen(), { description = "Toggle fullscreen" })
      hl.bind("T", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
      hl.bind("K", hl.dsp.window.close(), { description = "Close window" })
      hl.bind("P", hl.dsp.window.pseudo(), { description = "Toggle pseudo" })
      hl.bind("S", hl.dsp.workspace.toggle_special("scratchpad"), { description = "Toggle scratchpad" })
      hl.bind("SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }), { description = "Move to scratchpad" })
      hl.bind("G", hl.dsp.exec_cmd(scripts .. "/toggle-performance.sh"), { description = "Toggle performance mode" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit mode" })
    end)
  '';
}
