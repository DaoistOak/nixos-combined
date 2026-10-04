-- Mason is disabled; mark servers so LazyVim calls vim.lsp.enable itself.
-- Executables come from programs.lazyvim.extraPackages.
local function noMason(servers)
	for name, config in pairs(servers) do
		if name ~= "*" and type(config) == "table" then
			config.mason = false
		elseif name ~= "*" and config == true then
			servers[name] = { mason = false }
		end
	end
	return servers
end

return {
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			opts.servers = noMason(opts.servers or {})
			local function with_cmd(name, cmd)
				local current = opts.servers[name]
				if type(current) == "function" then
					return
				end
				opts.servers[name] = vim.tbl_extend("force", type(current) == "table" and current or {}, {
					mason = false,
					cmd = cmd,
				})
			end
			with_cmd("html", { "vscode-html-language-server", "--stdio" })
			with_cmd("cssls", { "vscode-css-language-server", "--stdio" })
			return opts
		end,
	},
}
