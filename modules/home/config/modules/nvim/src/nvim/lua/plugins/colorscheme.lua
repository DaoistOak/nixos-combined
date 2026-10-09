-- The theme-switcher colorscheme is the only theme in this config.
--
-- LazyVim's colorscheme is picked in lazyvim/config (the table with
-- `colorscheme = function() require("tokyonight").load() end`); passing it as an
-- option on the LazyVim spec replaces that function, so LazyVim follows
-- ~/.config/theme-switcher/nvim-base16.lua like everything else on the desktop.
--
-- <leader>uC is Snacks' colorscheme picker (LazyVim's snacks_picker extra). It is
-- removed in lua/config/keymaps.lua instead of here: it is defined on the extra's
-- own spec, and lazy.nvim merges two specs for the same plugin positionally, so
-- neither keys.del (which this lazy.nvim version does not implement) nor a
-- `false` rhs could address that one entry reliably. It only existed to load
-- another theme, and the theme is switched from outside nvim with
-- `theme set <theme>`.
--
-- tokyonight and catppuccin are LazyVim's own colorscheme specs. Nothing else
-- uses them, so they are disabled rather than left installed as a way for
-- another theme to slip in (the old config picked tokyonight's "moon" style).
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "theme-switcher",
    },
  },

  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", name = "catppuccin", enabled = false },
}
