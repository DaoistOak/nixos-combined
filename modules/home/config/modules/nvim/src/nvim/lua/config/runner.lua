-- The parts of <leader>r that cook.nvim cannot express.
--
-- cook resolves an extension to a command string and its recipes are plain
-- strings, which covers every interpreted language and the browser hand-off
-- for markup (see lua/plugins/cook.lua). What is left here needs to be
-- computed per file at the moment the key is pressed:
--
--   * compiled output goes to <project root>/build -- cook's {dir} is the
--     file's own directory, not the root, so there is no placeholder for it,
--   * the include and link flags a C/C++ source needs come from the #includes
--     in that source, which no fixed string can know,
--   * the nix shell variants wrap whatever command was built rather than
--     being one.
--
-- Commands are handed to cook's executor, which lua/plugins/cook.lua has
-- pointed at the <leader>tf float, so there is exactly one terminal.

local M = {}

---@param s string
---@return string
local function q(s)
  return "'" .. s:gsub("'", [['\'']]) .. "'"
end

---@param msg string
local function warn(msg)
  vim.notify("runner: " .. msg, vim.log.levels.WARN)
end

---@param path string
---@return boolean
local function exists(path)
  return vim.uv.fs_stat(path) ~= nil
end

--- The directory holding the .git that owns the current buffer -- the same
--- root LazyVim uses for its project-wide commands -- falling back to the cwd
--- for files that are not in a repository.
---@return string
function M.root()
  return vim.fs.root(vim.api.nvim_get_current_buf(), { ".git" }) or vim.fn.getcwd()
end

--- Where compiled artefacts go. One directory for the whole project keeps the
--- flake and .gitignore needing to know about a single path.
---@param root string
---@return string
local function build_dir(root)
  return root .. "/build"
end

