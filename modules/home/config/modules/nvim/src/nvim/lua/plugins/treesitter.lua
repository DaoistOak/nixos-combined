-- Treesitter highlighting off. Two things turn it on, and both have to be dealt
-- with: this option, which is what LazyVim's own FileType autocommand reads
-- before calling vim.treesitter.start() (see lua/config/autocmds.lua for the
-- other one, neovim's ftplugins), and the runtime ftplugins neovim 0.12 ships,
-- which call vim.treesitter.start() unconditionally. Indentation and textobjects
-- keep working, they do not need the highlighter.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = { enable = false },
    },
  },
}
