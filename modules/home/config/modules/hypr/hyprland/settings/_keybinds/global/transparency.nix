{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    -- All-window transparency: the whitelist below renders at 0.90 via a
    -- single runtime window rule. SUPER+W,T in the windows mode flips every
    -- window to fully opaque; the choice persists in a state file so it
    -- survives reboots and home-manager switches (config reload re-reads it).
    local transStateFile = "${config.xdg.configHome}/hypr/transparency-state.conf"
    local transRule = hl.window_rule({
      match = {
        class = "^(wezterm|ghostty|com\\.mitchellh\\.ghostty|[Kk]itty|[Aa]lacritty|Code|Codium|Visual Studio Code|[Cc]ursor|neovide|[Kk]ate|dolphin|org\\.kde\\.dolphin|[Pp]cmanfm(-qt)?|[Tt]hunar|[Ff]erdium|[Vv]esktop|[Dd]iscord|com\\.rtosta\\.zapzap|com\\.viber\\.Viber|keepassxc|org\\.kde\\.kdeconnect|[Ll]utris|com\\.usebottles\\.bottles|org\\.kde\\.elisa|[Ee]lisa|[Cc]antata|AI-(gemini|chatgpt|perplexity|grok|claude))$",
      },
      opacity = "0.9 override 0.9 override",
    })

    -- AI agents (launch-ai.sh + opencode/hermes binds) open in the
    -- special (scratchpad) workspace, so SUPER+W, S surfaces them together.
    hl.window_rule({
      match = {
        class = "^(AI-(gemini|chatgpt|perplexity|grok|claude)|opencode|hermes)$",
      },
      workspace = "scratchpad",
    })

    -- All windows in the special (scratchpad) workspace never go fullscreen,
    -- even when a single app is present (unlike the other workspaces).
    hl.window_rule({
      match = {
        class = "^(AI-(gemini|chatgpt|perplexity|grok|claude)|opencode|hermes)$",
        workspace = "^(scratchpad)$",
      },
      fullscreen = false,
    })

    local function transReadMode()
      -- true = transparent (.90 for the whitelist); false = fully opaque.
      local f = io.open(transStateFile, "r")
      if not f then
        return true
      end
      local mode = f:read("l")
      f:close()
      return mode ~= "0"
    end

    local function transApply(transparent)
      transRule:set_enabled(transparent)
    end

    local function transSet(transparent)
      transApply(transparent)
      local f = io.open(transStateFile, "w")
      if f then
        f:write(transparent and "1\n" or "0\n")
        f:close()
      end
    end

    transApply(transReadMode())

    -- Runtime handle shared with scripts (performance-mode.sh): exposes the
    -- whitelist transparency rule so they can force it opaque/restore the
    -- saved SUPER+W,T preference without touching the persistence file.
    hyprTrans = {
      get = transReadMode,
      force = transApply,
    }
  '';
}
