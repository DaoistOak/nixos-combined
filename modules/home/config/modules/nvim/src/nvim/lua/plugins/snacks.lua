-- The Snacks override lives here rather than in the lualine-style `config` block
-- because LazyVim's snacks spec is also a function, and a second `opts` table
-- would be merged positionally over the sources table it already defines.
--
-- LazyVim's defaults (`picker.sources.explorer`) are:
--   layout = { preset = "sidebar" }, cwd = true, hidden = false, ignored = true,
--   follow = false, show_hidden = false, ...
-- so the explorer opens as a right sidebar and dotfiles are filtered out. Only
-- `hidden` is changed here; `opts.picker.sources.explorer.hidden = true` feeds
-- `:Neotree`-style dotfile visibility into the explorer source and keeps them in
-- the list, `picker.hidden` is left alone because that would also pull dotfiles
-- into fuzzy finders and buffers.
return {
	{
		"folke/snacks.nvim",
		opts = {
			picker = {
				sources = {
					explorer = {
						hidden = true,
					},
				},
			},
		},
	},
}
