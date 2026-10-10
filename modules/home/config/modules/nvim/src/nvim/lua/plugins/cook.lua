-- cook.nvim resolves "which command runs this file" and ships it to
-- executor.run(); lua/config/runner.lua covers the three things it cannot,
-- because its runners and recipes are plain strings:
--
--   * compiled output goes to <git root>/build, and {dir} is the file's own
--     directory rather than the project root,
--   * the include and link flags a C/C++ source needs are only knowable at
--     run time, from the #includes in that file,
--   * the nix shell variants, which wrap a command rather than being one.
--
-- cook keeps `:Cook`, `:Cookt` and `:Coop`, the per-project recipes.lua, and
-- the extension -> command table below; its {file}/{name}/{filename}/{ext}
-- placeholders do the substitution.
return {
  {
    "07CalC/cook.nvim",
    config = function()
      require("cook").setup({
        -- cook substitutes {file} verbatim, so the quoting is written into the
        -- template; a project path with a space in it would otherwise split
        -- the command in two.
        runners = {
          py = "python3 '{file}'",
          js = "node '{file}'",
          mjs = "node '{file}'",
          cjs = "node '{file}'",
          sh = "sh '{file}'",
          bash = "sh '{file}'",
          zsh = "zsh '{file}'",
          lua = "lua '{file}'",
          rb = "ruby '{file}'",
          pl = "perl '{file}'",
          -- Markup is a document, not a program: hand it to whatever the
          -- session has registered as its default handler.
          html = "xdg-open '{file}'",
          htm = "xdg-open '{file}'",
        },
      })

      -- cook opens and owns a terminal of its own. This config already has a
      -- long-lived one behind <leader>tf (lua/config/terminals.lua), and a
      -- run belongs in that same buffer: same shell, same scrollback, and
      -- <leader>tf still toggles the window afterwards. executor.run is the
      -- only place cook touches a terminal, so redirecting it is the whole
      -- integration.
      local executor = require("cook.executor")
      local cook_run = executor.run
      executor.run = function(cmd)
        -- A leading ! is cook's own convention for "this is a vim command,
        -- not a shell line"; everything else is a shell line for the float.
        if type(cmd) ~= "string" or cmd == "" or cmd:sub(1, 1) == "!" then
          return cook_run(cmd)
        end
        require("config.terminals").run(cmd)
      end

      -- cook binds <leader><leader>r and <leader><leader>t at require time,
      -- including in terminal mode where <leader>tf is the way out of the
      -- run. They duplicate <leader>rr and <leader>tf, so they go.
      for _, mode in ipairs({ "n", "t" }) do
        pcall(vim.keymap.del, mode, "<leader><leader>r")
        pcall(vim.keymap.del, mode, "<leader><leader>t")
      end
      pcall(vim.keymap.del, "n", "<leader><leader>p")
    end,
  },
}
