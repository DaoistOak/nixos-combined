require "nvchad.options"

local o = vim.o

o.clipboard = "unnamedplus"

do
  local candidates = vim.fn.glob("/nix/store/*sqlite-*/lib/libsqlite3.so", true, true)
  local path
  local exe = vim.fn.exepath "sqlite3"
  if exe ~= "" then
    path = exe:gsub("bin/sqlite3$", "lib/libsqlite3.so")
  elseif #candidates > 0 then
    path = candidates[#candidates]
  end
  if path and vim.uv.fs_stat(path) then
    vim.g.sqlite_clib_path = path
  end
end