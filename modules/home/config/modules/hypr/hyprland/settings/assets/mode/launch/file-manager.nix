
    hl.define_submap("launch", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi"), { description = "Yazi (home)" })
      hl.bind("D", hl.dsp.exec_cmd("dolphin"), { description = "Dolphin" })
      hl.bind("Y", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi"), { description = "Yazi (home)" })
      hl.bind("P", hl.dsp.exec_cmd("pcmanfm"), { description = "PCManFM" })
      hl.bind("C", hl.dsp.submap("apps-file-open"), { description = "Open folder submenu" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit files mode" })
    end)
  