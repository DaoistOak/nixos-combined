-- render-markdown, loaded eagerly.
--
-- LazyVim gates it behind FileType (markdown, norg, rmd, org, codecompanion),
-- and that is normally invisible. It is not here, because plugin directories
-- come from nixpkgs and are therefore on the runtimepath from startup whether
-- lazy.nvim has loaded a plugin or not -- which breaks Snacks' ability to tell
-- the two apart. See snacks/picker/util/markdown.lua:
--
--   pcall(require, "render-markdown")   -- "trigger plugin loading if available"
--   ...
--   if package.loaded["render-markdown"] then
--     require("render-markdown").render({ ... })
--   end
--
-- With an ordinary plugin manager that require fails for a plugin that is
-- installed but not loaded, package.loaded stays nil, and Snacks falls through
-- to markview. Under Nix the require always succeeds, so Snacks calls render()
-- on a plugin whose setup() never ran, and lib/config.lua indexes a nil root:
--
--   attempt to index local 'root' (a nil value)
--
-- It fires in the notification picker's preview, which is where it showed up.
-- Setting ft = false clears LazyVim's FileType trigger (lazy merges specs with
-- a deep-extend, so an empty table would not have overwritten the list) and
-- lazy = false loads it at startup, so setup() runs before anything can render.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = false,
    lazy = false,
  },
}
