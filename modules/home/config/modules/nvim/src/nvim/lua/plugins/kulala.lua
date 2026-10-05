-- kulala.nvim ships its own fork of the HTTP tree-sitter grammar and installs it
-- at runtime: it clones tree-sitter-kulala-http into stdpath("data"), then runs
-- `tree-sitter build -o stdpath("data")/site/parser/kulala_http.so` and copies
-- its queries into stdpath("data")/site/queries (kulala/config/parser.lua).
--
-- Both destinations are home-manager symlinks into the read-only nix store
-- (programs.lazyvim.treesitterParsers installs the parser set the same way), so
-- the compile step dies with "ld: cannot open output file ...: Read-only file
-- system" and the queries never land. Because kulala only considers itself set
-- up once the parser *and* the queries are present, it re-ran the whole clone on
-- every startup, first complaining that the `tree-sitter` CLI was missing.
--
-- The `http` parser from nixpkgs is already in treesitterParsers, and
-- plugins/_lazyvim_nix_treesitter points the `http` and `rest` filetypes at it,
-- so the buffers kulala opens are still highlighted.
return {
	{
		"kulala.nvim",
		opts = {
			treesitter = {
				enable = false,
			},
		},
		config = function()
			-- kulala locks its response buffers read-only and restores that state
			-- across sessions, which can leave the shared kulala://scratchpad
			-- buffer modifiable=false; its own scratchpad command then dies with
			-- "Buffer is not 'modifiable'". Request buffers are meant to be typed
			-- into, so drop the lock whenever one is loaded.
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("kulala_nix", { clear = true }),
				pattern = "http",
				callback = function(args)
					vim.bo[args.buf].modifiable = true
				end,
			})
		end,
	},
}
