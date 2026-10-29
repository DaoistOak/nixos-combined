
    hl.define_submap("apps-file-open", "reset", function()
      hl.bind("H", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME"), { description = "Open home folder" })
      hl.bind("D", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME/Downloads"), { description = "Open Downloads (files)" })
      hl.bind("P", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME/Pictures"), { description = "Open Pictures" })
      hl.bind("C", hl.dsp.exec_cmd(scripts .. "/launch-terminal.sh yazi $HOME/Documents"), { description = "Open Documents" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit file-open mode" })
    end)
  