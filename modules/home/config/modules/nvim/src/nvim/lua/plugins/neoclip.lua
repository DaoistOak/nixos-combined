-- Yank history through telescope, as before. Every dependency is listed so the
-- Nix module dev-links it instead of letting lazy.nvim clone it.
return {
  {
    "AckslD/nvim-neoclip.lua",
    lazy = true,
    event = "VeryLazy",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "kkharji/sqlite.lua",
    },
    opts = {
      history = 1000,
      enable_persistent_history = true,
      continuous_sync = true,
    },
    keys = {
      {
        "<leader>fy",
        function()
          require("telescope").load_extension("neoclip")
          require("telescope").extensions.neoclip.default()
        end,
        desc = "Yank history",
      },
    },
  },
}