--- The `#include`s of `file`, split by kind: `<...>` names something the
--- toolchain has to be told where to find, `"..."` is normally a header
--- sitting next to the source.
---@param file string
---@return string[] angled, string[] quoted
local function includes(file)
  local angled, quoted = {}, {}
  local ok, lines = pcall(vim.fn.readfile, file)
  if not ok then
    return angled, quoted
  end
  for _, line in ipairs(lines) do
    local kind, header = line:match("^%s*#%s*include%s*([<\"])([^>\"]+)[>\"]")
    if kind == "<" then
      angled[#angled + 1] = header
    elseif kind == '"' then
      quoted[#quoted + 1] = header
    end
  end
  return angled, quoted
end

--- header -> whether the compiler already resolves it.
---@type table<string, boolean>
local probed = {}

--- Asks the compiler whether it finds `header` on its own.
---
--- This is the cheap question and the one that matters: the compiler carries
--- its own include directories -- its libc headers, the C++ standard library
--- -- which no pkg-config package ever mentions. Asking it first keeps
--- stdio.h and friends off the slow path in find_owner; without that, and on
--- NixOS where there is no /usr/include to short-circuit on, every include of
--- every program would pay for a full scan of the .pc files.
---@param header string
---@param cc string
---@return boolean
local function compiler_resolves(header, cc)
  if probed[header] ~= nil then
    return probed[header]
  end
  local probe = vim.fn.tempname() .. (cc == "gcc" and ".c" or ".cpp")
  vim.fn.writefile({ ("#include <%s>"):format(header) }, probe)
  vim.fn.system({ cc, "-fsyntax-only", probe })
  local resolved = vim.v.shell_error == 0
  vim.fn.delete(probe)
  probed[header] = resolved
  return resolved
end

--- The installed pkg-config package names, asked once: enumerating the .pc
--- files is the expensive part of the lookup.
---@type string[]|nil
local pc_packages

---@return string[]
local function packages()
  if pc_packages == nil then
    pc_packages = {}
    if vim.fn.executable("pkg-config") == 1 then
      local ok, list = pcall(vim.fn.systemlist, { "pkg-config", "--list-all" })
      if ok then
        for _, line in ipairs(list) do
          local pkg = line:match("^(%S+)")
          if pkg then
            pc_packages[#pc_packages + 1] = pkg
          end
        end
      end
    end
  end
  return pc_packages
end

--- header -> pkg-config package that ships it. false means "asked, nobody has it".
---@type table<string, string|false>
local owner = {}

---@param header string
---@return string?
local function find_owner(header)
  if owner[header] ~= nil then
    return owner[header] or nil
  end
  local found
  for _, pkg in ipairs(packages()) do
    local ok, cflags = pcall(vim.fn.systemlist, { "pkg-config", "--cflags", pkg })
    if ok then
      for _, flag in ipairs(cflags) do
        local dir = flag:match("^-I(.+)$")
        if dir and exists(dir .. "/" .. header) then
          found = pkg
          break
        end
      end
    end
    if found then
      break
    end
  end
  owner[header] = found or false
  return found
end

---@param tool string
---@param pkg string
---@return string[]
local function pc_flags(tool, pkg)
  local ok, out = pcall(vim.fn.systemlist, { "pkg-config", tool, pkg })
  if not ok then
    return {}
  end
  return vim.split(out, "%s+", { trimempty = true })
end

--- The include and link flags a C/C++ source needs.
---
--- A header only reaches the compiler if the package shipping it is passed
--- with -I, and the symbols it uses only resolve if the matching -l is passed
--- too; pkg-config already knows both, so the work is to work out which
--- packages this file's #includes refer to. -lm and -lpthread are always
--- linked: neither is in libc on glibc, and most programs want them without
--- having written an include that mentions them.
---@param file string
---@param cc string
---@return string cflags, string libs
local function compile_flags(file, cc)
  local angled, quoted = includes(file)

  local cflags = {}
  -- A quoted include is normally next to the source, so the file's own
  -- directory is the include path that resolves it.
  if #quoted > 0 then
    cflags[#cflags + 1] = "-I" .. vim.fn.fnamemodify(file, ":h")
  end

  local seen, libs = {}, {}
  for _, header in ipairs(angled) do
    if not compiler_resolves(header, cc) then
      local pkg = find_owner(header)
      if pkg and not seen[pkg] then
        seen[pkg] = true
        vim.list_extend(cflags, pc_flags("--cflags", pkg))
        vim.list_extend(libs, pc_flags("--libs", pkg))
      end
    end
  end

  libs[#libs + 1] = "-lm"
  libs[#libs + 1] = "-lpthread"

  return table.concat(cflags, " "), table.concat(libs, " ")
end

--- Compiled languages, keyed by extension. `run` is what executes the product;
--- without one the product is the binary itself.
local compiled = {
  c = { cc = "gcc", flags = "-Wall -Wextra" },
  cpp = { cc = "g++", flags = "-std=c++20 -Wall -Wextra" },
  rs = { cc = "rustc", flags = "--edition 2021" },
  go = { cc = "go", flags = "" },
  java = {
    cc = "javac",
    flags = "",
    -- javac emits one .class per class it finds rather than a binary, so -d
    -- sends them to build/ and the entry point is the capitalised file name,
    -- which holds for the one-public-class-per-file layout javac enforces.
    output_dir = true,
    run = function(ctx)
      return ("java -cp %s %s"):format(q(ctx.build), ctx.stem:sub(1, 1):upper() .. ctx.stem:sub(2))
    end,
  },
  ts = {
    cc = "tsc",
    flags = "--target es2022 --module commonjs",
    output_dir = true,
    run = function(ctx)
      return ("node %s"):format(q(ctx.build .. "/" .. ctx.stem .. ".js"))
    end,
  },
}

for _, alias in ipairs({ "cc", "cxx", "c++", "hpp", "hh" }) do
  compiled[alias] = compiled.cpp
end

--- The pieces of a compiled run, derived from the current buffer.
---@return { file: string, root: string, build: string, stem: string, out: string }?
local function compiled_context()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    warn("no file name for this buffer")
    return nil
  end
  local root = M.root()
  local stem = vim.fn.fnamemodify(file, ":t:r")
  return {
    file = file,
    root = root,
    build = build_dir(root),
    stem = stem,
    out = build_dir(root) .. "/" .. stem,
  }
end

---@vararg string
---@return string
local function join(...)
  local parts = {}
  for _, part in ipairs({ ... }) do
    if part and part ~= "" then
      parts[#parts + 1] = part
    end
  end
  return table.concat(parts, " ")
end

--- The compile line for a compiled file.
---@param ctx table
---@param recipe table
---@return string
local function compile_command(ctx, recipe)
  if recipe.output_dir then
    -- Nothing to put in -o: javac and tsc choose their own output names, so
    -- only the include path for the emitted files is given.
    local flags = recipe.cc == "tsc" and "--outDir " .. q(ctx.build) or "-d " .. q(ctx.build)
    return join(("mkdir -p %s &&"):format(q(ctx.build)), recipe.cc, recipe.flags, flags, q(ctx.file))
  end

  local cflags, libs = "", ""
  if recipe.cc == "gcc" or recipe.cc == "g++" then
    cflags, libs = compile_flags(ctx.file, recipe.cc)
  end

  -- cflags go before the source and libs after it: link order decides which
  -- way a dependency resolves as soon as a library is static, and pkg-config
  -- already emits -l in dependency order, so its output goes last.
  return join(
    ("mkdir -p %s &&"):format(q(ctx.build)),
    recipe.cc,
    recipe.flags,
    cflags,
    ("-o %s"):format(q(ctx.out)),
    q(ctx.file),
    libs
  )
end

---@param root string
---@return boolean
local function has_make_target(root, target)
  local path = root .. "/Makefile"
  if not exists(path) then
    return false
  end
  for line in io.lines(path) do
    if line:match("^" .. target .. "%s*:") then
      return true
    end
  end
  return false
end

---@param root string
---@return table<string, string>
local function npm_scripts(root)
  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(root .. "/package.json"), "\n"))
  if not ok or type(decoded) ~= "table" or type(decoded.scripts) ~= "table" then
    return {}
  end
  return decoded.scripts
end

--- How the project in `root` is started, or nil when nothing says.
---@param root string
---@return string?
local function project_command(root)
  if exists(root .. "/Cargo.toml") then
    return "cargo run --release"
  end
  if exists(root .. "/go.mod") then
    return "go run ."
  end
  if exists(root .. "/package.json") then
    local scripts = npm_scripts(root)
    for _, name in ipairs({ "start", "dev", "main" }) do
      if scripts[name] then
        return ("npm run %s"):format(name)
      end
    end
    if exists(root .. "/index.js") then
      return "node index.js"
    end
  end
  if has_make_target(root, "run") then
    return "make run"
  end
  if exists(root .. "/CMakeLists.txt") then
    -- cmake has no generic run step; configure+build lands the binary in
    -- build/, named after the project directory in the usual case.
    return ("cmake -S . -B build && cmake --build build -j$(nproc) && ./build/%s"):format(
      vim.fn.fnamemodify(root, ":t")
    )
  end
  for _, name in ipairs({ "main.py", "app.py", "__main__.py" }) do
    if exists(root .. "/" .. name) then
      return ("python3 %s"):format(name)
    end
  end
  return nil
end

--- Wraps `cmd` in the project's nix shell, or nil when it has none.
---
--- nix develop -c keeps the wrapper on one line; without it nix develop drops
--- into an interactive shell and the command would have to be typed there.
---@param root string
---@param cmd string
---@return string?
local function in_nix(root, cmd)
  if exists(root .. "/flake.nix") then
    return ("cd %s && nix develop -c %s"):format(q(root), q(cmd))
  end
  if exists(root .. "/shell.nix") then
    return ("cd %s && nix-shell --run %s"):format(q(root), q(cmd))
  end
  return nil
end

--- Hands a shell line to cook, which sends it to the <leader>tf float.
---@param cmd string
local function dispatch(cmd)
  require("cook.executor").run(cmd)
end

--- Compiles the current file and, unless `only`, runs the product.
---@param opts? { nix?: boolean, only?: boolean }
function M.file(opts)
  opts = opts or {}
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return warn("no file name for this buffer")
  end

  local ext = vim.fn.fnamemodify(file, ":e")
  local recipe = compiled[ext]

  local cmd
  if recipe then
    local ctx = compiled_context()
    if not ctx then
      return
    end
    cmd = compile_command(ctx, recipe)
    if not opts.only then
      cmd = cmd .. " && " .. (recipe.run and recipe.run(ctx) or q(ctx.out))
    end
  elseif opts.only then
    -- Not compiled, so there is nothing for <leader>rc to do; cook's runner
    -- table would run it, which is what <leader>rr is for.
    return warn((".%s is interpreted, there is nothing to compile"):format(ext ~= "" and ext or "?"))
  else
    -- Interpreted, or markup: cook already knows the command for this.
    local resolved = require("cook.filetype").resolve(file)
    if not resolved then
      return
    end
    cmd = resolved
  end

  if opts.nix then
    local wrapped = in_nix(M.root(), cmd)
    if not wrapped then
      return warn(("no flake.nix or shell.nix in %s"):format(M.root()))
    end
    cmd = wrapped
  end

  dispatch(cmd)
  if opts.only then
    vim.notify(("runner: compiled to %s"):format(build_dir(M.root())), vim.log.levels.INFO)
  end
end

--- Runs the project the current buffer belongs to.
---@param opts? { nix?: boolean }
function M.project(opts)
  opts = opts or {}
  local root = M.root()
  local cmd = project_command(root)
  if not cmd then
    return warn(("no way to run %s -- a Makefile 'run' target or a flake would say"):format(root))
  end

  if opts.nix then
    local wrapped = in_nix(root, cmd)
    if not wrapped then
      return warn(("no flake.nix or shell.nix in %s"):format(root))
    end
    cmd = wrapped
  else
    cmd = ("cd %s && %s"):format(q(root), cmd)
  end

  dispatch(cmd)
end

--- The problem's URL, taken from a comment near the top of the buffer.
---
--- The template .competitest.lua points competitest at writes that line when a
--- problem is received from the browser, which keeps each solution carrying its
--- own submission target instead of relying on a value that has to be remembered
--- or retyped per problem. Files that predate the template have no such line, so
--- this can still come up empty.
---@param bufnr integer
---@return string?
local function problem_url(bufnr)
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 10, false)) do
    local url = line:match("(https?://%S+)")
    if url then
      return url
    end
  end
  return nil
end

--- Submits the current file to its online judge with online-judge-tools.
---
--- oj keeps only a session cookie (XDG_STATE_HOME/online-judge-tools/cookie.jar)
--- -- no password is written anywhere -- so login is a one-time `oj login <url>`
--- done by hand. HackerRank is the service that implements submit_code; CS
--- Academy's module only downloads samples, so a problem without an oj service
--- will fail here and want a paste into the web editor instead.
---@param opts? { nix?: boolean }
function M.submit(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    return warn("no file name for this buffer")
  end

  local url = problem_url(bufnr)
  if not url then
    url = vim.fn.input("Problem URL: ")
    if url == nil or url == "" then
      return
    end
  end

  -- oj reads the file off disk, so an unsaved buffer would submit the previous
  -- version without saying so.
  if vim.bo[bufnr].modified then
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("write")
    end)
  end

  -- -y skips oj's interactive confirmation; it opens the result page itself.
  local cmd = ("oj submit -y %s %s"):format(q(url), q(file))
  if opts.nix then
    local wrapped = in_nix(M.root(), cmd)
    if not wrapped then
      return warn(("no flake.nix or shell.nix in %s"):format(M.root()))
    end
    cmd = wrapped
  end
  dispatch(cmd)
end

return M
