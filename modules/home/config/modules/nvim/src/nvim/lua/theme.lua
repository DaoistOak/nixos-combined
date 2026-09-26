-- Applies the palette that `scripts/theme` writes (and that
-- modules/config/themes/colors generates at build time) through
-- base16-nvim, so Neovim follows the tracked theme selection like the
-- terminals do. Re-applied on SIGUSR1 (`pkill -USR1 nvim`) so `theme set ...`
-- recolors a running editor without a rebuild.
local M = {}

M.path = vim.fn.expand("~/.config/theme-switcher/nvim-base16.lua")

local function read_palette()
  local chunk = loadfile(M.path)
  if not chunk then
    return nil, ("no theme palette at %s"):format(M.path)
  end
  local ok, palette = pcall(chunk)
  if not ok then
    return nil, ("bad theme palette at %s: %s"):format(M.path, palette)
  end
  return palette
end

-- base16-nvim styles telescope from the palette already; these keep the flat
-- prompts/sections the picker had before the migration.
local function apply_overrides(c)
  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi("TelescopeNormal", { fg = c.base05, bg = c.base00 })
  hi("TelescopeBorder", { fg = c.base03, bg = c.base00 })
  hi("TelescopePromptNormal", { fg = c.base05, bg = c.base00 })
  hi("TelescopePromptBorder", { fg = c.base03, bg = c.base00 })
  hi("TelescopePromptPrefix", { fg = c.base0D, bg = c.base00 })
  hi("TelescopePromptCounter", { fg = c.base04, bg = c.base00 })
  hi("TelescopePromptTitle", { fg = c.base00, bg = c.base0D, bold = true })
  hi("TelescopeResultsTitle", { fg = c.base00, bg = c.base0D, bold = true })
  hi("TelescopePreviewTitle", { fg = c.base00, bg = c.base0A, bold = true })
  hi("TelescopeSelection", { fg = c.base05, bg = c.base02 })
  hi("TelescopeSelectionCaret", { fg = c.base0D, bg = c.base02 })
  hi("TelescopeMatching", { fg = c.base0D, bold = true })
end

-- base16-nvim is a normal lazy.nvim plugin, but the colorscheme is applied
-- before every lazy plugin has loaded, so pull it in on demand.
local function base16()
  if pcall(require, "base16-colorscheme") then
    return require("base16-colorscheme")
  end
  require("lazy").load({ plugins = { "folke/base16-nvim" } })
  return require("base16-colorscheme")
end

function M.load()
  local palette, err = read_palette()
  if not palette then
    vim.notify(err, vim.log.levels.ERROR, { title = "theme" })
    return
  end

  base16().setup(palette)
  apply_overrides(palette)
  vim.g.colors_name = "base16"
end

function M.setup()
  if M.signal then
    return
  end

  vim.api.nvim_create_user_command("ThemeReload", M.load, { desc = "Reload the theme-switcher palette" })

  M.signal = vim.uv.new_signal()
  M.signal:start("sigusr1", vim.schedule_wrap(M.load))
end

return M
