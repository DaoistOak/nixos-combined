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

        -- Remembered window state: pseudo/floating is kept per window CLASS in a
        -- state file and re-applied as window rules, so the state survives layout
        -- switches, window close/reopen and restarts. Toggled from the WINDOWS
        -- submap (P = pseudo, T = floating).
        local windowStateFile = "${config.xdg.configHome}/hypr/window-state.conf"
        local remRules = {}

        local function remSave()
          local lines = {}
          for cls, e in pairs(remRules) do
            if e.float and e.float:is_enabled() then
              lines[#lines + 1] = "float=" .. cls
            end
            if e.pseudo and e.pseudo:is_enabled() then
              lines[#lines + 1] = "pseudo=" .. cls
            end
          end
          local f = io.open(windowStateFile, "w")
          if not f then
            return
          end
          f:write(table.concat(lines, "\n"), "\n")
          f:close()
        end

        local function remLoad()
          remRules = {}
          local f = io.open(windowStateFile, "r")
          if not f then
            return
          end
          for line in f:lines() do
            local kind, cls = line:match("^(float|pseudo)=(.+)$")
            if kind then
              remRules[cls] = remRules[cls] or {}
              remRules[cls][kind] = hl.window_rule({ match = { class = "^" .. cls .. "$" }, [kind] = true })
            end
          end
          f:close()
        end

        local function remToggle(kind)
          local w = hl.get_active_window()
          if not w or not w.class then
            return
          end
          local cls = w.class
          remRules[cls] = remRules[cls] or {}
          local rule = remRules[cls][kind]
          if rule then
            rule:set_enabled(not rule:is_enabled())
          else
            remRules[cls][kind] = hl.window_rule({ match = { class = "^" .. cls .. "$" }, [kind] = true })
          end
          remSave()
        end

    remLoad()

        -- All-window transparency: the whitelist below renders at 0.90 via a
        -- single runtime window rule. SUPER+W,T in the windows mode flips every
        -- window to fully opaque; the choice persists in a state file so it
        -- survives reboots and home-manager switches (config reload re-reads it).
        local transStateFile = "${config.xdg.configHome}/hypr/transparency-state.conf"
        local transRule = hl.window_rule({
          match = {
            class = "^(wezterm|ghostty|com\\.mitchellh\\.ghostty|[Kk]itty|[Aa]lacritty|Code|Codium|Visual Studio Code|[Cc]ursor|neovide|[Kk]ate|dolphin|org\\.kde\\.dolphin|[Pp]cmanfm(-qt)?|[Tt]hunar|[Ff]erdium|[Vv]esktop|[Dd]iscord|com\\.rtosta\\.zapzap|com\\.viber\\.Viber|keepassxc|org\\.kde\\.kdeconnect|[Ll]utris|com\\.usebottles\\.bottles|org\\.kde\\.elisa|[Ee]lisa|[Cc]antata|AI-(gemini|chatgpt|perplexity|grok|claude))$",
          },
          opacity = "0.9 override 0.9 override",
        })

        local function transReadMode()
          -- true = transparent (.90 for the whitelist); false = fully opaque.
          local f = io.open(transStateFile, "r")
          if not f then
            return true
          end
          local mode = f:read("l")
          f:close()
          return mode ~= "0"
        end

        local function transApply(transparent)
          transRule:set_enabled(transparent)
        end

        local function transSet(transparent)
          transApply(transparent)
          local f = io.open(transStateFile, "w")
          if f then
            f:write(transparent and "1\n" or "0\n")
            f:close()
          end
        end

        transApply(transReadMode())

        -- Runtime handle shared with scripts (performance-mode.sh): exposes the
        -- whitelist transparency rule so they can force it opaque/restore the
        -- saved SUPER+W,T preference without touching the persistence file.
        hyprTrans = {
          get = transReadMode,
          force = transApply,
        }

        -- 1. MOUSE (SUPER HELD)
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
        hl.gesture({ fingers = gestureFingers, direction = "horizontal", action = "scroll_move", scale = 1.2 })

        -- 2. GLOBAL (SUPER)
        hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh tmux"), { description = "Terminal (default + tmux)" })
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

        -- 3. MODES (SUPER)
        hl.bind(mod .. " + T", hl.dsp.submap("terminal-apps"), { description = "Enter terminal-apps mode" })
        hl.bind(mod .. " + S", hl.dsp.submap("shell"), { description = "Enter shell mode" })
        hl.bind(mod .. " + E", hl.dsp.submap("apps"), { description = "Enter apps mode" })
        hl.bind(mod .. " + M", hl.dsp.submap("messaging"), { description = "Enter messaging mode" })
        hl.bind(mod .. " + W", hl.dsp.submap("windows"), { description = "Enter windows mode" })

        -- 4. WORKSPACES (SUPER)
        hl.bind(mod .. " + 1", hl.dsp.focus({ workspace = 1 }), { description = "Workspace 1" })
        hl.bind(mod .. " + 2", hl.dsp.focus({ workspace = 2 }), { description = "Workspace 2" })
        hl.bind(mod .. " + 3", hl.dsp.focus({ workspace = 3 }), { description = "Workspace 3" })
        hl.bind(mod .. " + 4", hl.dsp.focus({ workspace = 4 }), { description = "Workspace 4" })
        hl.bind(mod .. " + 5", hl.dsp.focus({ workspace = 5 }), { description = "Workspace 5" })
        hl.bind(mod .. " + 6", hl.dsp.focus({ workspace = 6 }), { description = "Workspace 6" })
        hl.bind(mod .. " + 7", hl.dsp.focus({ workspace = 7 }), { description = "Workspace 7" })
        hl.bind(mod .. " + 8", hl.dsp.focus({ workspace = 8 }), { description = "Workspace 8" })
        hl.bind(mod .. " + 9", hl.dsp.focus({ workspace = 9 }), { description = "Workspace 9" })
        hl.bind(mod .. " + 0", hl.dsp.focus({ workspace = 10 }), { description = "Workspace 10" })
        hl.bind(mod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }), { description = "Move window to workspace 1" })
        hl.bind(mod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }), { description = "Move window to workspace 2" })
        hl.bind(mod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }), { description = "Move window to workspace 3" })
        hl.bind(mod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }), { description = "Move window to workspace 4" })
        hl.bind(mod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }), { description = "Move window to workspace 5" })
        hl.bind(mod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }), { description = "Move window to workspace 6" })
        hl.bind(mod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }), { description = "Move window to workspace 7" })
        hl.bind(mod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }), { description = "Move window to workspace 8" })
        hl.bind(mod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }), { description = "Move window to workspace 9" })
        hl.bind(mod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }), { description = "Move window to workspace 10" })
        hl.bind(mod .. " + SHIFT + ALT + 1", hl.dsp.window.move({ workspace = 1, follow = false }), { description = "Send window to workspace 1 (silent)" })
        hl.bind(mod .. " + SHIFT + ALT + 2", hl.dsp.window.move({ workspace = 2, follow = false }), { description = "Send window to workspace 2 (silent)" })
        hl.bind(mod .. " + SHIFT + ALT + 3", hl.dsp.window.move({ workspace = 3, follow = false }), { description = "Send window to workspace 3 (silent)" })
        hl.bind(mod .. " + SHIFT + ALT + 4", hl.dsp.window.move({ workspace = 4, follow = false }), { description = "Send window to workspace 4 (silent)" })
        hl.bind(mod .. " + SHIFT + ALT + 5", hl.dsp.window.move({ workspace = 5, follow = false }), { description = "Send window to workspace 5 (silent)" })
        hl.bind(mod .. " + SHIFT + ALT + 6", hl.dsp.window.move({ workspace = 6, follow = false }), { description = "Send window to workspace 6 (silent)" })
        hl.bind(mod .. " + SHIFT + ALT + 7", hl.dsp.window.move({ workspace = 7, follow = false }), { description = "Send window to workspace 7 (silent)" })
        hl.bind(mod .. " + SHIFT + ALT + 8", hl.dsp.window.move({ workspace = 8, follow = false }), { description = "Send window to workspace 8 (silent)" })
        hl.bind(mod .. " + SHIFT + ALT + 9", hl.dsp.window.move({ workspace = 9, follow = false }), { description = "Send window to workspace 9 (silent)" })
        hl.bind(mod .. " + SHIFT + ALT + 0", hl.dsp.window.move({ workspace = 10, follow = false }), { description = "Send window to workspace 10 (silent)" })
        hl.bind(mod .. " + mouse_down", function()
          superTap.armed = false
          hl.dispatch(hl.dsp.focus({ workspace = "e-1" }))
        end, { description = "Previous workspace (scroll)" })
        hl.bind(mod .. " + mouse_up", function()
          superTap.armed = false
          hl.dispatch(hl.dsp.focus({ workspace = "e+1" }))
        end, { description = "Next workspace (scroll)" })

        -- 5. FOCUS (SUPER)
        hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }), { description = "Focus left" })
        hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }), { description = "Focus right" })
        hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }), { description = "Focus up" })
        hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }), { description = "Focus down" })
        hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }), { description = "Focus left (vim)" })
        hl.bind(mod .. " + J", hl.dsp.focus({ direction = "d" }), { description = "Focus down (vim)" })
        hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }), { description = "Focus up (vim)" })
        hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }), { description = "Focus right (vim)" })

        -- 6. WINDOW MOVE (SUPER)
        hl.bind(mod .. " + SHIFT + left", hl.dsp.layout("swapcol l"), { description = "Move window left (swap column)" })
        hl.bind(mod .. " + SHIFT + right", hl.dsp.layout("swapcol r"), { description = "Move window right (swap column)" })
        hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }), { description = "Move window up" })
        hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }), { description = "Move window down" })
        hl.bind(mod .. " + SHIFT + ALT + left", hl.dsp.window.move({ direction = "l" }), { description = "Move window left (keep column)" })
        hl.bind(mod .. " + SHIFT + ALT + right", hl.dsp.window.move({ direction = "r" }), { description = "Move window right (keep column)" })
        hl.bind(mod .. " + SHIFT + H", hl.dsp.layout("swapcol l"), { description = "Move window left (swap column, vim)" })
        hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }), { description = "Move window down (vim)" })
        hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }), { description = "Move window up (vim)" })
        hl.bind(mod .. " + SHIFT + L", hl.dsp.layout("swapcol r"), { description = "Move window right (swap column, vim)" })

        -- 7. RESIZE (SUPER+CTRL)
        hl.bind(mod .. " + CONTROL + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { description = "Resize window smaller" })
        hl.bind(mod .. " + CONTROL + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { description = "Resize window larger" })
        hl.bind(mod .. " + CONTROL + up", hl.dsp.layout("colresize +conf"), { description = "Resize column taller" })
        hl.bind(mod .. " + CONTROL + down", hl.dsp.layout("colresize -conf"), { description = "Resize column shorter" })
        hl.bind(mod .. " + CONTROL + H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { description = "Resize window smaller (vim)" })
        hl.bind(mod .. " + CONTROL + J", hl.dsp.layout("colresize -conf"), { description = "Resize column shorter (vim)" })
        hl.bind(mod .. " + CONTROL + K", hl.dsp.layout("colresize +conf"), { description = "Resize column taller (vim)" })
        hl.bind(mod .. " + CONTROL + L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { description = "Resize window larger (vim)" })

        -- 8. MEDIA & HARDWARE KEYS
        hl.bind("XF86PowerOff", hl.dsp.exec_cmd("noctalia msg panel-toggle session"), { locked = true, description = "Power menu" })
        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(scripts .. "/volume.sh up"), { locked = true, repeating = true, submap_universal = true, description = "Volume up (wpctl, up to 150%)" })
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(scripts .. "/volume.sh down"), { locked = true, repeating = true, submap_universal = true, description = "Volume down" })
        hl.bind("XF86AudioMute", hl.dsp.exec_cmd(scripts .. "/volume.sh mute"), { locked = true, repeating = true, submap_universal = true, description = "Toggle mute" })
        hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(scripts .. "/mic-mute.sh"), { locked = true, repeating = true, description = "Toggle mic mute" })
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(scripts .. "/brightness.sh up"), { locked = true, repeating = true, description = "Brightness up" })
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(scripts .. "/brightness.sh down"), { locked = true, repeating = true, description = "Brightness down" })
        hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("noctalia msg keyboard-backlight-up"), { locked = true, repeating = true, description = "Keyboard backlight up" })
        hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("noctalia msg keyboard-backlight-down"), { locked = true, repeating = true, description = "Keyboard backlight down" })
        hl.bind("XF86AudioNext", hl.dsp.exec_cmd("noctalia msg media next"), { locked = true, description = "Next track" })
        hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("noctalia msg media toggle"), { locked = true, description = "Play/pause" })
        hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("noctalia msg media previous"), { locked = true, description = "Previous track" })
        hl.bind("XF86RFKill", hl.dsp.exec_cmd(scripts .. "/airplane-mode.sh"), { locked = true, description = "Toggle airplane mode" })
        hl.bind("XF86SelectiveScreenshot", hl.dsp.exec_cmd("noctalia msg screenshot-region"), { locked = true, description = "Screenshot region (snip key)" })

        -- 9. TOOLS (SUPER)

        -- 10. LAUNCHER (SUPER TAP)
        hl.bind(mod .. " + SUPER_L", function()
          superTap.armed = true
        end, { description = "Launcher (SUPER tap)" })
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
        end, { release = true, description = "Launcher (SUPER tap)" })

        -- 11. SYSTEM (SUPER)
        hl.bind(mod .. " + CONTROL + ALT + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland" })

        -- 12. PASSTHROUGH (SUPER+SHIFT+ESC)
        hl.bind(mod .. " + SHIFT + escape", hl.dsp.submap("passthru"), { description = "Enter passthrough mode" })
        hl.define_submap("passthru", "reset", function()
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit passthrough mode" })
        end)

        -- 13. TERMINAL APPS (SUPER+T)
        hl.define_submap("terminal-apps", "reset", function()
          hl.bind("RETURN", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh tmux"), { description = "Open terminal (T)" })
          hl.bind("B", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh btop"), { description = "btop monitor" })
          hl.bind("C", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh " .. scripts .. "/cava-auto.sh"), { description = "cava visualizer" })
          hl.bind("N", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh tmux new-session -A -s nvim nvim"), { description = "Neovim" })
          hl.bind("H", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh tmux new-session -A -s herdr herdr"), { description = "herdr" })
          hl.bind("D", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh"), { description = "Default terminal" })
          hl.bind("S", hl.dsp.exec_cmd("qs ipc -c terminal-switcher call terminal-switcher toggle"), { description = "Switch default terminal" })
          hl.bind("F", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh nix run nixpkgs#fastfetch"), { description = "fastfetch (nix run)" })
          hl.bind("O", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh --cwd $HOME/.config/nixos"),
            { description = "Shell in nixos config" })
          hl.bind("A", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh --cwd $HOME opencode"),
            { description = "OpenCode" })
          hl.bind("I", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh --hold hyprctl info"),
            { description = "Hyprland info" })
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit terminal-apps mode" })
        end)

        -- 14. SHELL (SUPER+S)
        hl.define_submap("shell", "reset", function()
          hl.bind("B", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh bluetooth 2 noctalia msg panel-toggle control-center bluetooth && hyprctl dispatch \"hl.dsp.submap('shell-bluetooth')\""), { description = "Bluetooth submenu (idle: panel)" })
          hl.bind("N", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh network 2 noctalia msg panel-toggle control-center network && hyprctl dispatch \"hl.dsp.submap('shell-network')\""), { description = "Network submenu (idle: panel)" })
          hl.bind("SHIFT + N", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center notifications"), { description = "Notifications panel" })
          hl.bind("S", hl.dsp.exec_cmd("noctalia msg panel-toggle alexander/screen-toolkit:panel"), { description = "Screen tools panel (mode S)" })
          hl.bind("SHIFT + S", hl.dsp.exec_cmd("flameshot gui"), { description = "Flameshot screenshot (mode S)" })
          hl.bind("Q", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"), { description = "Control center (mode S)" })
          hl.bind("M", hl.dsp.exec_cmd("noctalia msg media toggle"), { description = "Media menu (mode S)" })
          hl.bind("W", hl.dsp.exec_cmd("noctalia msg panel-toggle wallpaper"), { description = "Wallpaper picker (mode S)" })
          hl.bind("R", hl.dsp.exec_cmd(scripts .. "/noctalia-restart.sh"), { description = "Restart noctalia (mode S)" })
          hl.bind("P", hl.dsp.exec_cmd("~/bin/colorpicker"), { description = "Color picker (mode S)" })
          hl.bind("K", hl.dsp.exec_cmd("keyviz"), { description = "Keyviz keypress visualizer (mode S)" })
          hl.bind("C", hl.dsp.exec_cmd("noctalia msg panel-toggle yuuto/calculator:panel"), { description = "Calculator panel (mode S)" })
          hl.bind("G", hl.dsp.exec_cmd(scripts .. "/performance-mode.sh"), { description = "Toggle performance mode (gaps/corners/transparency/border rotate)" })
          hl.bind("SHIFT + V", hl.dsp.exec_cmd(scripts .. "/session-restore.sh"), { description = "Restore session (mode S)" })
          hl.bind("D", hl.dsp.submap("shell-widgets"), { description = "Widget toggles submenu" })
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit shell mode" })
        end)
        -- 15. SHELL > BLUETOOTH (SUPER+S, B)
        hl.define_submap("shell-bluetooth", "reset", function()
          hl.bind("o", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel bluetooth && " .. scripts .. "/launch-bluetooth.sh open"), { description = "Open bluetooth panel" })
          hl.bind("c", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel bluetooth && " .. scripts .. "/launch-bluetooth.sh close"), { description = "Close bluetooth panel" })
          hl.bind("a", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel bluetooth && " .. scripts .. "/launch-bluetooth.sh auto"), { description = "Toggle bluetooth auto" })
          hl.bind("escape", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel bluetooth && hyprctl dispatch \"hl.dsp.submap('reset')\""), { description = "Exit bluetooth mode" })
        end)
        -- 16. SHELL > NETWORK (SUPER+S, N)
        hl.define_submap("shell-network", "reset", function()
          hl.bind("o", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel network && " .. scripts .. "/launch-network.sh open"), { description = "Open network panel" })
          hl.bind("c", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel network && " .. scripts .. "/launch-network.sh close"), { description = "Close network panel" })
          hl.bind("escape", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel network && hyprctl dispatch \"hl.dsp.submap('reset')\""), { description = "Exit network mode" })
        end)
        -- 17. SHELL > WIDGETS (SUPER+S, D) — desktop widget toggles
        hl.define_submap("shell-widgets", "reset", function()
          hl.bind("M", hl.dsp.exec_cmd(scripts .. "/widget-toggle.sh com.widget.metro nix run github:5c0/metropolis"), { description = "Toggle metropolis widget" })
          hl.bind("C", hl.dsp.exec_cmd(scripts .. "/widget-toggle.sh com.widget.cava " .. scripts .. "/cava-auto.sh"), { description = "Toggle cava widget" })
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit widgets mode" })
        end)

        -- 18. APPS (SUPER+E)
        hl.define_submap("apps", "reset", function()
          hl.bind("W", hl.dsp.submap("apps-web"), { description = "Web browsers submenu" })
          hl.bind("E", hl.dsp.submap("apps-editor"), { description = "Editors submenu" })
          hl.bind("F", hl.dsp.submap("apps-file"), { description = "Files submenu" })
          hl.bind("M", hl.dsp.submap("apps-media"), { description = "Media submenu" })
          hl.bind("G", hl.dsp.submap("apps-games"), { description = "Games submenu" })
          hl.bind("A", hl.dsp.submap("apps-ai"), { description = "AI assistants submenu" })
          hl.bind("P", hl.dsp.exec_cmd("keepassxc"), { description = "KeepassXC (mode E)" })
          hl.bind("V", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh vm 2 virt-manager && hyprctl dispatch \"hl.dsp.submap('apps-vm')\""), { description = "Virtual machines (timeout: open virt-manager)" })
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit apps mode" })
        end)

        -- 19. APPS > VM (SUPER+E, V)
        hl.define_submap("apps-vm", "reset", function()
          hl.bind("W", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel vm && virt-manager --show-domain-editor Windows"), { description = "Open Windows VM (no launch)" })
          hl.bind("escape", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel vm && hyprctl dispatch \"hl.dsp.submap('reset')\""), { description = "Exit VM mode" })
        end)
        -- 18. APPS > WEB (SUPER+E, W)
        hl.define_submap("apps-web", "reset", function()
          hl.bind("RETURN", hl.dsp.exec_cmd("zen"), { description = "Zen browser" })
          hl.bind("B", hl.dsp.exec_cmd("brave"), { description = "Brave browser" })
          hl.bind("Z", hl.dsp.exec_cmd("zen"), { description = "Zen browser" })
          hl.bind("F", hl.dsp.exec_cmd("firefox"), { description = "Firefox" })
          hl.bind("SHIFT + F", hl.dsp.exec_cmd("firefox --private-window"),
            { description = "Firefox private window" })
          hl.bind("Q", hl.dsp.exec_cmd("qutebrowser"), { description = "Qutebrowser" })
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit web mode" })
        end)
        -- 19. APPS > EDITORS (SUPER+E, E)
        hl.define_submap("apps-editor", "reset", function()
          hl.bind("RETURN", hl.dsp.exec_cmd("cursor --classic"),
            { description = "Cursor editor" })
          hl.bind("C", hl.dsp.exec_cmd("cursor --classic"),
            { description = "Cursor editor" })
          hl.bind("K", hl.dsp.exec_cmd("kate"), { description = "Kate" })
          hl.bind("N", hl.dsp.exec_cmd("neovide"), { description = "Neovide" })
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit editor mode" })
        end)
        -- 20. APPS > FILES (SUPER+E, F)
        hl.define_submap("apps-file", "reset", function()
          hl.bind("RETURN", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi"), { description = "Yazi (home)" })
          hl.bind("D", hl.dsp.exec_cmd("dolphin"), { description = "Dolphin" })
          hl.bind("Y", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi"), { description = "Yazi (home)" })
          hl.bind("P", hl.dsp.exec_cmd("pcmanfm"), { description = "PCManFM" })
          hl.bind("C", hl.dsp.submap("apps-file-open"), { description = "Open folder submenu" })
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit files mode" })
        end)
        -- 21. APPS > FILES > OPEN (SUPER+E, F, C)
        hl.define_submap("apps-file-open", "reset", function()
          hl.bind("H", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME"), { description = "Open home folder" })
          hl.bind("D", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME/Downloads"), { description = "Open Downloads (files)" })
          hl.bind("P", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME/Pictures"), { description = "Open Pictures" })
          hl.bind("C", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME/Documents"), { description = "Open Documents" })
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit file-open mode" })
        end)
        -- 22. APPS > MEDIA (SUPER+E, M)
        hl.define_submap("apps-media", "reset", function()
          hl.bind("RETURN", hl.dsp.exec_cmd("cantata"), { description = "Cantata player" })
          hl.bind("C", hl.dsp.exec_cmd("cantata"), { description = "Cantata player" })
          hl.bind("m", hl.dsp.exec_cmd("mpv"), { description = "mpv player" })
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit media mode" })
        end)
        -- 23. APPS > GAMES (SUPER+E, G)
        hl.define_submap("apps-games", "reset", function()
          hl.bind("RETURN", hl.dsp.exec_cmd("lutris"), { description = "Lutris" })
          hl.bind("S", hl.dsp.exec_cmd("steam"), { description = "Steam" })
          hl.bind("L", hl.dsp.exec_cmd("lutris"), { description = "Lutris" })
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit games mode" })
        end)

        -- 24. APPS > AI ASSISTANTS (SUPER+E, A)
        hl.define_submap("apps-ai", "reset", function()
          hl.bind("G", hl.dsp.exec_cmd(scripts .. "/launch-ai.sh gemini"), { description = "Gemini (mode E, A)" })
          hl.bind("C", hl.dsp.exec_cmd(scripts .. "/launch-ai.sh chatgpt"), { description = "ChatGPT (mode E, A)" })
          hl.bind("P", hl.dsp.exec_cmd(scripts .. "/launch-ai.sh perplexity"), { description = "Perplexity (mode E, A)" })
          hl.bind("l", hl.dsp.exec_cmd(scripts .. "/launch-ai.sh claude"), { description = "Claude (mode E, A)" })
          hl.bind("X", hl.dsp.exec_cmd(scripts .. "/launch-ai.sh grok"), { description = "Grok (mode E, A)" })
          hl.bind("RETURN", hl.dsp.exec_cmd(scripts .. "/launch-ai.sh gemini"), { description = "Default AI — Gemini (mode E, A)" })
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit AI mode" })
        end)

        -- 25. MESSAGING (SUPER+M)
        hl.define_submap("messaging", "reset", function()
          hl.bind("RETURN", hl.dsp.exec_cmd("flatpak run com.viber.Viber"), { description = "Viber" })
          hl.bind("V", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh viber 3 flatpak run com.viber.Viber && hyprctl dispatch \"hl.dsp.submap('messaging-viber')\""), { description = "Viber submenu (idle: launch)" })
          hl.bind("T", hl.dsp.exec_cmd("telegram-desktop"), { description = "Telegram" })
          hl.bind("D", hl.dsp.exec_cmd("vesktop"), { description = "Vesktop (Discord)" })
          hl.bind("W", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh whatsapp 3 flatpak run com.rtosta.zapzap && hyprctl dispatch \"hl.dsp.submap('messaging-whatsapp')\""), { description = "WhatsApp submenu (idle: launch)" })
          hl.bind("M", hl.dsp.exec_cmd("ferdium"), { description = "Ferdium" })
          hl.bind("A", hl.dsp.exec_cmd("sh -c 'flatpak run com.viber.Viber & vesktop & flatpak run com.rtosta.zapzap &'"), { description = "Launch all messengers" })
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit messaging mode" })
        end)
        -- 25. MESSAGING > VIBER (SUPER+M, V)
        hl.define_submap("messaging-viber", "reset", function()
          hl.bind("D", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel viber && xdg-open $HOME/Documents/ViberDownloads"), { description = "Open Viber downloads" })
          hl.bind("escape", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel viber && hyprctl dispatch \"hl.dsp.submap('reset')\""), { description = "Exit viber mode" })
        end)
        -- 26. MESSAGING > WHATSAPP (SUPER+M, W)
        hl.define_submap("messaging-whatsapp", "reset", function()
          hl.bind("D", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel whatsapp && xdg-open $HOME/Downloads"), { description = "Open WhatsApp downloads" })
          hl.bind("escape", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel whatsapp && hyprctl dispatch \"hl.dsp.submap('reset')\""), { description = "Exit whatsapp mode" })
        end)

        -- 27. WINDOWS (SUPER+W)
        hl.define_submap("windows", "reset", function()
          -- Toggle between scrolling and monocle layouts, flashing the Keymap bar
          -- so the switch is visible. Monocle tiles windows edge to edge, so its
          -- gaps are disabled (restored to 8/16 when leaving it).
          local toggLay = { "scrolling", "monocle" }
          local function applyGaps(gapsIn, gapsOut)
            hl.config({ general = { ["gaps_in"] = gapsIn, ["gaps_out"] = gapsOut } })
          end
          local function toggleLayout()
            local ws = hl.get_active_workspace()
            local cur = (ws and ws.tiled_layout) or toggLay[1]
            local nextName = cur ~= toggLay[1] and toggLay[1] or toggLay[2]
            hl.config({ general = { layout = nextName } })
            if nextName == "monocle" then
              applyGaps(0, 0)
            else
              applyGaps(8, 16)
            end
            hl.dispatch(hl.dsp.exec_cmd("noctalia msg bar-show Keymap"))
            hl.timer(function()
              hl.dispatch(hl.dsp.exec_cmd("noctalia msg bar-hide Keymap"))
            end, { timeout = 2000, type = "oneshot" })
          end
          hl.bind("F", hl.dsp.window.fullscreen(), { description = "Toggle fullscreen" })
          hl.bind("ALT + F", function()
            hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
            remToggle("float")
          end, { description = "Toggle floating (remembered)" })
          hl.bind("T", function()
            local nextMode = not transReadMode()
            transSet(nextMode)
            hl.dispatch(hl.dsp.exec_cmd("noctalia msg bar-show Keymap"))
            hl.timer(function()
              hl.dispatch(hl.dsp.exec_cmd("noctalia msg bar-hide Keymap"))
            end, { timeout = 2000, type = "oneshot" })
          end, { description = "Toggle all-window transparency" })
          hl.bind("M", toggleLayout, { description = "Toggle tiling layout (mode W)" })
          hl.bind("C", hl.dsp.window.close(), { description = "Close window (mode W)" })
          hl.bind("P", function()
            hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
            hl.dispatch(hl.dsp.window.pin())
            remToggle("float")
          end, { description = "Pin to all workspaces (floating)" })
          hl.bind("ALT + P", function()
            hl.dispatch(hl.dsp.window.pseudo())
            remToggle("pseudo")
          end, { description = "Toggle pseudo (remembered)" })
          hl.bind("S", hl.dsp.workspace.toggle_special("scratchpad"), { description = "Toggle scratchpad" })
          hl.bind("SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }), { description = "Move to scratchpad" })
          hl.bind("V", hl.dsp.exec_cmd(scripts .. "/session-save.sh"), { description = "Save session" })
          hl.bind("SHIFT + V", hl.dsp.exec_cmd(scripts .. "/session-restore.sh"), { description = "Restore session (mode W)" })
          hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit windows mode" })
        end)
  '';
}
