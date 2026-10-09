-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Keep treesitter highlighting off. Turning it off with the Snacks toggle only
-- affects the buffer it was switched off in: neovim 0.12's own ftplugins call
-- vim.treesitter.start() every time a filetype is set (runtime/ftplugin/lua.lua
-- and friends), so the next buffer brings it straight back. The autocommand is
-- scheduled so it runs after those ftplugins, and the classic syntax highlighting
-- is turned back on in its place -- vim.treesitter.start() switches 'syntax' off.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_highlight_off", { clear = true }),
  callback = function(args)
    local buf = args.buf
    vim.schedule(function()
      -- Scratch buffers (quickfix, help, plugin UIs) are often wiped again
      -- before the scheduled callback runs.
      if not vim.api.nvim_buf_is_valid(buf) or not vim.b[buf].ts_highlight then
        return
      end
      vim.treesitter.stop(buf)
      vim.bo[buf].syntax = "ON"
    end)
  end,
})
