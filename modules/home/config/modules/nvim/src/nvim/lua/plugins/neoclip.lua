-- Yank history through telescope. Dependencies are listed explicitly so lazy.nvim
-- installs them; the sqlite backend needs libsqlite3, see lua/config/options.lua.
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
