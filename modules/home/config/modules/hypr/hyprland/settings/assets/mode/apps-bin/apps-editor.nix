
    hl.define_submap("apps-editor", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("cursor --classic"), { description = "Cursor editor" })
      hl.bind("C", hl.dsp.exec_cmd("cursor --classic"), { description = "Cursor editor" })
      hl.bind("K", hl.dsp.exec_cmd("kate"), { description = "Kate" })
      hl.bind("N", hl.dsp.exec_cmd("neovide"), { description = "Neovide" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit editor mode" })
    end)
  