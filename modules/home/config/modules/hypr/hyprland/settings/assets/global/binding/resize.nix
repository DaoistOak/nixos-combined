
    -- 7. RESIZE (SUPER+CTRL)
    hl.bind(mod .. " + CONTROL + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { description = "Resize window smaller" })
    hl.bind(mod .. " + CONTROL + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { description = "Resize window larger" })
    hl.bind(mod .. " + CONTROL + up", hl.dsp.layout("colresize +conf"), { description = "Resize column taller" })
    hl.bind(mod .. " + CONTROL + down", hl.dsp.layout("colresize -conf"), { description = "Resize column shorter" })
    hl.bind(mod .. " + CONTROL + H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { description = "Resize window smaller (vim)" })
    hl.bind(mod .. " + CONTROL + J", hl.dsp.layout("colresize -conf"), { description = "Resize column shorter (vim)" })
    hl.bind(mod .. " + CONTROL + K", hl.dsp.layout("colresize +conf"), { description = "Resize column taller (vim)" })
    hl.bind(mod .. " + CONTROL + L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { description = "Resize window larger (vim)" })
  