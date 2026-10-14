return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        theme = require("theme").lualine_theme() or "auto",
        component_separators = "",
        section_separators = {
          left = vim.fn.nr2char(0xE0B4),
          right = vim.fn.nr2char(0xE0B6),
        },
        icons_enabled = true,
        globalstatus = true,
      })

      if opts.sections then
        local sections = opts.sections
        local x = sections.lualine_x or {}
        local y_old = sections.lualine_y or {}

        -- Sections rearranged left-to-right: mode | diagnostics | search | sep
        -- x gets the AI score; original x content goes to y, original y to z.
        sections.lualine_a = {
          {
            "mode",
            separator = {
              left = vim.fn.nr2char(0xE0B6),
              right = vim.fn.nr2char(0xE0B4),
            },
            padding = { left = 0, right = 0 },
          },
        }

        sections.lualine_x = {
          {
            function()
              local ai = require("config.ai-slop")
              return ai.status()
            end,
            color = function()
              local score = vim.g.ai_slop_score or 0
              if score >= 70 then
                return { fg = "#ff6b6b", bg = "#1e1e2e" }
              elseif score >= 40 then
                return { fg = "#f9e2af", bg = "#1e1e2e" }
              else
                return { fg = "#a6e3a1", bg = "#1e1e2e" }
              end
            end,
            padding = { left = 1, right = 0 },
          },
        }
        sections.lualine_y = x
        sections.lualine_z = y_old

        -- Clear function-based z entries from LazyVim's defaults
        if sections.lualine_z then
          local z = sections.lualine_z
          for i = #z, 1, -1 do
            if type(z[i]) == "function" then
              table.remove(z, i)
            end
          end
        end

        table.insert(sections.lualine_z, {
          function()
            return vim.fn.nr2char(0xE0B4)
          end,
          color = function()
            local p = require("theme.palette").load()
            return { fg = p.surface2, bg = p.base }
          end,
          padding = { left = 0, right = 0 },
          separator = "",
        })
      end
      return opts
    end,
  },
}
