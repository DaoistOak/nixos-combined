local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#24273a',
    base01 = '#363a4f',
    base02 = '#3e435b',
    base03 = '#6e738d',
    base04 = '#a5adcb',
    base05 = '#cad3f5',
    base06 = '#cad3f5',
    base07 = '#cad3f5',
    base08 = '#ed8796',
    base09 = '#8bd5ca',
    base0A = '#8aadf4',
    base0B = '#8bd5ca',
    base0C = '#96e9dc',
    base0D = '#96e9dc',
    base0E = '#8aadf4',
    base0F = '#b9cef8',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#cad3f5',       bg = '#24273a' })
  hi('TelescopeBorder',         { fg = '#6e738d',       bg = '#24273a' })
  hi('TelescopePromptNormal',   { fg = '#cad3f5',       bg = '#24273a' })
  hi('TelescopePromptBorder',   { fg = '#6e738d',       bg = '#24273a' })
  hi('TelescopePromptPrefix',   { fg = '#8bd5ca',       bg = '#24273a' })
  hi('TelescopePromptCounter',  { fg = '#a5adcb',       bg = '#24273a' })
  hi('TelescopePromptTitle',    { fg = '#24273a',       bg = '#8bd5ca' })
  hi('TelescopePreviewTitle',   { fg = '#24273a',       bg = '#8aadf4' })
  hi('TelescopeResultsTitle',   { fg = '#24273a',       bg = '#8bd5ca' })
  hi('TelescopeSelection',      { fg = '#cad3f5',       bg = '#3e435b' })
  hi('TelescopeSelectionCaret', { fg = '#8bd5ca',       bg = '#3e435b' })
  hi('TelescopeMatching',       { fg = '#8bd5ca',       bold = true })

  hi('MiniPickNormal',         { fg = '#cad3f5',       bg = '#24273a' })
  hi('MiniPickBorder',         { fg = '#6e738d',       bg = '#24273a' })
  hi('MiniPickPrompt',         { fg = '#cad3f5',       bg = '#24273a' })
  hi('MiniPickPromptPrefix',   { fg = '#8bd5ca',       bg = '#24273a' })
  hi('MiniPickBorderText',     { fg = '#24273a',       bg = '#8bd5ca' })
  hi('MiniPickMatchCurrent',   { fg = '#cad3f5',       bg = '#3e435b' })
  hi('MiniPickPromptCaret',    { fg = '#8bd5ca',       bg = '#3e435b' })
  hi('MiniPickMatchRanges',    { fg = '#8bd5ca',       bold = true })
end

if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M