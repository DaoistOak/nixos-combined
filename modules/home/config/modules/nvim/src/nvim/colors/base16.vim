" base16 entry point. The palette itself is generated from the tracked theme
" selection (see modules/config/themes/colors); lua/theme.lua applies it and
" listens for SIGUSR1.
lua require("theme").load()
