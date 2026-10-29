
    hl.define_submap("apps-media", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("cantata"), { description = "Cantata player" })
      hl.bind("C", hl.dsp.exec_cmd("cantata"), { description = "Cantata player" })
      hl.bind("m", hl.dsp.exec_cmd("mpv"), { description = "mpv player" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit media mode" })
    end)
  