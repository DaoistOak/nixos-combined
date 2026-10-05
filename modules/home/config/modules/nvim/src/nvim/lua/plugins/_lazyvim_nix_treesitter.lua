-- Parsers are pre-built by Nix and linked into stdpath("data")/site/parser (see
-- programs.lazyvim.treesitterParsers), which is a symlink into the read-only
-- nix store. LazyVim's runtime installer would need the tree-sitter CLI, a C
-- compiler and a writable parser directory, none of which exist here, so it gets
-- replaced with a no-op below.
--
-- One wrinkle has to be papered over first: nvim-treesitter maps the filetype
-- `http` to the *language* `rest`, but the nixpkgs package is tree-sitter-http,
-- whose parser registers the language `http`. Left alone, LazyVim resolves
-- `http` to `rest`, finds no `rest` parser installed, and asks for a runtime
-- install on every buffer -- including `.rest` files, which resolve the same way.
-- Pointing both filetypes at the parser that is actually installed settles it;
-- no extra package is needed since nixpkgs has no `rest` parser.
vim.treesitter.language.register("http", { "http", "rest" })

-- LazyDone fires before any LazyFile/VeryLazy plugin loads, so the overrides are
-- in place before LazyVim's treesitter config runs.
vim.api.nvim_create_autocmd("User", {
	pattern = "LazyDone",
	once = true,
	callback = function()
		local ok, ts = pcall(require, "lazyvim.util.treesitter")
		if not ok or not ts then
			return
		end
		-- Parsers come from Nix, so whatever is missing is a configuration problem
		-- rather than something to install; do not run the CLI on every attempt.
		ts.check = function()
			return true, { ["nix"] = true }
		end
		ts.build = function() end
	end,
})

return {}
