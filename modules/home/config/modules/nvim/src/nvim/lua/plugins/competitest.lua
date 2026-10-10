-- competItest.nvim: manages testcases, and pulls problems straight out of the
-- browser through Competitive Companion.
--
-- Two things about it are not obvious from the README and shape this config:
--
-- 1. Commands are keyed by *filetype* (runner.lua reads vim.bo.filetype), not
--    by file extension, and they are spawned with luv.spawn as an argv list --
--    there is no shell. Anything needing a shell has to ask for one explicitly
--    with `sh -c`.
--
-- 2. exec/args go through competItest's own modifier parser first, and that
--    parser rejects the string outright if it finds a `$` that is not followed
--    by `(` -- see utils.format_string_modifiers, which bails out with
--    "isn't followed by '('" and makes the whole command nil. So neither
--    $(git rev-parse ...) nor a plain $VAR can be used in a command here;
--    POSIX backticks are what does command substitution instead.
--
-- Because of that the compile/run pair below is spelled out per language
-- rather than sharing config.runner's flag resolution, which needs a Lua
-- function that this schema has no room for. Keep the two in sync by hand.
--
-- A project can override anything in this table by dropping a .competitest.lua
-- next to its sources; competItest walks up from the buffer looking for one.
return {
  {
    "xeluxee/competitest.nvim",
    -- Declaring `keys` below makes lazy.nvim infer lazy = true, which would
    -- leave the Competitive Companion listener down until the first
    -- <leader>rt press -- too late, since the browser is what triggers it.
    -- This overrides the inference and matches defaults.lazy = false.
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = function(_, opts)
      opts = opts or {}
      -- Backtick form of `git rev-parse --show-toplevel`, so compiled output
      -- lands in the same <project root>/build that <leader>rr uses. The
      -- fallback keeps it working in a directory that is not a repository,
      -- where git would otherwise print nothing and the path would become
      -- "/build/<name>".
      local root = "`git rev-parse --show-toplevel 2>/dev/null || pwd`"

      opts.compile_command = {
        cpp = {
          exec = "sh",
          args = {
            "-c",
            ("mkdir -p %s/build && g++ -std=c++20 -Wall -Wextra $(FNAME) -o %s/build/$(FNOEXT) -lm"):format(
              root,
              root
            ),
          },
        },
        c = {
          exec = "sh",
          args = {
            "-c",
            ("mkdir -p %s/build && gcc -Wall -Wextra $(FNAME) -o %s/build/$(FNOEXT) -lm -lpthread"):format(
              root,
              root
            ),
          },
        },
        rust = {
          exec = "sh",
          args = {
            "-c",
            ("mkdir -p %s/build && rustc --edition 2021 $(FNAME) -o %s/build/$(FNOEXT)"):format(root, root),
          },
        },
      }

      opts.run_command = {
        cpp = { exec = "sh", args = { "-c", root .. "/build/$(FNOEXT)" } },
        c = { exec = "sh", args = { "-c", root .. "/build/$(FNOEXT)" } },
        rust = { exec = "sh", args = { "-c", root .. "/build/$(FNOEXT)" } },
        -- The plugin's own default is `python`, which does not exist on
        -- NixOS; python3 does.
        python = { exec = "python3", args = { "$(FNAME)" } },
      }
      -- No compile_command for python: an interpreted language has nothing to
      -- build, and the plugin skips the compile step when one is absent. The
      -- stock default "compiles" it with py_compile, which only writes a
      -- __pycache__ and never affects the result.

      -- competitest's default of 27121 needs no change: Competitive Companion
      -- broadcasts to a fixed list of ports and 27121 is on it, so the stock
      -- browser extension is received without configuring anything.
      opts.companion_port = opts.companion_port or 27121
      opts.receive_print_message = true

      return opts
    end,
    keys = {
      {
        "<leader>rt",
        function()
          vim.cmd("CompetiTest")
        end,
        desc = "CompetiTest Menu",
      },
    },
  },
}
