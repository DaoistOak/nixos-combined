return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<Tab>",
          dismiss = "<C-]>",
        },
      },
      panel = {
        enabled = false,
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
    end,
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    build = "make tiktoken",
    dependencies = {
      "zbirenbaum/copilot.lua",
      "nvim-lua/plenary.nvim",
    },
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
    config = function(_, opts)
      require("CopilotChat").setup(opts)

      vim.keymap.set("n", "<leader>cc", ":CopilotChat<CR>", { desc = "Copilot Chat" })
      vim.keymap.set("n", "<leader>co", ":CopilotChatOpen<CR>", { desc = "Open Copilot Chat" })
      vim.keymap.set("n", "<leader>cq", ":CopilotChatClose<CR>", { desc = "Close Copilot Chat" })

      vim.keymap.set("v", "<leader>ce", ":CopilotChat Explain<CR>", { desc = "Explain selection" })
      vim.keymap.set("v", "<leader>cf", ":CopilotChat Fix<CR>", { desc = "Fix selection" })
      vim.keymap.set("v", "<leader>cr", ":CopilotChat Refactor<CR>", { desc = "Refactor selection" })
      vim.keymap.set("v", "<leader>ct", ":CopilotChat Tests<CR>", { desc = "Generate tests" })
    end,
  },

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
      default_register = '"',
      filter = nil,
      continuous_sync = true,
    },
    config = function(_, opts)
      require("neoclip").setup(opts)
      vim.keymap.set("n", "<leader>fy", function()
        require("telescope").load_extension("neoclip")
        require("telescope").extensions.neoclip.default()
      end, { desc = "Yank history" })
    end,
  },
}