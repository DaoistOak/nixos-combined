-- The Snacks override lives here rather than in the lualine-style `config` block
-- because LazyVim's snacks spec is also a function, and a second `opts` table
-- would be merged positionally over the sources table it already defines.
--
-- LazyVim only sets `layout = { preset = "sidebar" }` and `cwd` for
-- `picker.sources.explorer`, and `hidden` is what makes dotfiles appear here.
-- `ignored` is the one that decides whether gitignored files are listed, and
-- leaving it unset means snacks' own source default, `ignored = false` --
-- so `build/` and `bin/` stayed invisible until this was set to true.
-- `picker.hidden` is left alone because that would also pull dotfiles into
-- fuzzy finders and buffers.
--
-- `i` toggles it per session inside the explorer, so this is the persistent
-- setting rather than the only way to see them.
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
          },
        },
      },
    },
  },
}
