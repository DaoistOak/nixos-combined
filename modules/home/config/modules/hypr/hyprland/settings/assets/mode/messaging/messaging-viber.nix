
    hl.define_submap("messaging-viber", "reset", function()
      hl.bind("D", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel viber && xdg-open $HOME/Documents/ViberDownloads"), { description = "Open Viber downloads" })
      hl.bind("escape", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel viber && hyprctl dispatch "hl.dsp.submap('reset')""), { description = "Exit viber mode" })
    end)
  