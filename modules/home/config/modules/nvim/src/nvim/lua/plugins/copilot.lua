-- copilot.lua downloads its own copilot-language-server into
-- stdpath("data")/copilot.lua/lsp on first use, and that static binary cannot
-- find libstdc++ in the Nix store. Point it at the packaged server instead;
-- a bare name is resolved through $PATH (programs.lazyvim.extraPackages).
-- `accept` is the one custom bind from the old NvChad config; LazyVim sets it
-- to false so blink.cmp owns <Tab>, so remove it if that clash is annoying.
return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      server = { custom_server_filepath = "copilot-language-server" },
      suggestion = {
        keymap = {
          accept = "<Tab>",
        },
      },
    },
  },
}
