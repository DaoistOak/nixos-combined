-- AI code detector integration (ai-slop-detector + synthscan).
--
-- On every BufWritePost this runs a CLI detector on the saved file in JSON
-- mode:
--
--   1. lualine component:  AI-{score}   (updates after :w)
--   2. virtual-text diag:  inline comment on flagged lines, shown after
--      :w + entering insert mode
--
-- Language dispatch:
--   .py  → slop-detector  (full AST analysis via ai-slop-detector)
--   .cpp/.cc/.h/.hpp/.cxx/.c → synthscan (pattern-based, works on any file type)
--
-- Detection is heuristic and deterministic — no API keys, no network.

local M = {}

M.ns = vim.api.nvim_create_namespace("ai-slop")

local CPP_EXTENSIONS = { "cpp", "cc", "h", "hpp", "cxx", "c" }

--- Check if a file extension is a C/C++ extension.
local function is_cpp(path)
  local ext = path:match("^.+%.([^/]+)$")
  if not ext then
    return false
  end
  ext = ext:lower()
  for _, e in ipairs(CPP_EXTENSIONS) do
    if ext == e then
      return true
    end
  end
  return false
end

--- Convert a raw score (0-100) to a status string for lualine.
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

--- Run slop-detector on a Python file.
M.run_python = function(bufnr, filepath)
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

    local score = data.deficit_score or 0
    vim.g.ai_slop_score = score

    pcall(vim.api.nvim_buf_clear_namespace, bufnr, M.ns, 0, -1)

    local findings = data.pattern_issues or {}
    for _, f in ipairs(findings) do
      local line = (f.line or 1) - 1
      if line >= 0 then
        local label = string.format("[AI:%s:%s]", f.severity or "?", f.pattern_id or "unknown")
        pcall(vim.api.nvim_buf_set_extmark, bufnr, M.ns, line, 0, {
          virt_text = { { label, "DiagnosticVirtualTextWarn" } },
          virt_text_pos = "eol",
        })
      end
    end

    vim.cmd("redrawstatus")
  end)
end

--- Run synthscan on a C/C++ file. SynthScan scans directories, so we copy
--- the file into a temp dir and scan just that.
M.run_cpp = function(bufnr, filepath)
  -- Create a temp directory and copy the file into it.
  local tmpdir = vim.fn.tempname()
  local tmpfile = tmpdir .. "/" .. vim.fn.fnamemodify(filepath, ":t")
  -- Name the report "synthscan-report.json" so SynthScan skips it in its
  -- own SKIP_FILES set (it would otherwise scan the report file too).
  local report = tmpdir .. "/synthscan-report.json"

  -- Ensure the temp directory exists
  vim.fn.mkdir(tmpdir, "p")

  -- Copy the file contents to the temp directory.
  local ok, lines = pcall(vim.fn.readfile, filepath)
  if not ok then
    pcall(vim.fn.delete, tmpdir, "rf")
    return
  end
  pcall(vim.fn.writefile, lines, tmpfile)

  local cmd = {
    "synthscan",
    "--scan-path",
    tmpdir,
    "--format",
    "json",
    "--report-path",
    report,
  }

  vim.system(cmd, { text = true }, function(result)
    local data
    pcall(function()
      local raw = vim.fn.readfile(report)
      data = vim.json.decode(table.concat(raw, "\n"))
    end)
    pcall(vim.fn.delete, tmpdir, "rf")

    if not data then
      return
    end

    -- SynthScan reports synthetic_code_score (per 1k LOC), raw_score,
    -- match_count, and lines_scanned. Convert to a 0-100 percentage by
    -- normalizing the raw_score against lines_scanned, then scaling so
    -- a match density of ~0.5 matches per line maps to ~100.
    local raw_score = data.raw_score or 0
    local lines = data.lines_scanned or 1
    local score = math.min(100, (raw_score / math.max(1, lines - 1)) * 50)
    vim.g.ai_slop_score = score

    pcall(vim.api.nvim_buf_clear_namespace, bufnr, M.ns, 0, -1)

    -- Add virtual text for each flagged line belonging to this file
    local fname = vim.fn.fnamemodify(filepath, ":t")
    local matches = data.matches or {}
    for _, m in ipairs(matches) do
      if m.file == fname then
        local line = (m.line or 1) - 1
        if line >= 0 then
          local label = string.format("[AI:%s:%s]", m.severity or "?", m.pattern or "unknown")
          pcall(vim.api.nvim_buf_set_extmark, bufnr, M.ns, line, 0, {
            virt_text = { { label, "DiagnosticVirtualTextWarn" } },
            virt_text_pos = "eol",
          })
        end
      end
    end

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

  -- Run the detector after every buffer write, dispatching by file type.
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = M.augroup,
    callback = function(args)
      local filepath = vim.api.nvim_buf_get_name(args.buf)
      if filepath == "" then
        return
      end
      if filepath:match("%.py$") then
        M.run_python(args.buf, filepath)
      elseif is_cpp(filepath) then
        M.run_cpp(args.buf, filepath)
      end
    end,
  })

  M.setup_clear()
end

return M
