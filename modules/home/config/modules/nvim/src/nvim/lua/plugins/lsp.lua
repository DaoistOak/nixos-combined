-- Extra LSP servers beyond LazyVim's defaults (lua_ls, nixd, marksman from
-- the lang.markdown extra, ...). LazyVim only enables servers that appear in
-- its nvim-lspconfig opts.servers, so every server needs an entry here; the
-- binaries themselves come from programs.lazyvim.extraPackages in the Nix
-- module. rasi (rofi themes) has no LSP server at all — only its treesitter
-- parser in treesitterParsers.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ansiblels = {},
        bashls = {}, -- bash + sh
        clangd = {}, -- c/c++
        cmake = {},
        cssls = {}, -- css + scss + less
        dockerls = {},
        fish_lsp = {},
        gopls = {},
        html = {},
        hyprls = {},
        jdtls = {},
        jsonls = {},
        pyright = {},
        rust_analyzer = {},
        sqls = {},
        taplo = {}, -- toml
        ts_ls = {}, -- javascript + typescript
        yamlls = {},
        zls = {}, -- zig
      },
    },
  },
}
