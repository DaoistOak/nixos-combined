-- AI-SLOP Detector integration.
--
-- On every BufWritePost this runs the `slop-detector` CLI (installed via the
-- ai-slop-detector Nix package) on the saved file in JSON mode.
--
-- The resulting score is exposed two ways:
--   1. lualine component:  AI-{score}   (updates after :w)
--   2. virtual-text diag:  inline comment on flagged lines, shown after
--      :w + entering insert mode
--
-- Only Python files are scanned (ai-slop-detector's core analysis language).
-- The detection is heuristic and deterministic — no API keys, no network.

local M = {}

M.ns = vim.api.nvim_create_namespace("ai-slop")

--- Convert the raw AI-SLOP deficit score (0-100) to a status string for
--- lualine.
M.status = function()
  local score = vim.g.ai_slop_score
  if score == nil then
    return "AI:-"
  end
  local pct = math.floor(score + 0.5)
  local label = "AI-" .. pct
  if pct >= 70 then
    label = label .. "!"
  elseif pct >= 40 then
    label = label .. "?"
  end
  return label
end

--- Run slop-detector on the saved file and update lualine + virtual text.
M.run = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == "" or not filepath:match("%.py$") then
    return
  end

  -- Write JSON to a temp file so we get proper stdout parsing.
  local tmpfile = vim.fn.tempname() .. ".json"
  local cmd = {
    "slop-detector",
    filepath,
    "--json",
    "--output",
    tmpfile,
  }

  vim.system(cmd, { text = true }, function(result)
    local data
    pcall(function()
      local raw = vim.fn.readfile(tmpfile)
      data = vim.json.decode(table.concat(raw, "\n"))
    end)
    pcall(vim.fn.delete, tmpfile)

    if not data then
      return
    end

    -- deficit_score is the 0–100 headline score
    local score = data.deficit_score or 0
    vim.g.ai_slop_score = score
    vim.b[bufnr].ai_slop_score = score

    -- Clear previous virtual text for this buffer
    pcall(vim.api.nvim_buf_clear_namespace, bufnr, M.ns, 0, -1)

    -- Add virtual text for each flagged line
    local findings = data.pattern_issues or {}
    for _, f in ipairs(findings) do
      local line = (f.line or 1) - 1 -- lua.nvim is 0-indexed
      if line >= 0 then
        local label = string.format("[AI:%s:%s]", f.severity or "?", f.pattern_id or "unknown")
        pcall(vim.api.nvim_buf_set_extmark, bufnr, M.ns, line, 0, {
          virt_text = { { label, "DiagnosticVirtualTextWarn" } },
          virt_text_pos = "eol",
        })
      end
    end

    -- Refresh lualine statusline
    vim.cmd("redrawstatus")
  end)
end

--- Clear virtual text when leaving the buffer.
M.setup_clear = function()
  vim.api.nvim_create_autocmd({ "BufLeave", "BufUnload" }, {
    group = M.augroup,
    callback = function(args)
      pcall(vim.api.nvim_buf_clear_namespace, args.buf, M.ns, 0, -1)
    end,
  })
end

M.setup = function()
  M.augroup = vim.api.nvim_create_augroup("ai_slop_detector", { clear = true })

  -- Run the detector after every buffer write
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = M.augroup,
    pattern = "*.py",
    callback = function(args)
      M.run(args.buf)
    end,
  })

  M.setup_clear()
end

return M
