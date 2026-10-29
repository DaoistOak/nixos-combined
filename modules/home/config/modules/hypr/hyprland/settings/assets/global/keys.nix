
    -- 2. GLOBAL (SUPER)
    hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh tmux"), { description = "Terminal (default + tmux)" })
    hl.bind(mod .. " + C", hl.dsp.window.close(), { description = "Close window" })
    hl.bind(mod .. " + X", hl.dsp.exec_cmd("noctalia msg panel-toggle session"), { description = "Session menu" })
    hl.bind(mod .. " + K", hl.dsp.exec_cmd("noctalia msg panel-toggle kenn/keybind-cheatsheet:cheatsheet"), { description = "Toggle keybind cheatsheet" })
    hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd("qs ipc -c themeswitcher call themeswitcher toggle"), { description = "Cycle theme" })
    hl.bind(mod .. " + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"), { description = "Clipboard menu" })
    hl.bind(mod .. " + D", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"), { description = "Control center" })
    hl.bind(mod .. " + SHIFT + W", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center weather"), { description = "Weather panel" })
    hl.bind(mod .. " + o", hl.dsp.exec_cmd("opencode"), { description = "OpenCode (GUI)" })
    hl.bind(mod .. " + h", hl.dsp.exec_cmd("hermes dashboard --no-open && chromium --app=http://127.0.0.1:9119 --class=hermes"), { description = "Hermes Dashboard (Chromium)" })
  