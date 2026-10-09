-- theme-switcher: the only colourscheme in this config.
--
-- It reads the palette that the Nix side keeps up to date and paints everything
-- from it, then registers the two ways a palette change arrives:
--
--  * SIGUSR1 -- `scripts/theme` writes the palette file and signals Neovim.
--  * :ThemeReload -- re-reads the palette file without needing a signal, useful
--    when the file changed outside of the script.
--
-- Both funnel into `load()`, so a theme switch never needs a restart and never
-- needs a second colorscheme to fight over the highlight groups.

local color = require("theme.color")

local M = {}

M.name = "theme-switcher"

local PAINTERS = {
  "editor",
  "syntax",
  "diagnostics",
  "float",
  "snacks",
  "plugins",
}

local function paint(c)
  local hl = require("theme.hl")
  for _, name in ipairs(PAINTERS) do
    require("theme.groups." .. name)(c, hl)
  end

  -- TEST: comments with no explicit fg (revert after testing).
  require("config.test_comment")()

  hl.clear_strikethrough()
  -- base16-nvim re-applies its groups from its own SIGUSR1 handler, which may
  -- be queued after this paint; the deferred pass runs once that has settled.
  vim.schedule(hl.clear_strikethrough)
end

--- Re-read the palette and repaint. Safe to call at any time.
function M.load()
  local palette = require("theme.palette")
  palette.reset()
  local c = palette.load()

  -- 'background' has to be right before anything paints, and setting it
  -- re-sources this colorscheme, which re-enters load() with the memoised
  -- palette. Painting is idempotent, so the second pass is free and it does not
  -- matter whether the outer or the inner call paints last.
  vim.g.colors_name = M.name
  vim.o.background = color.needs_dark_text(c.bg.base) and "light" or "dark"

  paint(c)
  require("theme.lualine").sync()
end

--- The lualine theme table for the active palette.
function M.lualine_theme()
  return require("theme.lualine").theme(require("theme.palette").load())
end

function M.setup()
  local group = vim.api.nvim_create_augroup("ThemeSwitcher", { clear = true })

  -- Re-paint after anything re-sources a colorscheme (including `background`
  -- above) so our groups win over the defaults again.
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      paint(require("theme.palette").load())
    end,
  })

  -- lualine loads at VeryLazy; once it is up, refresh it from the palette.
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = function()
      require("theme.lualine").sync()
      require("theme.hl").clear_strikethrough()
    end,
  })

  vim.api.nvim_create_user_command("ThemeReload", function()
    M.load()
  end, { desc = "Re-read the theme-switcher palette" })

  -- `scripts/theme` signals the running Neovim after rewriting the palette.
  -- luv only accepts the numeric signal here, so ask libuv for the number.
  M.signal = vim.uv.new_signal()
  M.signal:start(vim.uv.constants.SIGUSR1, function()
    vim.schedule(M.load)
  end)
end

return M
