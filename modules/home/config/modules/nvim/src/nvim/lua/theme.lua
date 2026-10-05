-- Palette from scripts/theme / theme-switcher. Reload with SIGUSR1 or :ThemeReload.
--
-- apply_overrides paints in one linear pass, top to bottom: base UI, then
-- syntax, then diagnostics/diff/search, then buffers, then the statusline.
-- Each block only ever reads the palette (`c`) and calls `hi`/`set`, so the
-- order below is the order of the file and the order of the paint.
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

-- Fills in the extended roles for palettes that predate them (plain base16).
local function extend(p)
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

local function hi(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

local function set(groups, opts)
	for _, group in ipairs(groups) do
		hi(group, opts)
	end
end

local function mix(a, b, amount)
	local function channel(shift)
		local ca = tonumber(a:sub(shift, shift + 1), 16)
		local cb = tonumber(b:sub(shift, shift + 1), 16)
		if not ca or not cb then
			return "00"
		end
		return string.format("%02x", math.floor(ca + (cb - ca) * amount + 0.5))
	end
	return string.format("#%s%s%s", channel(2), channel(4), channel(6))
end

-- Severity ramp shared by diagnostics, LSP virtual text and bufferline. Neovim
-- spells the warning group `Warn`, bufferline spells it `Warning`.
local function severity(c)
	return {
		{ lsp = "Error", bufferline = "Error", colour = c.base08 },
		{ lsp = "Warn", bufferline = "Warning", colour = c.base09 },
		{ lsp = "Info", bufferline = "Info", colour = c.base0D },
		{ lsp = "Hint", bufferline = "Hint", colour = c.base0C },
	}
end

local function base_ui(c)
	hi("Normal", { fg = c.text, bg = c.base })
	hi("NormalNC", { fg = c.text, bg = c.base })
	hi("SignColumn", { fg = c.subtext0 })
	hi("SignColumnSB", { fg = c.overlay0 })
	hi("FoldColumn", { fg = c.overlay0, bg = c.base })
	hi("Folded", { fg = c.accent, bg = c.base })
	set({ "LineNr", "LineNrAbove" }, { fg = c.overlay0 })
	set({ "CursorLineNr", "CursorLineSign" }, { fg = c.text })
	hi("CursorLineFold", { fg = c.overlay0 })
	hi("NonText", { fg = c.overlay1, bg = c.surface0 })
	hi("WinSeparator", { fg = c.crust, bg = c.base })
	hi("VertSplit", { fg = c.crust, bg = c.base })

	local cursorline = mix(c.base, c.surface0, 0.45)
	hi("CursorLine", { bg = cursorline })
	hi("MatchParen", { fg = c.accent, bg = cursorline, bold = true })

	hi("Search", { fg = c.text, bg = c.surface0 })
	hi("IncSearch", { fg = c.crust, bg = c.base0B, bold = true })
	hi("CurSearch", { fg = c.crust, bg = c.base0A, bold = true })

	set({ "FloatShadow", "FloatShadowThrough", "FloatShadowBorder" }, { fg = c.surface2, bg = c.crust })
	set({ "RedrawDebugComposed", "RedrawDebugClear" }, { fg = c.crust, bg = c.crust })
	hi("RedrawDebugRecompose", { fg = c.base, bg = c.base })
end

local function syntax(c)
	hi("Title", { fg = c.accent, bold = true })
	set({ "@text.title", "TSTitle", "@markup.heading" }, { link = "Title" })
	hi("@markup.heading.1.markdown", { fg = c.text, bold = true })
	hi("@markup.heading.2.markdown", { fg = c.accent, bold = true })
	for level = 3, 6 do
		hi(("@markup.heading.%d.markdown"):format(level), { fg = c.accent })
	end

	hi("Special", { fg = c.base0C })
	hi("Comment", { fg = c.overlay0, bg = "NONE", italic = true })
	set({ "@comment", "TSComment", "SpecialComment" }, { link = "Comment" })
	hi("@comment.error", { fg = c.base08, italic = true })
	hi("@comment.warning", { fg = c.base09, italic = true })
	hi("@comment.todo", { fg = c.accent, italic = true })
	hi("@comment.note", { fg = c.base0A, italic = true })
	set({ "EndOfBuffer", "Conceal", "SpecialKey" }, { fg = c.surface2 })
end

local function diagnostics(c)
	for _, s in ipairs(severity(c)) do
		local name, colour = s.lsp, s.colour
		set({ "Diagnostic" .. name, "DiagnosticSign" .. name }, { fg = colour })
		set({ "DiagnosticVirtualText" .. name, "DiagnosticFloating" .. name }, { fg = colour })
		set({ "DiagnosticVirtualLines" .. name, "DiagnosticSign" .. name .. "HL" }, { fg = colour })
		hi("DiagnosticUnderline" .. name, { sp = colour, undercurl = true })
	end
	set({ "DiagnosticOk", "DiagnosticUnnecessary" }, { fg = c.base0B })
	set({ "DiagnosticChanged", "Changed" }, { fg = c.base0D })
	set({ "DiagnosticDeprecated", "Removed" }, { fg = c.base08 })
	hi("Added", { fg = c.base0B })
	hi("DiagnosticUnderlineOk", { sp = c.base0B, undercurl = true })
	hi("DiagnosticUnderlineDeprecated", { sp = c.base08, undercurl = true })
end

local function diff(c)
	set({ "DiffAdd", "DiffviewDiffAdd" }, { fg = c.base0B })
	set({ "DiffChange", "DiffviewDiffChange" }, { fg = c.base0D })
	set({ "DiffDelete", "DiffviewDiffDelete", "DiffviewDiffAddAsDelete" }, { fg = c.base08 })
	hi("DiffText", { fg = c.text, bg = c.surface0 })
	hi("DiffTextAdd", { fg = c.base0B, bg = c.surface0 })
	hi("DiffTextChange", { fg = c.base0D, bg = c.surface0 })
	hi("DiffTextDelete", { fg = c.base08, bg = c.surface0 })
end

local function floating(c)
	hi("NormalFloat", { fg = c.text, bg = c.surface0 })
	hi("FloatBorder", { fg = c.surface2, bg = c.surface0 })
	hi("FloatTitle", { fg = c.base, bg = c.accent, bold = true })
	hi("FloatFooter", { fg = c.subtext0, bg = c.surface0 })

	hi("Pmenu", { fg = c.text, bg = c.surface0 })
	hi("PmenuSel", { fg = c.text, bg = c.surface1 })
	hi("PmenuThumb", { bg = c.surface1 })
	hi("PmenuMatch", { fg = c.accent, bg = c.surface0, bold = true })
	hi("PmenuMatchSel", { fg = c.accent, bg = c.surface1, bold = true })
	hi("WildMenu", { fg = c.text, bg = c.surface0 })

	set({ "NoiceCmdline", "NoiceCmdlinePopup" }, { fg = c.text, bg = c.surface0 })
	set({ "NoiceCmdlinePopupBorder", "NoiceCmdlinePopupTitle" }, { fg = c.accent, bg = c.surface0, bold = true })
	set({ "NoiceCmdlineIcon", "NoiceCmdlineIconSearch", "NoiceCmdlinePrompt" }, { fg = c.accent, bg = c.surface0 })
	hi("NoiceCmdlinePopupBorderSearch", { fg = c.accent, bg = c.surface0 })
	set({ "NoiceConfirm", "NoiceConfirmBorder" }, { fg = c.text, bg = c.surface0 })
	hi("NoicePopupmenu", { fg = c.text, bg = c.surface0 })
	hi("NoicePopupmenuSelected", { fg = c.text, bg = c.surface1 })
	hi("NoicePopupmenuMatch", { fg = c.accent, bg = c.surface0, bold = true })

	set({ "TermNormal", "TermNormalNC" }, { fg = c.text, bg = c.surface0 })
	set({ "TermCursor", "TermCursorNC" }, { fg = c.crust, bg = c.accent })
	set({ "SnacksTerminalNormal", "SnacksTerminalNormalNC" }, { fg = c.text, bg = c.surface0 })
	hi("SnacksTerminalCursor", { fg = c.crust, bg = c.accent })

	set({ "WhichKey", "WhichKeyGroup", "WhichKeyDesc" }, { fg = c.overlay0, bg = c.surface0 })
	set({ "WhichKeySeparator", "WhichKeyFloat", "WhichKeyNormal" }, { fg = c.surface1, bg = c.surface0 })
	set({ "WhichKeyValue", "WhichKeyBorder" }, { fg = c.text, bg = c.surface0 })
	set({ "WhichKeyIcon", "WhichKeyIconAzure" }, { fg = c.accent, bg = c.surface0 })
end

local function pickers(c)
	hi("TelescopeNormal", { fg = c.text, bg = c.surface0 })
	hi("TelescopeBorder", { fg = c.surface2, bg = c.surface0 })
	hi("TelescopePromptNormal", { fg = c.text, bg = c.surface0 })
	hi("TelescopePromptBorder", { fg = c.surface2, bg = c.surface0 })
	hi("TelescopePromptPrefix", { fg = c.accent, bg = c.surface0 })
	hi("TelescopePromptCounter", { fg = c.overlay0, bg = c.surface0 })
	hi("TelescopePromptTitle", { fg = c.base, bg = c.accent, bold = true })
	hi("TelescopeResultsTitle", { fg = c.base, bg = c.accent, bold = true })
	hi("TelescopePreviewTitle", { fg = c.base, bg = c.base0A, bold = true })
	hi("TelescopeSelection", { fg = c.text, bg = c.surface1 })
	hi("TelescopeSelectionCaret", { fg = c.accent, bg = c.surface1 })
	hi("TelescopeMatching", { fg = c.accent, bold = true })
	hi("TelescopePreviewLine", { bg = c.surface1 })

	hi("SnacksPickerNormal", { fg = c.text, bg = c.surface0 })
	hi("SnacksPickerList", { fg = c.text, bg = c.surface0 })
	hi("SnacksPickerListCursorLine", { fg = c.text, bg = c.surface1 })
	set({ "SnacksPickerDir", "SnacksPickerDirIcon" }, { fg = c.accent, bg = c.surface0 })
	hi("SnacksPickerFileIcon", { fg = c.overlay1, bg = c.surface0 })
	set({ "SnacksPickerSpecial", "SnacksPickerPrompt", "SnacksPickerTotals" }, { fg = c.accent, bg = c.surface0 })
	set({ "SnacksPickerPathHidden", "SnacksPickerPathIgnored" }, { fg = c.overlay0, bg = c.surface0 })
	hi("SnacksPickerBorder", { fg = c.surface2, bg = c.surface0 })
	hi("SnacksPickerTitle", { fg = c.base, bg = c.accent, bold = true })
	set({ "SnacksPickerSelected", "SnacksPickerListSelected" }, { fg = c.text, bg = c.surface1 })
	hi("SnacksPickerMatch", { fg = c.accent, bold = true })
	set({ "SnacksIndent", "SnacksIndentChunk", "SnacksIndentScope", "SnacksIndentUnderline" }, {
		fg = c.surface2,
		bg = c.base,
	})
end

-- bufferline resolves the buffer *name* through hl_group("buffer", "background")
-- (lua/bufferline/highlights.lua), so a plain inactive buffer is painted with
-- BufferLineBackground, not BufferLineBuffer: only "visible" (shown in another
-- window) and "selected" get their own groups. Painting it mantle-on-mantle is
-- what hid the inactive titles, so only the fill stays invisible.
local function buffers(c)
	hi("BufferLineBackground", { fg = c.subtext0, bg = c.mantle })
	hi("BufferLineFill", { fg = c.mantle, bg = c.mantle })
	-- Inactive titles need to stay readable: overlay0 on mantle is too close to
	-- the bar background to read, let alone to look like the crust behind it.
	set({
		"BufferLineBuffer",
		"BufferLineBufferVisible",
		"BufferLineTab",
		"BufferLineOffsetSeparator",
	}, { fg = c.subtext0, bg = c.mantle })
	set({ "BufferLineBufferSelected", "BufferLineTabSelected" }, { fg = c.text, bg = c.base, bold = true })
	set({ "BufferLineSeparator", "BufferLineTabSeparator" }, { fg = c.mantle, bg = c.mantle })
	set({ "BufferLineSeparatorSelected", "BufferLineTabSeparatorSelected" }, { fg = c.base, bg = c.base })
	set({ "BufferLineIndicatorVisible", "BufferLineIndicatorSelected" }, { fg = c.accent, bg = c.base })
	set({
		"BufferLineCloseButton",
		"BufferLineCloseButtonVisible",
		"BufferLineTabClose",
	}, { fg = c.overlay0, bg = c.mantle })
	set({ "BufferLineCloseButtonSelected", "BufferLineTabCloseSelected" }, { fg = c.text, bg = c.base })
	set({ "BufferLineNumbers", "BufferLineNumbersVisible" }, { fg = c.overlay0, bg = c.mantle })
	hi("BufferLineNumbersSelected", { fg = c.subtext0, bg = c.base })
	set({ "BufferLineModified", "BufferLineModifiedVisible" }, { fg = c.accent, bg = c.mantle })
	hi("BufferLineModifiedSelected", { fg = c.accent, bg = c.base, bold = true })
	set({ "BufferLineDuplicate", "BufferLineDuplicateVisible" }, { fg = c.subtext0, bg = c.mantle, italic = true })
	hi("BufferLineDuplicateSelected", { fg = c.subtext1, bg = c.base, italic = true })
	hi("BufferLineGroupLabel", { fg = c.accent, bg = c.mantle, bold = true })
	hi("BufferLineGroupSeparator", { fg = c.surface1, bg = c.mantle })
	set({ "BufferLineTruncMarker", "BufferLineDiagnostic", "BufferLineDiagnosticVisible" }, {
		fg = c.overlay0,
		bg = c.mantle,
	})
	hi("BufferLineDiagnosticSelected", { fg = c.subtext0, bg = c.base })
	set({ "BufferLinePick", "BufferLinePickVisible" }, { fg = c.text, bg = c.surface0 })
	hi("BufferLinePickSelected", { fg = c.text, bg = c.surface1 })
	for _, s in ipairs(severity(c)) do
		local name, colour = "BufferLine" .. s.bufferline, s.colour
		set({ name, name .. "Visible" }, { fg = colour, bg = c.mantle })
		hi(name .. "Diagnostic", { fg = colour, bg = c.mantle })
		hi(name .. "Selected", { fg = colour, bg = c.base })
		hi(name .. "DiagnosticSelected", { fg = colour, bg = c.base })
	end
end

-- Mode pill NORMAL: the fill carries the mode, the label is `base` on top of it.
local function statusline(c)
	local mode_fills = {
		-- One hue per mode, straight out of the palette: the accent for normal,
		-- the named blue/mauve roles for insert/visual, base16 slots for the
		-- rest. base0C (teal) is left out on purpose, it is the default accent
		-- and would collide with normal.
		normal = c.accent,
		insert = c.blue,
		visual = c.mauve,
		replace = c.base08,
		command = c.base0A,
		terminal = c.base0B,
		inactive = c.surface0,
	}
	for mode, fill in pairs(mode_fills) do
		local inactive = mode == "inactive"
		local bg = inactive and c.surface0 or fill
		M.lualine = M.lualine or {}
		M.lualine[mode] = {
			-- Dark label on the fill, like tmux's message-command-style: the
			-- fills are full-brightness accents now, not washes of base.
			a = { fg = inactive and c.text or c.base, bg = bg, bold = not inactive },
			-- One band per section, so a section reads as a single block: b (git
			-- branch) on surface2, everything from the filetype onwards on surface0.
			b = { fg = c.subtext0, bg = c.surface2 },
			c = { fg = c.text, bg = c.surface0 },
			x = { fg = c.subtext0, bg = c.surface0 },
			y = { fg = c.subtext0, bg = c.surface0 },
			z = { fg = c.subtext0, bg = c.surface0 },
		}
		-- The bar is surface0 edge to edge, so a cap's second colour is
		-- surface0 as well: the rounded end dissolves into the bar.
		hi("StatusLineCap_" .. mode, { fg = bg, bg = inactive and c.mantle or c.surface0 })
	end
	hi("StatusLine", { fg = c.subtext0, bg = c.surface0 })
	hi("StatusLineNC", { fg = c.overlay0, bg = c.mantle })
	-- Closing cap: the glyph is the bar colour so the round shape is carved out
	-- of the tail, and the cell behind it is base, so the line ends in a dark
	-- block instead of running flat to the window edge.
	hi("StatusLineCapRight", { fg = c.surface0, bg = c.base })
end

local function apply_overrides(p)
	local c = extend(p)
	M.palette = c

	base_ui(c)
	syntax(c)
	diagnostics(c)
	diff(c)
	floating(c)
	pickers(c)
	buffers(c)
	statusline(c)
end

local mode_names = {
	n = "normal",
	no = "normal",
	nov = "normal",
	i = "insert",
	ic = "insert",
	ix = "insert",
	v = "visual",
	V = "visual",
	["\22"] = "visual",
	s = "visual",
	S = "visual",
	["\19"] = "visual",
	R = "replace",
	Rv = "replace",
	c = "command",
	cv = "command",
	ce = "command",
	t = "terminal",
}

function M.lualine_mode()
	return mode_names[vim.fn.mode()] or "normal"
end

function M.lualine_theme()
	return M.lualine
end

function M.sync_lualine()
	if not M.lualine or not package.loaded["lualine.highlight"] then
		return
	end
	pcall(function()
		require("lualine.highlight").create_highlight_groups(M.lualine)
		require("lualine").refresh()
	end)
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

	local palette, err = read_palette()
	if not palette then
		M.loading = false
		vim.notify(err, vim.log.levels.ERROR, { title = "theme" })
		return
	end

	base16().setup(palette)
	apply_overrides(palette)
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
