-- kulala is only the modifiable fix, the rest comes from LazyVim's `util.rest`
-- extra: it owns the repo URL, the <leader>R* maps, the `http` filetype and the
-- http/graphql parsers. The extra is enabled in the Nix module
-- (programs.lazyvim.extras.util.rest) so its import lands before user plugins
-- and LazyVim's import-order check passes; the plugin is layered on top of the
-- extra by name.
--
-- kulala locks its response buffers read-only and restores that state across
-- sessions, which can leave the shared kulala://scratchpad buffer
-- modifiable=false; its own scratchpad command then dies with "Buffer is not
-- 'modifiable'". Request buffers are meant to be typed into, so drop the lock
-- whenever one is loaded.
return {
  {
    "kulala.nvim",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("kulala", { clear = true }),
        pattern = "http",
        callback = function(args)
          vim.bo[args.buf].modifiable = true
        end,
      })
    end,
  },
}
