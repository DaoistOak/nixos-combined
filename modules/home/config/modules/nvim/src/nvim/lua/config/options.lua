-- Loaded by LazyVim before plugins start, so the palette is applied first and
-- the signal handler is in place before anything can trigger a reload.
require("theme").setup()

-- LazyVim v16 stores the colorscheme on lazyvim.config; assigning the field
-- survives later empty setup() calls. colors/base16.vim -> lua/theme.lua
require("lazyvim.config").colorscheme = "base16"

-- Soft wrap. LazyVim sets wrap=false; this file loads after those defaults.
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.breakindentopt = "sbr,min:20"
vim.opt.showbreak = " 󰌑 "
-- Put the showbreak marker in the number column (`:h cpo-n`).
vim.opt.cpo:append("n")

-- nvim-neoclip's sqlite backend needs the C library. lua/config/nix.lua is
-- generated from pkgs.sqlite; the profile glob is a fallback.
do
	local ok, nix = pcall(require, "config.nix")
	if ok and not vim.g.sqlite_clib_path and nix.sqlite_clib and vim.uv.fs_stat(nix.sqlite_clib) then
		vim.g.sqlite_clib_path = nix.sqlite_clib
	end

	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		once = true,
		callback = function()
			if vim.g.sqlite_clib_path then
				return
			end

			local patterns = {
				vim.fn.expand("~/.nix-profile/lib/libsqlite3.so*"),
				"/nix/var/nix/profiles/default/lib/libsqlite3.so*",
				"/run/current-system/sw/lib/libsqlite3.so*",
			}
			for _, pattern in ipairs(patterns) do
				for _, path in ipairs(vim.fn.glob(pattern, false, true)) do
					if vim.uv.fs_stat(path) then
						vim.g.sqlite_clib_path = path
						return
					end
				end
			end
		end,
	})
end
