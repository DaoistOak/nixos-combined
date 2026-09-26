-- base16-nvim applies the palette that scripts/theme writes (see
-- lua/theme.lua). It has to be requirable while the colorscheme is being
-- applied, so keep it out of the lazy-loading path; theme.load() still pulls it
-- in through lazy if the colorscheme runs before startup finished.
return {
  { "folke/base16-nvim", lazy = false },
}
