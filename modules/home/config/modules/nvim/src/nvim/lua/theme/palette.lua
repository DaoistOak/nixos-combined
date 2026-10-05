-- The palette scripts/theme writes to ~/.config/theme-switcher/nvim-base16.lua.
local M = {}

M.path = vim.fn.expand("~/.config/theme-switcher/nvim-base16.lua")

function M.read()
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

-- Fills in the extended roles for palettes that predate them (plain base16).
function M.extend(p)
	local c = p
	c.crust = c.crust or c.base00
	c.mantle = c.mantle or c.base00
	c.base = c.base or c.base01
	c.surface0 = c.surface0 or c.base01
	c.surface1 = c.surface1 or c.base02
	c.surface2 = c.surface2 or c.base02
	c.overlay0 = c.overlay0 or c.base03
	c.overlay1 = c.overlay1 or c.base04
	c.overlay2 = c.overlay2 or c.base04
	c.subtext0 = c.subtext0 or c.base04
	c.subtext1 = c.subtext1 or c.base04
	c.text = c.text or c.base05
	c.accent = c.accent or c.base0D
	c.blue = c.blue or c.base07
	c.mauve = c.mauve or c.base0E
	return c
end

-- Severity ramp shared by diagnostics and bufferline. Neovim spells the warning
-- group `Warn`, bufferline spells it `Warning`, so both names are carried.
function M.severity(c)
	return {
		{ lsp = "Error", bufferline = "Error", colour = c.base08 },
		{ lsp = "Warn", bufferline = "Warning", colour = c.base09 },
		{ lsp = "Info", bufferline = "Info", colour = c.base0D },
		{ lsp = "Hint", bufferline = "Hint", colour = c.base0C },
	}
end

return M
