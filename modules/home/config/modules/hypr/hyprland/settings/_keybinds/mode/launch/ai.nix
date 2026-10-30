{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    hl.define_submap("apps-ai", "reset", function()
      hl.bind("G", hl.dsp.exec_cmd(scripts .. "/launch-ai.sh gemini"), { description = "Gemini (mode E, A)" })
      hl.bind("C", hl.dsp.exec_cmd(scripts .. "/launch-ai.sh chatgpt"), { description = "ChatGPT (mode E, A)" })
      hl.bind("P", hl.dsp.exec_cmd(scripts .. "/launch-ai.sh perplexity"), { description = "Perplexity (mode E, A)" })
      hl.bind("l", hl.dsp.exec_cmd(scripts .. "/launch-ai.sh claude"), { description = "Claude (mode E, A)" })
      hl.bind("X", hl.dsp.exec_cmd(scripts .. "/launch-ai.sh grok"), { description = "Grok (mode E, A)" })
      hl.bind("RETURN", hl.dsp.exec_cmd(scripts .. "/launch-ai.sh gemini"), { description = "Default AI — Gemini (mode E, A)" })
      hl.bind("O", hl.dsp.exec_cmd(scripts .. "/launch-ai-opencode.sh"), { description = "OpenCode web UI (mode E, A)" })
      hl.bind("H", hl.dsp.exec_cmd(scripts .. "/launch-ai-hermes.sh"), { description = "Hermes web UI (mode E, A)" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit AI mode" })
    end)
  '';
}
