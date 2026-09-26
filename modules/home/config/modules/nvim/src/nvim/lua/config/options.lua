-- Loaded by LazyVim before plugins start, so the palette is applied first and
-- the signal handler is in place before anything can trigger a reload.
require("theme").setup()

-- colorscheme: LazyVim v16 has no `vim.g.colorscheme`, the colorscheme is a
-- field on the lazyvim.config module that LazyVim applies while setting itself
-- up. Passing it to `require("lazyvim").setup()` from here does not work,
-- because lazy runs `require("lazyvim").setup(opts)` again for LazyVim's own
-- spec once it loads it, with that spec's `opts = {}`. Assign the field
-- directly instead: a raw field takes precedence over the metatable that falls
-- back to the defaults, so it survives those later calls.
-- colors/base16.vim -> lua/theme.lua
require("lazyvim.config").colorscheme = "base16"

-- nvim-neoclip's sqlite backend needs the C library, which nvim does not have
-- built in. lua/config/nix.lua is generated from pkgs.sqlite3, so point at it
-- right away; the profile glob is only a fallback for an editor started from
-- outside the home-manager environment.
do
  local nix = require("config.nix")

  if not vim.g.sqlite_clib_path and nix.sqlite_clib and vim.loop.fs_stat(nix.sqlite_clib) then
    vim.g.sqlite_clib_path = nix.sqlite_clib
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function()
      if vim.g.sqlite_clib_path then
        return
      end

      local found = vim.fn.glob(
        table.concat({
          vim.fn.expand("~/.nix-profile/lib/libsqlite3.so*"),
          "/nix/var/nix/profiles/default/lib/libsqlite3.so*",
          "/run/current-system/sw/lib/libsqlite3.so*",
        }, " "),
        false,
        true
      )

      for _, path in ipairs(found) do
        if vim.loop.fs_stat(path) then
          vim.g.sqlite_clib_path = path
          break
        end
      end
    end,
  })
end
