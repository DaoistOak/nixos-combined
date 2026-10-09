-- copilot.lua. It normally downloads its own copilot-language-server into
-- stdpath("data")/copilot.lua/lsp on first use, but that static binary cannot
-- find libstdc++ on NixOS. When a packaged server is on $PATH it is used instead
-- (`nix profile install nixpkgs#copilot-language-server`), otherwise the download
-- path is left alone.
--
-- The old `<Tab>` accept bind is not ported: LazyVim gives <Tab> to blink.cmp, so
-- both mappings would fire on the same key. copilot.lua's own default (<M-]>)
-- applies; add a keymap here only if blink's <Tab> is remapped away.
local server = vim.fn.executable("copilot-language-server") == 1 and "copilot-language-server" or nil

return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      server = server and { custom_server_filepath = server } or nil,
    },
  },
}
