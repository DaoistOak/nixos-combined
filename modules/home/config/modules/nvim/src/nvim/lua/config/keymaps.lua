-- Custom binds. Copilot Chat maps live here (not in the plugin spec) because
-- lazy.nvim merges `keys` of two specs for the same plugin positionally, and
-- the ai.copilot-chat extra would overwrite the tail of that list.
-- Visual Copilot maps use `:` so the `'<,'>` range is kept; `<cmd>` drops it.
vim.keymap.set("n", "qq", ":q!<CR>", { desc = "Force Quit Neovim" })

local wk = require("which-key")

--- which-key resolves a node's label from its spec before the live keymap:
--- buf.lua feeds nvim_get_keymap() into the tree first and then appends
--- Config.mappings, and node.lua falls back mapping -> keymap when a field is
--- missing, so a spec entry always wins over the keymap it labels.
---
--- Two things follow from that. Moving a prefix leaves the old label behind --
--- LazyVim's own spec still describes <leader>b as the buffer group after
--- move_prefix has put every buffer key on <leader>B. And a wk.add() made
--- during startup cannot fix it: which-key drains wk._queue and only then adds
--- M.options.spec (config.lua, end of load()), so anything queued from
--- keymaps.lua is overwritten by LazyVim's spec a moment later.
---
--- So the labels are collected in `relabel` while the keys move and re-added
--- once which-key has finished that first pass. Later spec entries overwrite
--- earlier ones in the tree (tree.lua assigns node.mapping unconditionally),
--- which is what makes the second add win.
---@type table<string, { group?: string, live?: boolean, icon?: table }>
local relabel = {}

--- Registers a which-key group, and remembers it so the label survives the
--- spec pass described above.
---
--- The icon is given explicitly rather than left to which-key's rules: those
--- are patterns matched against the description ("buffer", "terminal", "test",
--- ...), and a description invented here matches none of them, which is why
--- <leader>rr and <leader>rn came up blank while <leader>B did not.
---@param lhs string
---@param label string
---@param icon? { icon: string, color: string }
local function wk_group(lhs, label, icon)
  local entry = { lhs, group = label, icon = icon }
  wk.add({ entry })
  relabel[lhs] = { group = label, icon = icon }
end

--- Rewrites a keymap lhs back into <leader> form so it can be compared and passed
--- to vim.keymap.* , which is how nvim_get_keymap spells it.
---@param lhs string
---@return string
local function to_spec(lhs)
  return (lhs:gsub("^" .. vim.pesc(vim.g.mapleader or "\\"), "<leader>"))
end

--- The description a live keymap carries, if any.
---@param lhs string
---@return string?
local function live_desc(lhs)
  local ok, maps = pcall(vim.api.nvim_get_keymap, "n")
  if not ok then
    return nil
  end
  for _, map in ipairs(maps) do
    if to_spec(map.lhs) == lhs and map.desc and not map.desc:match("^%+") then
      return map.desc
    end
  end
  return nil
end

