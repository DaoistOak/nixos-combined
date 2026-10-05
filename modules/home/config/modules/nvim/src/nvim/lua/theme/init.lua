-- Palette from scripts/theme / theme-switcher. Reload with SIGUSR1 or
-- :ThemeReload; colors/base16.vim calls load() when the colorscheme is applied.
--
-- One linear pass: base_ui, syntax, diagnostics, diff, floating, pickers,
-- buffers, then the statusline. Each painter only reads the palette (`c`) and
-- calls theme.hl, so the order of apply_overrides is the order of the paint and
-- the order of the file.
local hl = require("theme.hl")
local palette = require("theme.palette")
local statusline = require("theme.statusline")
local modes = require("theme.statusline.modes")

local base_ui = require("theme.groups.editor")
local syntax = require("theme.groups.syntax")
local diagnostics = require("theme.groups.diagnostics")
local diff = require("theme.groups.diff")
local floating = require("theme.groups.floating")
local pickers = require("theme.groups.pickers")
local buffers = require("theme.groups.buffers")

local M = {}

M.path = palette.path

local function apply_overrides(p)
	local c = palette.extend(p)
	M.palette = c

	base_ui(c)
	syntax(c)
	diagnostics(c)
	diff(c)
	floating(c)
	pickers(c)
	buffers(c)
	M.lualine = statusline.paint(c)
end

function M.lualine_mode()
	return modes.current()
end

function M.lualine_theme()
	return M.lualine
end

function M.sync_lualine()
	if not M.lualine or not package.loaded["lualine.highlight"] then
		return
	end
	statusline.sync(M.lualine)
end

local function base16()
	if pcall(require, "base16-colorscheme") then
		return require("base16-colorscheme")
	end
	require("lazy").load({ plugins = { "folke/base16-nvim" } })
	return require("base16-colorscheme")
end

function M.load()
	if M.loading then
		return
	end
	M.loading = true

	local p, err = palette.read()
	if not p then
		M.loading = false
		vim.notify(err, vim.log.levels.ERROR, { title = "theme" })
		return
	end

	base16().setup(p)
	apply_overrides(p)
	M.sync_lualine()
	vim.g.colors_name = "base16"
	M.loading = false
end

function M.setup()
	if M.signal then
		return
	end

	vim.api.nvim_create_user_command("ThemeReload", M.load, { desc = "Reload the theme-switcher palette" })

	local group = vim.api.nvim_create_augroup("theme_switcher", { clear = true })
	-- Re-paint overrides only. Calling M.load here retriggered ColorScheme forever.
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		desc = "Re-apply theme-switcher overrides after a colorscheme change",
		callback = function()
			if M.loading or not M.palette then
				return
			end
			apply_overrides(M.palette)
			M.sync_lualine()
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "VeryLazy",
		desc = "Re-apply theme-switcher overrides once plugins have set up",
		callback = function()
			vim.schedule(function()
				if M.palette then
					apply_overrides(M.palette)
					M.sync_lualine()
				else
					M.load()
				end
			end)
		end,
	})

	M.signal = vim.uv.new_signal()
	M.signal:start("sigusr1", vim.schedule_wrap(M.load))
end

return M
