-- harpoon2 + snacks picker: buffer navigation via a popup.
--
-- <leader>B is a leaf: it opens a Snacks floating picker (same style as
-- <leader>n notifications) with fuzzy search over all listed buffers.
-- Press 1-9 inside the picker to jump to that buffer by position.
--
-- Buffer management lives inside the picker too, which is what leaves the
-- prefix with no tail: p pins the highlighted buffer, < and > close the
-- buffers either side of it, U closes everything that is not pinned, and d
-- drops the buffer itself. They are normal-mode keys so the search prompt
-- keeps every character -- <Esc> only reaches normal mode from the input,
-- since that is where snacks binds it, and the list is normal mode already.
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

-- Open a Snacks floating picker with fuzzy search over all buffers, number
-- keys mapped for positional selection, and the buffer management that the
-- <leader>b and <leader>B prefixes used to carry: the BufferLine keys, plus
-- LazyVim's delete.
--
-- Every BufferLine command acts on the *current* buffer, so an action has to
-- point the current buffer at the highlighted item first -- and the picker
-- has to close before that, since it owns the floating window the command
-- would otherwise run in.
local function open_harpoon_picker()
  sync_active_buffers()

  local actions = {}
  local input_keys = {}
  local list_keys = {}

  for i = 1, 9 do
    local action_name = "harpoon_select_" .. i
    input_keys[tostring(i)] = { action_name, mode = { "i", "n" } }
    actions[action_name] = make_harpoon_select(i)
  end

  for _, def in ipairs({
    { "p", "buffer_pin", "BufferLineTogglePin" },
    { "<", "buffer_close_left", "BufferLineCloseLeft" },
    { ">", "buffer_close_right", "BufferLineCloseRight" },
  }) do
    local key, name, cmd = def[1], def[2], def[3]
    actions[name] = function(picker)
      local item = picker:current()
      picker:close()
      if item and item.buf and vim.api.nvim_buf_is_valid(item.buf) then
        vim.api.nvim_set_current_buf(item.buf)
        vim.cmd(cmd)
      end
    end
    input_keys[key] = { name, mode = "n" }
    list_keys[key] = name
  end

  -- Dropping everything unpinned is a decision about the whole bufferline, so
  -- it needs no highlighted item to act on.
  actions.buffer_unpinned = function(picker)
    picker:close()
    vim.cmd("BufferLineGroupClose ungrouped")
  end
  input_keys["U"] = { "buffer_unpinned", mode = "n" }
  list_keys["U"] = "buffer_unpinned"

  -- Delete takes the bufnr straight from the highlighted item, so unlike the
  -- commands above the window never has to visit the buffer first. This is
  -- LazyVim's <leader>bd: Snacks handles the modified-buffer prompt itself.
  actions.buffer_delete = function(picker)
    local item = picker:current()
    picker:close()
    if item and item.buf and vim.api.nvim_buf_is_valid(item.buf) then
      Snacks.bufdelete(item.buf)
    end
  end

  -- Add a brand-new buffer. It is put at the top of the list and the picker
  -- closes with the buffer made current so the user can name and save it
  -- immediately. The buffer source re-reads `nvim_list_bufs()` on the next
  -- open, so the new buffer is picked up in the list too.
  actions.buffer_add = function(picker)
    local buf = vim.api.nvim_create_buf(false, {buflisted = true, swapfile = false})
    local item = {
      buf = buf,
      name = "",
      file = "",
      buftype = "",
      filetype = "",
      flags = "",
      text = "",
      info = { hidden = 0, windows = {} },
    }
    local list = picker.list
    list.topk:clear()
    for i, v in ipairs(list.items) do
      if v == item then
        table.remove(list.items, i)
        break
      end
    end
    table.insert(list.items, 1, item)
    list.target = nil
    list:update()
    list:move(1, true)
    picker:close()
    vim.api.nvim_set_current_buf(buf)
    vim.cmd("startinsert!")
  end

  -- Mark the highlighted buffer to the top of the list. Remove it from the
  -- buffer order and re-insert it at index 1, then re-render so the cursor is
  -- on the top item. Pressing it again while it is already at the top leaves
  -- it there.
  actions.buffer_top = function(picker)
    local item = picker:current()
    if not item or not item.buf then return end
    local list = picker.list
    list.topk:clear()
    for i, v in ipairs(list.items) do
      if v == item then
        table.remove(list.items, i)
        break
      end
    end
    table.insert(list.items, 1, item)
    list.target = nil
    list:update()
    list:move(1, true)
  end

  -- Delete the highlighted buffer with dd. `buffer_delete` resolves to
  -- snacks' own `bufdelete`, so the modified-buffer prompt is handled for us.
  input_keys["d"] = { "buffer_delete", mode = "n" }
  input_keys["dd"] = { "buffer_delete", mode = "n" }
  list_keys["d"] = "buffer_delete"
  list_keys["dd"] = "buffer_delete"

  -- Create a new buffer (a).
  list_keys["a"] = "buffer_add"

  -- Mark the highlighted buffer to the top of the list (space).
  list_keys["<Space>"] = "buffer_top"

  Snacks.picker.buffers({
    title = "Harpoon Buffers",
    win = {
      input = { keys = input_keys },
      list = { keys = list_keys },
    },
    actions = actions,
  })
end

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  -- A leaf by choice: nothing lives under <leader>B any more, so nowait stops
  -- it ever waiting on a longer sequence it cannot complete.
  keys = {
    {
      "<leader>B",
      open_harpoon_picker,
      desc = "Harpoon Buffers (popup)",
      nowait = true,
    },
  },

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
