-- Thin wrapper around nvim_set_hl, plus a metatable so painters can read as
-- `hl.Normal { fg = ... }` (or `hl("Normal", { fg = ... })`).
--
-- `default` is deliberately NOT set: a colorscheme has to win over Neovim's
-- built-in defaults for groups like Normal and Comment, and anything that wants
-- to override the theme afterwards (a plugin, a user autocmd) runs later and so
-- still has the last word.

local M = {}

function M.set(name, spec)
  if not vim.tbl_isempty(spec) then
    vim.api.nvim_set_hl(0, name, spec)
  end
end

--- Paint `name` from `target` through a link.
function M.link(name, target)
  M.set(name, { link = target })
end

-- Groups whose only purpose is the struck-through rendering; they are fully
-- cleared so a link chain resolving into them paints nothing at all.
local strike_only = {
  TSStrike = true,
  ["@text.strike"] = true,
  ["@markup.strikethrough"] = true,
}

--- Strip the strikethrough attribute from every highlight group.
--- Callers outside this theme (base16-nvim, Neovim's runtime defaults) set it
--- again, so this runs after every repaint and once at VeryLazy.
function M.clear_strikethrough()
  for name, spec in pairs(vim.api.nvim_get_hl(0, {})) do
    if not spec.link and (spec.strikethrough or (spec.cterm and spec.cterm.strikethrough)) then
      if strike_only[name] then
        vim.api.nvim_set_hl(0, name, {})
      else
        spec.strikethrough = nil
        if spec.cterm then
          spec.cterm.strikethrough = nil
        end
        vim.api.nvim_set_hl(0, name, spec)
      end
    end
  end
end

return setmetatable(M, {
  __call = function(_, name, spec)
    M.set(name, spec)
  end,
  __index = function(_, name)
    return function(spec)
      M.set(name, spec)
    end
  end,
})
