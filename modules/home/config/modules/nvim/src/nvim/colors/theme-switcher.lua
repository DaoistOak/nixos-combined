-- The colorscheme entry point.
--
-- LazyVim.config.colorscheme is set to "theme-switcher" (see
-- lua/plugins/colorscheme.lua), so LazyVim applies this file at startup and
-- :colorscheme theme-switcher re-applies it by hand. Everything comes from the
-- palette that scripts/theme keeps up to date in
-- ~/.config/theme-switcher/nvim-base16.lua.
--
-- setup() comes first so the ColorScheme autocmd and the SIGUSR1 handler are in
-- place before load() starts; setting 'background' inside load() re-sources this
-- file, and that inner pass should already know how to repaint.
local theme = require("theme")

theme.setup()
theme.load()
