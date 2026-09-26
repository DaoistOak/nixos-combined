-- LazyVim hands the default servers to mason-lspconfig for enabling (see
-- plugins/lsp/init.lua: `local use_mason = sopts.mason ~= false and ...`). The
-- module disables Mason, so nothing would ever be enabled. Marking every
-- server `mason = false` makes LazyVim call `vim.lsp.enable` itself; the
-- executables come from programs.lazyvim.extraPackages, since nothing can be
-- installed at runtime.
local function noMason(servers)
  for name, config in pairs(servers) do
    if name ~= "*" then
      servers[name] = type(config) == "table" and vim.tbl_extend("force", config, { mason = false })
        or { mason = false }
    end
  end
  return servers
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = noMason(opts.servers or {})
      opts.servers = vim.tbl_extend("force", opts.servers, {
        -- Only reached when the server is enabled for its filetype.
        html = { cmd = { "vscode-html-language-server", "--stdio" } },
        cssls = { cmd = { "vscode-css-language-server", "--stdio" } },
      })
      return opts
    end,
  },
}