--- Moves every mapping under `from` onto `to`, keeping its rhs, callback, options
--- and description. Plugin keys live in lazy.nvim specs rather than in this file,
--- so they are read back with nvim_get_keymap (which already ran, the specs are
--- registered by `require("lazy").setup`) and re-created on the new prefix.
--- which-key group labels carry no rhs and describe themselves as "+name", so
--- they are declared as groups again instead of as mappings.
---@param from string
---@param to string
local function move_prefix(from, to)
  local moved = {}
  for _, mode in ipairs({ "n", "x" }) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      local lhs = to_spec(map.lhs)
      if lhs == from or lhs:sub(1, #from) == from then
        moved[#moved + 1] = { mode = mode, lhs = to .. lhs:sub(#from + 1), map = map }
      end
    end
  end

  -- Delete first so the new keys do not have to fight the old ones.
  for _, entry in ipairs(moved) do
    pcall(vim.keymap.del, entry.mode, to_spec(entry.map.lhs))
  end

  for _, entry in ipairs(moved) do
    local map = entry.map
    local desc = map.desc or ""
    if map.rhs == "" and desc:sub(1, 1) == "+" then
      wk_group(entry.lhs, desc:sub(2))
    else
      vim.keymap.set(entry.mode, entry.lhs, map.callback or map.rhs, {
        desc = desc ~= "" and desc or nil,
        expr = map.expr == 1 or nil,
        remap = map.noremap == 0 or nil,
        silent = map.silent == 1 or nil,
        nowait = map.nowait == 1 or nil,
      })
    end
  end

  -- `from` keeps whatever LazyVim's spec says about it until something
  -- overrides that, so record that it has to be re-read: the description of
  -- the keymap this file puts there is only decided further down. Any group
  -- that lived on `from` went away with its keys, so there is nothing to name
  -- -- the replacement mapping's own description is the whole story.
  relabel[from] = { live = true }
end

-- <leader>b is only the split and <leader>B is only the picker, so everything
-- either prefix used to carry is deleted rather than moved: moved onto
-- <leader>B it would give the leaf a tail to wait out, and left on <leader>b
-- it would do the same to the split while keeping which-key calling it a
-- group. Deleting is also what lazy checks before re-creating a mapping, so a
-- plugin reload cannot bring these back.
--
-- The BufferLine five become picker actions in lua/plugins/harpoon.lua
-- instead. So do LazyVim's own buffer defaults: the picker replaces the
-- switch, delete becomes a picker action, and buffer-only / info /
-- delete-and-window lose their home rather than delay the split.
--
-- The BufferLineGoToIndex number keys that used to live here are gone for the
-- same reason: harpoon's list replaces the bufferline index navigation.
for _, mode in ipairs({ "n", "x" }) do
  for _, lhs in ipairs({
    -- bufferline: pin / delete-unpinned / close right / close left / pick
    "<leader>bp",
    "<leader>bP",
    "<leader>br",
    "<leader>bl",
    "<leader>bj",
    -- LazyVim's buffer defaults: switch / delete / only / info / delete+win
    "<leader>bb",
    "<leader>bd",
    "<leader>bo",
    "<leader>bi",
    "<leader>bD",
  }) do
    pcall(vim.keymap.del, mode, lhs)
  end
end

-- LazyVim's default split keys give way to these two.
for _, lhs in ipairs({ "<leader>|", "<leader>-" }) do
  pcall(vim.keymap.del, "n", lhs)
end

vim.keymap.set("n", "<leader>v", "<cmd>vsplit<cr>", { desc = "Split Right" })
vim.keymap.set("n", "<leader>b", "<cmd>split<cr>", { desc = "Split Below" })

-- LazyVim still labels <leader>b as the buffer group with expand.buf(),
-- which now describes nothing underneath it; re-stating it as a plain mapping
-- swaps that group for the split's own description (see the relabel note at
-- the top of this file).
relabel["<leader>b"] = { live = true }

-- Two LazyVim mappings that only exist to change what the theme-switcher owns.
--
-- <leader>uC is Snacks' colorscheme picker, <leader>ub the Dark Background
-- toggle, which flips 'background' the way LazyVim flips between a light and a
-- dark colorscheme. The palette decides both now: theme/palette reads the
-- luminance of the palette base and sets 'background' from it. Both are removed
-- rather than repointed, in every mode they could have been set in -- the first
-- one is a lazy.nvim-managed keymap, and deleting the mapping is what lazy
-- checks before it re-creates one, so a plugin reload cannot bring it back.
for _, mode in ipairs({ "n", "v", "x", "s", "o", "i", "c", "t" }) do
  for _, lhs in ipairs({ "<leader>uC", "<leader>ub" }) do
    pcall(vim.keymap.del, mode, lhs)
  end
end

-- <leader>t becomes the terminal layer, so the test group moves to <leader>T.
move_prefix("<leader>t", "<leader>T")
wk_group("<leader>T", "test")

local terminals = require("config.terminals")

vim.keymap.set("n", "<leader>t", function()
  terminals.horizontal()
end, { desc = "Terminal" })
vim.keymap.set("n", "<leader>tb", function()
  terminals.horizontal()
end, { desc = "Terminal (Below)" })
vim.keymap.set("n", "<leader>tv", function()
  terminals.vertical()
end, { desc = "Terminal (Right)" })
vim.keymap.set("n", "<leader>tf", function()
  terminals.float()
end, { desc = "Terminal (Float)" })

wk_group("<leader>t", "terminal")

-- <leader>r compiles and runs, in the float terminal above.
local runner = require("config.runner")

wk_group("<leader>r", "run/compile", { icon = "  ", color = "green" })

vim.keymap.set("n", "<leader>rr", function()
  runner.file()
end, { desc = "Run File" })
vim.keymap.set("n", "<leader>rp", function()
  runner.project()
end, { desc = "Run Project" })
vim.keymap.set("n", "<leader>rc", function()
  runner.file({ only = true })
end, { desc = "Compile File" })
vim.keymap.set("n", "<leader>rz", function()
  runner.submit()
end, { desc = "Submit to Judge" })
vim.keymap.set("n", "<leader>rzN", function()
  runner.submit({ nix = true })
end, { desc = "Submit to Judge (nix)" })

wk_group("<leader>rn", "nix shell", { icon = " ", color = "azure" })

vim.keymap.set("n", "<leader>rnr", function()
  runner.file({ nix = true })
end, { desc = "Run File (nix)" })
vim.keymap.set("n", "<leader>rnp", function()
  runner.project({ nix = true })
end, { desc = "Run Project (nix)" })

-- competItest lives under the run layer rather than <leader>T because that
-- already holds LazyVim's neotest keys. The plugin's own <leader>rt mapping
-- lives in lua/plugins/competitest.lua and opens the same :CompetiTest menu.
wk_group("<leader>rt", "competitest", { icon = " ", color = "orange" })

-- competItest's commands act on whatever buffer is current, and every UI it
-- owns -- the runner, the path prompt, the testcase editor -- presents a
-- filetype it has no run command for. The same is true of the pickers and
-- terminals that can hold the window. Rather than deny-list the ones seen so
-- far, ask the same question runner.lua:new does: does this filetype have a
-- run command at all?
--
-- Cheap version of that question for the BufEnter below: read the global setup
-- table instead of the per-buffer one, because the per-buffer lookup walks up
-- the tree looking for a .competitest.lua and this runs on every buffer entry.
-- A project that adds a filetype to its own .competitest.lua is tracked as
-- non-runnable here, and the guard below then falls through to the warning.
local function runnable(bufnr)
  return require("competitest.config").current_setup.run_command[vim.bo[bufnr].filetype] ~= nil
end

--- The most recent buffer competItest could actually run. Pressing <leader>rtx
--- from inside a picker means "run the solution I was working on", not "run
--- the picker", so the last one is the sensible target.
local last_solution

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("competitest_last_solution", { clear = true }),
  callback = function(args)
    if runnable(args.buf) then
      last_solution = args.buf
    end
  end,
})

