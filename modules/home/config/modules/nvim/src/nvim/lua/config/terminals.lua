-- Persistent terminals for the <leader>t layer.
--
-- Each layout owns one long-lived buffer. Windows are created and destroyed
-- around it, the shell is not: dismissing the float with <leader>tf and pressing
-- it again resumes the same session -- same cwd, same scrollback, same running
-- job -- instead of starting a fresh shell. LazyVim's own terminal maps spawn a
-- terminal per press, and :terminal cannot be reopened without losing the job,
-- hence the small registry below.
--
-- The shell only restarts when its buffer is gone or the job exited, e.g. after
-- `exit` was typed in it.

local M = {}

---@type table<string, { buf: integer, job: integer, win?: integer }>
local sessions = {}

--- Runs the shell into a fresh terminal buffer without disturbing the layout.
--- `jobstart`'s `term_buf` is a no-op on neovim 0.12 (the buffer never becomes a
--- terminal), and `termopen` always uses the current buffer, so the buffer is
--- parked in a hidden one-line window for the call and the window is dropped
--- again -- the shell keeps running in the buffer that is left behind.
---@param buf integer
---@return integer job
local function start_shell(buf)
  local previous = vim.api.nvim_get_current_win()
  local scratch = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = 1,
    height = 1,
    row = 0,
    col = 0,
    style = "minimal",
    hide = true,
  })
  -- $NVIM has to be the RPC address so tooling run inside the terminal (the
  -- zsh `vi` wrapper, nvr, ...) can reach this instance. Neovim injects that
  -- automatically for :terminal children, but passing `env` clobbers it, so set
  -- it explicitly from the server name.
  local job = vim.fn.termopen(vim.o.shell, {
    cwd = vim.fn.getcwd(),
    env = vim.tbl_extend("force", vim.fn.environ(), { NVIM = vim.v.servername }),
  })
  vim.api.nvim_win_close(scratch, true)
  if vim.api.nvim_win_is_valid(previous) then
    vim.api.nvim_set_current_win(previous)
  end
  return job
end

--- The session for `id`, started on first use and restarted only when needed.
local function session(id)
  local s = sessions[id]
  if s and vim.api.nvim_buf_is_valid(s.buf) and vim.fn.jobwait({ s.job }, 0)[1] == -1 then
    return s
  end

  local buf = vim.api.nvim_create_buf(false, true)
  -- Survive the closing of its window.
  vim.bo[buf].bufhidden = "hide"
  s = { buf = buf, job = start_shell(buf) }
  sessions[id] = s
  return s
end

---@param buf integer
---@return integer? win
local function window_with(buf)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      return win
    end
  end
end

--- Shows `id` in a split made by `cmd`, or focuses it when it is already visible.
local function split(id, cmd)
  local s = session(id)
  local win = window_with(s.buf)
  if win then
    vim.api.nvim_set_current_win(win)
    return
  end

  vim.cmd(cmd)
  vim.api.nvim_win_set_buf(0, s.buf)
  vim.cmd("startinsert")
end

--- Toggles `id` in a float, leaving the shell running while it is hidden.
local function float(id)
  local s = session(id)
  if s.win and vim.api.nvim_win_is_valid(s.win) then
    vim.api.nvim_win_close(s.win, true)
    s.win = nil
    return
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  s.win = vim.api.nvim_open_win(s.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - vim.o.cmdheight),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Terminal ",
    title_pos = "center",
  })
  vim.cmd("startinsert")
end

--- Terminal in a horizontal split, focused if it is already open.
function M.horizontal()
  split("horizontal", "split")
end

--- Terminal in a vertical split, focused if it is already open.
function M.vertical()
  split("vertical", "vsplit")
end

--- Floating terminal, toggled by the same key that opened it.
function M.float()
  float("float")
end

return M
