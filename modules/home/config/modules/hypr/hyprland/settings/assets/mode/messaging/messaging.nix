
    hl.define_submap("messaging", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("flatpak run com.viber.Viber"), { description = "Viber" })
      hl.bind("V", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh viber 3 flatpak run com.viber.Viber && hyprctl dispatch "hl.dsp.submap('messaging-viber')""), { description = "Viber submenu (idle: launch)" })
      hl.bind("T", hl.dsp.exec_cmd("telegram-desktop"), { description = "Telegram" })
      hl.bind("D", hl.dsp.exec_cmd("vesktop"), { description = "Vesktop (Discord)" })
      hl.bind("W", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh whatsapp 3 ferdium && hyprctl dispatch "hl.dsp.submap('messaging-whatsapp')""), { description = "WhatsApp submenu (idle: launch)" })
      hl.bind("F", hl.dsp.exec_cmd("ferdium"), { description = "Ferdium" })
      hl.bind("A", hl.dsp.exec_cmd("sh -c 'flatpak run com.viber.Viber & vesktop & ferdium &'"), { description = "Launch all messengers" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit messaging mode" })
    end)
  