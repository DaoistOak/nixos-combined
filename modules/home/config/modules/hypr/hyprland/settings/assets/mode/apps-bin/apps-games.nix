
    hl.define_submap("apps-games", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("lutris"), { description = "Lutris" })
      hl.bind("S", hl.dsp.exec_cmd("steam"), { description = "Steam" })
      hl.bind("L", hl.dsp.exec_cmd("lutris"), { description = "Lutris" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit games mode" })
    end)
  