local function competitest(subcommand, needs_solution)
  return function()
    if needs_solution then
      -- A picker or the competItest runner is floating; step out of it before
      -- anything else, or the buffer switch below would land inside it.
      if vim.api.nvim_win_get_config(0).relative ~= "" then
        vim.cmd("close")
      end
      if not runnable(0) then
        if not (last_solution and vim.api.nvim_buf_is_valid(last_solution)) then
          vim.notify("competitest: no runnable buffer found -- open a solution first", vim.log.levels.WARN)
          return
        end
        vim.api.nvim_set_current_buf(last_solution)
      end
    end
    vim.cmd("CompetiTest " .. subcommand)
  end
end

for _, entry in ipairs({
  { "<leader>rtx", "run", "Run Tests", true },
  { "<leader>rtk", "run_no_compile", "Run Tests (No Compile)", true },
  { "<leader>rtr", "receive testcases", "Receive Testcases", true },
  { "<leader>rta", "add_testcase", "Add Testcase", true },
  { "<leader>rte", "edit_testcase", "Edit Testcase", true },
  { "<leader>rtp", "receive problem", "Receive Problem", false },
  { "<leader>rtc", "receive contest", "Receive Contest", false },
  { "<leader>rtP", "receive persistently", "Receive Persistently", false },
  { "<leader>rtS", "receive stop", "Receive Stop", false },
  { "<leader>rtQ", "receive status", "Receive Status", false },
  { "<leader>rts", "show_ui", "Show Test UI", false },
}) do
  vim.keymap.set("n", entry[1], competitest(entry[2], entry[4]), { desc = entry[3] })
end

vim.keymap.set("n", "<leader>cc", "<cmd>CopilotChat<cr>", { desc = "CopilotChat" })
vim.keymap.set("n", "<leader>co", "<cmd>CopilotChatOpen<cr>", { desc = "CopilotChatOpen" })
vim.keymap.set("n", "<leader>cq", "<cmd>CopilotChatClose<cr>", { desc = "CopilotChatClose" })

vim.keymap.set("x", "<leader>ce", ":CopilotChat Explain<CR>", { desc = "CopilotChat Explain" })
vim.keymap.set("x", "<leader>cf", ":CopilotChat Fix<CR>", { desc = "CopilotChat Fix" })
vim.keymap.set("x", "<leader>cr", ":CopilotChat Refactor<CR>", { desc = "CopilotChat Refactor" })
vim.keymap.set("x", "<leader>ct", ":CopilotChat Tests<CR>", { desc = "CopilotChat Tests" })

-- Re-state the labels collected above, once which-key is past its startup
-- pass, or LazyVim's spec overwrites them again.
--
-- This file is loaded from LazyVim's own User VeryLazy handler, which runs
-- after lazy.nvim has loaded the VeryLazy plugins, so which-key has already
-- been set up by now: setup() sees vim_did_enter and defers its first
-- registration to vim.schedule. That call was queued before this file was
-- even read, so a schedule() from here lands behind it.
--
-- An autocmd would be the wrong tool: one registered while User VeryLazy is
-- being dispatched does not run for that same event. The wait is for
-- which-key to report itself loaded rather than for a fixed tick, because the
-- two schedules are only ordered if which-key was set up first.
local pending, tries = 0, 0

local function relabel_spec()
  if not require("which-key.config").loaded then
    tries = tries + 1
    if tries < 50 then
      vim.schedule(relabel_spec)
      return
    end
    return
  end
  pending = pending + 1
  if pending > 1 then
    return
  end

  local spec = {}
  for lhs, entry in pairs(relabel) do
    spec[#spec + 1] = entry.group and { lhs, group = entry.group, icon = entry.icon }
      or { lhs, desc = live_desc(lhs) or ("unmapped " .. lhs) }
  end
  wk.add(spec)
end

vim.schedule(relabel_spec)
