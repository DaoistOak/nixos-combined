
    hl.define_submap("shell-widgets", "reset", function()
      hl.bind("M", hl.dsp.exec_cmd(scripts .. "/widget-toggle.sh com.widget.metro nix run github:5c0/metropolis"), { description = "Toggle metropolis widget" })
      hl.bind("C", hl.dsp.exec_cmd(scripts .. "/widget-toggle.sh com.widget.cava " .. scripts .. "/cava-auto.sh"), { description = "Toggle cava widget" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit widgets mode" })
    end)
  