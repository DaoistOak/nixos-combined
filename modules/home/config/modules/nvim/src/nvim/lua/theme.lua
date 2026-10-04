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

local function apply_overrides(p)
  local c = p

  -- The named neutral roles (crust/mantle/base/surface0..2) were added to the
  -- generated palette after the first base16-only files shipped, so a stale
  -- ~/.config/theme-switcher/nvim-base16.lua can still be missing them. Fall
  -- back to the base16 slot holding the same step of the ramp rather than
  -- rendering a half-themed ui.
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

  -- Keep the resolved palette around: the lualine theme table and the statusline
  -- caps below are derived from it, and both have to be rebuilt on SIGUSR1.
  M.palette = c

  local function hi(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  local function set(groups, opts)
    for _, group in ipairs(groups) do
      hi(group, opts)
    end
  end

  -- Blend two palette hexes. The neutral ramp has no slot between base and
  -- surface0, and the cursorline has to be visible against the canvas without
  -- reading as a different panel.
  local function mix(a, b, amount)
    local function channel(shift)
      local ca = tonumber(a:sub(shift, shift + 1), 16)
      local cb = tonumber(b:sub(shift, shift + 1), 16)
      return string.format("%02x", math.floor(ca + (cb - ca) * amount + 0.5))
    end
    return string.format("#%s%s%s", channel(2), channel(4), channel(6))
  end

  -- Layered backgrounds. base16 collapses the neutral ramp onto
  -- base00..base02, so the editor, the tab bar and the explorer all ended up on
  -- one flat panel. The ramp is used as one layer per surface:
  --
  --   crust    the darkest step: the bar behind the tabs (the space left beside
  --            them), the statusline strip and the window separators
  --   mantle   one step up: the inactive tab headers
  --   base     the editor canvas, and the active tab header so it reads as
  --            continuous with the text area
  --   surface0 chrome: file explorer, cmdline, scratch buffer
  --   surface1 selected rows inside that chrome
  --   surface2 separators and filler text
  --
  -- Backing the editor with `base` rather than `crust` puts the canvas *above*
  -- the tab bar, which is what makes the active tab look like a hole cut into
  -- the bar instead of a tab that is lighter than its neighbours.
  hi("Normal", { fg = c.text, bg = c.base })
  hi("NormalNC", { fg = c.text, bg = c.base })
  hi("SignColumn", { fg = c.subtext0, bg = c.base })
  hi("SignColumnSB", { fg = c.subtext0, bg = c.base })
  hi("CursorLine", { bg = mix(c.base, c.surface0, 0.45) })
  hi("CursorLineNr", { bg = mix(c.base, c.surface0, 0.45) })
  hi("CursorLineSign", { bg = mix(c.base, c.surface0, 0.45) })
  hi("WinSeparator", { fg = c.crust, bg = c.base })
  hi("VertSplit", { fg = c.crust, bg = c.base })

  -- Floating panels sit a step above the canvas rather than on it.
  hi("NormalFloat", { fg = c.text, bg = c.base })
  hi("FloatBorder", { fg = c.surface1, bg = c.base })
  hi("FloatTitle", { fg = c.base, bg = c.accent, bold = true })
  hi("FloatFooter", { fg = c.subtext0, bg = c.base })
  set({ "Pmenu", "PmenuSel" }, { fg = c.text, bg = c.base })
  hi("PmenuSel", { bg = c.surface0 })
  hi("PmenuMatch", { fg = c.accent, bg = c.base, bold = true })
  hi("PmenuMatchSel", { fg = c.accent, bg = c.surface0, bold = true })
  set({ "WildMenu", "WildMenuSel" }, { fg = c.text, bg = c.base })

  -- File explorer.
  set({ "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer", "NeoTreeWinSeparator", "NeoTreeVertSplit" }, {
    fg = c.text,
    bg = c.surface0,
  })
  set(
    { "NeoTreeDirectoryName", "NeoTreeRootName", "NeoTreeFileName", "NeoTreeFileIcon", "NeoTreeSymbolicLinkTarget" },
    {
      fg = c.text,
    }
  )
  set({ "NeoTreeDirectoryIcon", "NeoTreeRootIcon" }, { fg = c.accent, bg = c.surface0 })
  set({ "NeoTreeCursorLine", "NeoTreeWinBar" }, { fg = c.text, bg = c.surface0, bold = true })
  set({ "NeoTreeGitAdded", "NeoTreeGitModified", "NeoTreeGitDeleted" }, { fg = c.accent, bg = c.surface0 })
  hi("NeoTreeIndentMarker", { fg = c.surface1, bg = c.surface0 })
  hi("NeoTreeDimText", { fg = c.overlay0, bg = c.surface0 })

  -- Cmdline and the scratch/toggle buffer.
  set({ "CmdLine", "CmdLinePopup", "CmdLinePopupBorder" }, { fg = c.text, bg = c.surface0 })
  hi("CmdLinePopup", { fg = c.text, bg = c.surface0 })
  set({ "NoiceCmdline", "NoiceCmdlinePopup" }, { fg = c.text, bg = c.surface0 })
  set({ "NoiceCmdlinePopupBorder", "NoiceCmdlinePopupTitle" }, { fg = c.accent, bg = c.surface0, bold = true })
  set({ "NoiceCmdlineIcon", "NoiceCmdlineIconSearch", "NoiceCmdlinePrompt" }, { fg = c.accent, bg = c.surface0 })
  set({ "NoiceCmdlinePopupBorderSearch" }, { fg = c.accent, bg = c.surface0 })
  set({ "NoiceConfirm", "NoiceConfirmBorder" }, { fg = c.text, bg = c.surface0 })
  set({ "NoicePopupmenu", "NoicePopupmenuSelected", "NoicePopupmenuMatch" }, { fg = c.text, bg = c.base })
  set({ "TermNormal", "TermNormalNC", "TermCursor" }, { fg = c.text, bg = c.surface0 })
  set({ "TermCursor", "TermCursorNC" }, { fg = c.crust, bg = c.accent })
  set({ "SnacksTerminalNormal", "SnacksTerminalNormalNC" }, { fg = c.text, bg = c.surface0 })
  set({ "SnacksTerminalCursor" }, { fg = c.crust, bg = c.accent })
  set({ "ToggleTermNormal", "ToggleTermNormalNC" }, { fg = c.text, bg = c.surface0 })

  -- Bufferline. Three steps, darkest first: crust is the bar the tabs sit on
  -- (and so the colour of the empty space beside them), mantle is an inactive
  -- tab, and the active tab takes the editor background so it reads as
  -- continuous with the text area. LazyVim left the active tab's name on
  -- surface0, which is darker than the overlay0 used for inactive tabs, so the
  -- current buffer read as dimmer than its neighbours, and it gave the fill
  -- (BufferLineFill) the same colour as the tabs, so the bar had no edge at all.
  set({ "BufferLineBackground", "BufferLineFill" }, { fg = c.crust, bg = c.crust })
  set({
    "BufferLineBuffer",
    "BufferLineBufferVisible",
    "BufferLineTab",
    "BufferLineOffsetSeparator",
  }, {
    fg = c.overlay0,
    bg = c.mantle,
  })
  set({ "BufferLineBufferSelected", "BufferLineTabSelected" }, { fg = c.text, bg = c.base, bold = true })
  -- Separators take the colour of the surface they sit on so the bar reads as
  -- one piece and the active tab opens up out of it.
  set({ "BufferLineSeparator", "BufferLineTabSeparator" }, { fg = c.crust, bg = c.mantle })
  set({ "BufferLineSeparatorSelected", "BufferLineTabSeparatorSelected" }, { fg = c.base, bg = c.base })
  set({ "BufferLineIndicatorVisible", "BufferLineIndicatorSelected" }, { fg = c.accent, bg = c.base })
  set(
    { "BufferLineCloseButton", "BufferLineCloseButtonVisible", "BufferLineTabClose" },
    { fg = c.surface2, bg = c.mantle }
  )
  set({ "BufferLineCloseButtonSelected" }, { fg = c.text, bg = c.crust })
  set({ "BufferLineNumbers", "BufferLineNumbersVisible" }, { fg = c.overlay0, bg = c.mantle })
  set({ "BufferLineNumbersSelected" }, { fg = c.subtext0, bg = c.crust })
  set({ "BufferLineModified", "BufferLineModifiedVisible" }, { fg = c.accent, bg = c.mantle })
  set({ "BufferLineModifiedSelected" }, { fg = c.accent, bg = c.crust, bold = true })
  set({ "BufferLineDuplicate", "BufferLineDuplicateVisible" }, { fg = c.subtext0, bg = c.mantle, italic = true })
  set({ "BufferLineDuplicateSelected" }, { fg = c.subtext1, bg = c.crust, italic = true })
  set({ "BufferLineGroupLabel" }, { fg = c.accent, bg = c.mantle, bold = true })
  set({ "BufferLineGroupSeparator" }, { fg = c.surface1, bg = c.mantle })
  set(
    { "BufferLineTruncMarker", "BufferLineDiagnostic", "BufferLineDiagnosticVisible" },
    { fg = c.overlay0, bg = c.mantle }
  )
  set({ "BufferLineDiagnosticSelected" }, { fg = c.subtext0, bg = c.crust })
  set({ "BufferLinePick", "BufferLinePickVisible" }, { fg = c.text, bg = c.surface0 })
  set({ "BufferLinePickSelected" }, { fg = c.text, bg = c.surface1 })
  for _, severity in ipairs({ "Error", "Warning", "Info", "Hint" }) do
    local colour = ({ Error = c.base08, Warning = c.base09, Info = c.base0D, Hint = c.base0C })[severity]
    set({ "BufferLine" .. severity, "BufferLine" .. severity .. "Visible" }, { fg = colour, bg = c.mantle })
    set({ "BufferLine" .. severity .. "Diagnostic" }, { fg = colour, bg = c.mantle })
    set({ "BufferLine" .. severity .. "Selected" }, { fg = colour, bg = c.crust })
    set({ "BufferLine" .. severity .. "DiagnosticSelected" }, { fg = colour, bg = c.crust })
  end

  -- Headings. base16 points Title/@text.title at base0D, but the lsp diagnostic
  -- holograms repaint it once they are set up, which is what left headings on a
  -- lighter teal that is in no palette. Pin them to the accent and give each
  -- markdown level its own weight instead of one flat colour for all of them.
  hi("Title", { fg = c.accent, bold = true })
  set({ "@text.title", "TSTitle", "@markup.heading" }, { link = "Title" })
  hi("@markup.heading.1.markdown", { fg = c.text, bold = true })
  hi("@markup.heading.2.markdown", { fg = c.accent, bold = true })
  for level = 3, 6 do
    hi(("@markup.heading.%d.markdown"):format(level), { fg = c.accent })
  end
  hi("Special", { fg = c.base0C })

  -- Comments. base16 sets Comment on base03 without italics but TSComment with
  -- them, so the same comment came out slanted in some filetypes and upright in
  -- others; base03 is also the colour of EndOfBuffer and of the inactive buffer
  -- name, which made comments read as interface chrome. One shared, italic
  -- comment colour, and the non-text filler pushed a step further down.
  hi("Comment", { fg = c.overlay0, italic = true })
  set({ "@comment", "TSComment", "SpecialComment" }, { link = "Comment" })
  hi("@comment.error", { fg = c.base08, italic = true })
  hi("@comment.warning", { fg = c.base09, italic = true })
  hi("@comment.todo", { fg = c.accent, italic = true })
  hi("@comment.note", { fg = c.base0A, italic = true })
  set({ "EndOfBuffer", "Conceal", "NonText", "SpecialKey" }, { fg = c.surface2 })

  -- Diagnostics, git signs, diffs and search. Nothing in theme.lua set these, so
  -- they kept whatever defaults the plugins brought with them: DiagnosticOk,
  -- DiagnosticChanged and the git sign groups landed on a green/red/cyan that is
  -- in no Catppuccin flavour, and the Diff* backgrounds on a neutral grey-blue
  -- that ignored the layered canvas. Pin every one of them to the base16 accent
  -- slots so a green sign is the same green as the bufferline error dot.
  local severity_colour = { Error = c.base08, Warn = c.base09, Info = c.base0D, Hint = c.base0C }
  for severity, colour in pairs(severity_colour) do
    set({ "Diagnostic" .. severity, "DiagnosticSign" .. severity }, { fg = colour })
    set({ "DiagnosticVirtualText" .. severity, "DiagnosticFloating" .. severity }, { fg = colour })
    set({ "DiagnosticVirtualLines" .. severity, "DiagnosticSign" .. severity .. "HL" }, { fg = colour })
    hi("DiagnosticUnderline" .. severity, { sp = colour, undercurl = true })
  end
  set({ "DiagnosticOk", "DiagnosticUnnecessary" }, { fg = c.base0B })
  set({ "DiagnosticChanged", "Changed" }, { fg = c.base0D })
  set({ "DiagnosticDeprecated", "Removed" }, { fg = c.base08 })
  set({ "Added" }, { fg = c.base0B })
  hi("DiagnosticUnderlineOk", { sp = c.base0B, undercurl = true })
  hi("DiagnosticUnderlineDeprecated", { sp = c.base08, undercurl = true })
  set({ "DiffAdd", "DiffviewDiffAdd" }, { fg = c.base0B })
  set({ "DiffChange", "DiffviewDiffChange" }, { fg = c.base0D })
  set({ "DiffDelete", "DiffviewDiffDelete", "DiffviewDiffAddAsDelete" }, { fg = c.base08 })
  hi("DiffText", { fg = c.text, bg = c.surface0 })
  hi("DiffTextAdd", { fg = c.base0B, bg = c.surface0 })
  hi("DiffTextChange", { fg = c.base0D, bg = c.surface0 })
  hi("DiffTextDelete", { fg = c.base08, bg = c.surface0 })

  -- Search keeps a light background so the match is unmissable, which means the
  -- text has to go dark to stay readable on it.
  hi("CurSearch", { fg = c.crust, bg = c.base0A, bold = true })
  hi("IncSearch", { fg = c.crust, bg = c.base0B, bold = true })
  hi("Search", { bg = c.surface0 })

  -- Float shadows, the completion scrollbar thumb and the redraw debug overlay
  -- are all painted in greys that belonged to no palette layer.
  set({ "FloatShadow", "FloatShadowThrough", "FloatShadowBorder" }, { fg = c.surface2, bg = c.crust })
  hi("PmenuThumb", { bg = c.surface1 })
  set({ "RedrawDebugComposed", "RedrawDebugClear" }, { fg = c.crust, bg = c.crust })
  hi("RedrawDebugRecompose", { fg = c.base, bg = c.base })

  -- Pickers.
  hi("TelescopeNormal", { fg = c.text, bg = c.base })
  hi("TelescopeBorder", { fg = c.surface1, bg = c.base })
  hi("TelescopePromptNormal", { fg = c.text, bg = c.base })
  hi("TelescopePromptBorder", { fg = c.surface1, bg = c.base })
  hi("TelescopePromptPrefix", { fg = c.accent, bg = c.base })
  hi("TelescopePromptCounter", { fg = c.overlay0, bg = c.base })
  hi("TelescopePromptTitle", { fg = c.base, bg = c.accent, bold = true })
  hi("TelescopeResultsTitle", { fg = c.base, bg = c.accent, bold = true })
  hi("TelescopePreviewTitle", { fg = c.base, bg = c.base0A, bold = true })
  hi("TelescopeSelection", { fg = c.text, bg = c.surface0 })
  hi("TelescopeSelectionCaret", { fg = c.accent, bg = c.surface0 })
  hi("TelescopeMatching", { fg = c.accent, bold = true })
  set({ "SnacksPickerNormal", "SnacksPickerList", "SnacksPickerDir" }, { fg = c.text, bg = c.base })
  set({ "SnacksPickerDir" }, { fg = c.accent, bg = c.base })
  set({ "SnacksPickerBorder" }, { fg = c.surface1, bg = c.base })
  set({ "SnacksPickerTitle" }, { fg = c.base, bg = c.accent, bold = true })
  set({ "SnacksPickerSelected", "SnacksPickerListSelected" }, { fg = c.text, bg = c.surface0 })
  set({ "SnacksPickerMatch" }, { fg = c.accent, bold = true })
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
  vim.g.colors_name = "base16"
  M.loading = false
end

function M.setup()
  if M.signal then
    return
  end

  vim.api.nvim_create_user_command("ThemeReload", M.load, { desc = "Reload the theme-switcher palette" })

  -- base16 runs before the plugins are set up and several of them then repaint
  -- groups the colorscheme owns: the lsp diagnostic holograms overwrite
  -- Title/@text.title, and bufferline and noice set their own. Re-apply once
  -- that has happened so the layered backgrounds and the heading ramp win.
  local group = vim.api.nvim_create_augroup("theme_switcher", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    desc = "Re-apply the theme-switcher palette after a colorscheme change",
    callback = function()
      vim.schedule(M.load)
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    desc = "Re-apply the theme-switcher palette once the plugins have set up",
    callback = function()
      vim.schedule(M.load)
    end,
  })

  M.signal = vim.uv.new_signal()
  M.signal:start("sigusr1", vim.schedule_wrap(M.load))
end

return M
