-- Declared explicitly (instead of only through the ai.copilot-chat extra) so
-- the Nix module dev-links it, and because the `make tiktoken` step is already
-- done by the nixpkgs build of the canary branch.
-- The mappings live in lua/config/keymaps.lua: lazy.nvim merges the `keys` of
-- two specs for the same plugin positionally, so the ai.copilot-chat extra
-- would overwrite the tail of this list.
return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      model = "gpt-4.1",
      temperature = 0.1,
      auto_insert_mode = true,
      window = {
        layout = "float",
        width = 80,
        height = 20,
        border = "rounded",
      },
    },
  },
}
