
    -- 1. MOUSE (SUPER HELD)
    hl.bind(mod .. " + mouse:272", function()
      superTap.armed = false
      hl.dispatch(hl.dsp.window.drag())
    end, { mouse = true, description = "Drag window" })
    hl.bind(mod .. " + mouse:273", function()
      superTap.armed = false
      hl.dispatch(hl.dsp.window.resize())
    end, { mouse = true, description = "Resize window" })
  