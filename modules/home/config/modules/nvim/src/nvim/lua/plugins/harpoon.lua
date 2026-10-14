-- harpoon2 + snacks picker: buffer navigation via a popup.
--
-- <leader>B opens a Snacks floating picker (same style as <leader>n
-- notifications) with fuzzy search over all listed buffers.  Press 1-9
-- inside the picker to jump to that buffer by position.  <leader>B1..9
-- also works globally.
--
-- The harpoon list is kept in sync with all active buffers so the
-- number positions are stable and predictable.

local function sync_active_buffers()
  local harpoon = require("harpoon")
  local list = harpoon:list()
  local existing = {}
  for i = 1, list:length() do
    local item = list:get(i)
    if item then
      existing[item.value] = true
    end
  end

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name ~= "" and not existing[name] then
        list:add({
          value = name,
          context = {
            row = 1,
            col = 0,
          },
        })
      end
    end
  end
end

-- Build a custom action that jumps to the Nth item in the picker list.
local function make_harpoon_select(n)
  return function(picker)
    local items = picker:items()
    if items[n] and items[n].buf then
      picker:close()
      vim.api.nvim_set_current_buf(items[n].buf)
    end
  end
end

-- Open a Snacks floating picker with fuzzy search over all buffers,
-- and number keys mapped for positional selection.
local function open_harpoon_picker()
  sync_active_buffers()

  local input_keys = {}
  local actions = {}
  for i = 1, 9 do
    local action_name = "harpoon_select_" .. i
    input_keys[tostring(i)] = { action_name, mode = { "i", "n" } }
    actions[action_name] = make_harpoon_select(i)
  end

  Snacks.picker.buffers({
    title = "Harpoon Buffers",
    win = {
      input = {
        keys = input_keys,
      },
    },
    actions = actions,
  })
end

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = function()
    local keys = {
      {
        "<leader>B",
        open_harpoon_picker,
        desc = "Harpoon Buffers (popup)",
      },
    }

    -- <leader>B1 .. <leader>B9 select the first nine harpoon entries
    -- globally, outside the picker.
    for i = 1, 9 do
      table.insert(keys, {
        "<leader>B" .. i,
        function()
          sync_active_buffers()
          require("harpoon"):list():select(i)
        end,
        desc = "Harpoon buffer " .. i,
      })
    end

    return keys
  end,

  config = function(_, opts)
    local harpoon = require("harpoon")
    local Extensions = require("harpoon.extensions")
    harpoon.setup(opts)

    -- Map bare 1-9 inside the harpoon UI fallback to select items, in
    -- case the harpoon quick-menu is opened directly.
    harpoon:extend(Extensions.builtins.navigate_with_number())
    harpoon:extend(Extensions.builtins.highlight_current_file())
  end,
}
