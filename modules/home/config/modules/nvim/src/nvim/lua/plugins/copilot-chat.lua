-- The mappings live in lua/config/keymaps.lua: lazy.nvim merges the `keys` of
-- two specs for the same plugin positionally, so the ai.copilot-chat extra would
-- overwrite the tail of that list.
return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      -- Copilot Education accounts only accept the "auto" router model;
      -- any concrete model name is rejected by the API
      model = "auto",
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
