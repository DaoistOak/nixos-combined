{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  nvchadRev = "add44b952d631981614bbb8cfc6f7002f296dfe6";
  nvchadSrc = pkgs.fetchFromGitHub {
    owner = "NvChad";
    repo = "NvChad";
    rev = nvchadRev;
    sha256 = "182l8m7va6lmsa8axfckgwkzm7x990vnpj0hk6ixliy3rdf08qjw";
  };

  nvimWithNvchad = pkgs.neovim.overrideAttrs (old: {
    name = "neovim-nvchad";
    postInstall = ''
      mkdir -p $out/share/nvim/runtime
      cp -r ${nvchadSrc}/lua $out/share/nvim/runtime/lua
      cp -r ${nvchadSrc}/doc $out/share/nvim/runtime/doc
      cp -r ${nvchadSrc}/ftplugin $out/share/nvim/runtime/ftplugin
      cp -r ${nvchadSrc}/after $out/share/nvim/runtime/after
      cp -r ${nvchadSrc}/syntax $out/share/nvim/runtime/syntax
      cp -r ${nvchadSrc}/colors $out/share/nvim/runtime/colors
      cp -r ${nvchadSrc}/autoload $out/share/nvim/runtime/autoload
    '';
  });
in
{
  home.packages = lib.mkDefault [ nvimWithNvchad pkgs.stylua pkgs.lua-language-server ];

  home.file.".config/nvim/init.lua" = { force = true;
    text = ''
      vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
      vim.g.mapleader = " "

      local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

      if not vim.uv.fs_stat(lazypath) then
        local repo = "https://github.com/folke/lazy.nvim.git"
        vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
      end

      vim.opt.rtp:prepend(lazypath)

      local lazy_config = require "configs.lazy"

      require("lazy").setup({
        {
          "NvChad/NvChad",
          lazy = false,
          branch = "v2.5",
          import = "nvchad.plugins",
        },

        { import = "plugins" },
      }, lazy_config)

      dofile(vim.g.base46_cache .. "defaults")
      dofile(vim.g.base46_cache .. "statusline")

      require "options"
      require "autocmds"

      vim.opt.relativenumber = true
      vim.schedule(function()
        require "mappings"
      end)
    '';
  };

  home.file.".config/nvim/lua/chadrc.lua" = { force = true;
    text = ''
      local M = {}

      M.base46 = {
        theme = "catppuccin",
      }

      return M
    '';
  };

  home.file.".config/nvim/lua/options.lua" = { force = true;
    text = ''
      require "nvchad.options"

      local o = vim.o

      o.clipboard = "unnamedplus"

      do
        local candidates = vim.fn.glob("/nix/store/*sqlite-*/lib/libsqlite3.so", true, true)
        local path
        local exe = vim.fn.exepath "sqlite3"
        if exe ~= "" then
          path = exe:gsub("bin/sqlite3$", "lib/libsqlite3.so")
        elseif #candidates > 0 then
          path = candidates[#candidates]
        end
        if path and vim.uv.fs_stat(path) then
          vim.g.sqlite_clib_path = path
        end
      end
    '';
  };

  home.file.".config/nvim/lua/mappings.lua" = { force = true;
    text = ''
      require "nvchad.mappings"

      local map = vim.keymap.set

      map("n", ";", ":", { desc = "CMD enter command mode" })
      map("i", "jk", "<ESC>")
      map("n", "qq", ":q!<CR>", { desc = "Force Quit Neovim" })
    '';
  };

  home.file.".config/nvim/lua/autocmds.lua" = { force = true;
    text = ''
      require "nvchad.autocmds"
    '';
  };

  home.file.".config/nvim/lua/configs/lazy.lua" = { force = true;
    text = ''
      return {
        defaults = { lazy = true },
        install = { colorscheme = { "nvchad" } },

        ui = {
          icons = {
            ft = "",
            lazy = "󰂠 ",
            loaded = "",
            not_loaded = "",
          },
        },

        performance = {
          rtp = {
            disabled_plugins = {
              "2html_plugin",
              "tohtml",
              "getscript",
              "getscriptPlugin",
              "gzip",
              "logipat",
              "netrw",
              "netrwPlugin",
              "netrwSettings",
              "netrwFileHandlers",
              "matchit",
              "tar",
              "tarPlugin",
              "rrhelper",
              "spellfile_plugin",
              "vimball",
              "vimballPlugin",
              "zip",
              "zipPlugin",
              "tutor",
              "rplugin",
              "syntax",
              "synmenu",
              "optwin",
              "compiler",
              "bugreport",
              "ftplugin",
            },
          },
        },
      }
    '';
  };

  home.file.".config/nvim/lua/configs/conform.lua" = { force = true;
    text = ''
      local options = {
        formatters_by_ft = {
          lua = { "stylua" },
        },
      }

      return options
    '';
  };

  home.file.".config/nvim/lua/configs/lspconfig.lua" = { force = true;
    text = ''
      require("nvchad.configs.lspconfig").defaults()

      local servers = { "html", "cssls" }
      vim.lsp.enable(servers)
    '';
  };

  home.file.".config/nvim/lua/plugins/init.lua" = { force = true;
    text = ''
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
    '';
  };

  home.file.".config/nvim/lua/plugins/base16.lua" = { force = true;
    text = ''
      return { 'RRethy/base16-nvim',
        config = function()
          local ok, matugen = pcall(require, 'matugen')
          if ok then matugen.setup() end
        end,
      }
    '';
  };

  home.file.".config/nvim/lua/matugen.lua" = { force = true;
    text = ''
      local M = {}

      function M.setup()
        require('base16-colorscheme').setup({
          base00 = '#24273a',
          base01 = '#363a4f',
          base02 = '#3e435b',
          base03 = '#6e738d',
          base04 = '#a5adcb',
          base05 = '#cad3f5',
          base06 = '#cad3f5',
          base07 = '#cad3f5',
          base08 = '#ed8796',
          base09 = '#8bd5ca',
          base0A = '#8aadf4',
          base0B = '#8bd5ca',
          base0C = '#96e9dc',
          base0D = '#96e9dc',
          base0E = '#8aadf4',
          base0F = '#b9cef8',
        })

        local hi = function(group, opts)
          vim.api.nvim_set_hl(0, group, opts)
        end

        hi('TelescopeNormal',         { fg = '#cad3f5',          bg = '#24273a' })
        hi('TelescopeBorder',         { fg = '#6e738d',             bg = '#24273a' })
        hi('TelescopePromptNormal',   { fg = '#cad3f5',          bg = '#24273a' })
        hi('TelescopePromptBorder',   { fg = '#6e738d',             bg = '#24273a' })
        hi('TelescopePromptPrefix',   { fg = '#8bd5ca',             bg = '#24273a' })
        hi('TelescopePromptCounter',  { fg = '#a5adcb',  bg = '#24273a' })
        hi('TelescopePromptTitle',    { fg = '#24273a',             bg = '#8bd5ca' })
        hi('TelescopePreviewTitle',   { fg = '#24273a',             bg = '#8aadf4' })
        hi('TelescopeResultsTitle',   { fg = '#24273a',             bg = '#8bd5ca' })
        hi('TelescopeSelection',      { fg = '#cad3f5',          bg = '#3e435b' })
        hi('TelescopeSelectionCaret', { fg = '#8bd5ca',             bg = '#3e435b' })
        hi('TelescopeMatching',       { fg = '#8bd5ca',             bold = true })

        hi('MiniPickNormal',         { fg = '#cad3f5',          bg = '#24273a' })
        hi('MiniPickBorder',         { fg = '#6e738d',             bg = '#24273a' })
        hi('MiniPickPrompt',   { fg = '#cad3f5',          bg = '#24273a' })
        hi('MiniPickPromptPrefix',   { fg = '#8bd5ca',             bg = '#24273a' })
        hi('MiniPickBorderText',    { fg = '#24273a',             bg = '#8bd5ca' })
        hi('MiniPickMatchCurrent',      { fg = '#cad3f5',          bg = '#3e435b' })
        hi('MiniPickPromptCaret', { fg = '#8bd5ca',             bg = '#3e435b' })
        hi('MiniPickMatchRanges',       { fg = '#8bd5ca',             bold = true })
      end

      if _G.__matugen_signal then
        _G.__matugen_signal:stop()
        _G.__matugen_signal:close()
      end

      local signal = vim.uv.new_signal()
      _G.__matugen_signal = signal
      signal:start(
        'sigusr1',
        vim.schedule_wrap(function()
          package.loaded['matugen'] = nil
          require('matugen').setup()
        end)
      )

      return M
    '';
  };
}
