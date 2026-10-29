
    hl.define_submap("messaging-whatsapp", "reset", function()
      hl.bind("D", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel whatsapp && xdg-open $HOME/Downloads"), { description = "Open WhatsApp downloads" })
      hl.bind("escape", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel whatsapp && hyprctl dispatch "hl.dsp.submap('reset')""), { description = "Exit whatsapp mode" })
    end)
  