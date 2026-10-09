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

        sections.lualine_x = {}
        sections.lualine_y = x
        sections.lualine_z = y_old

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
