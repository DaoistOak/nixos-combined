-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Soft wrap. LazyVim sets wrap=false; this file loads after those defaults.
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.breakindentopt = "sbr,min:20"
vim.opt.showbreak = " 󰌑 "
-- Put the showbreak marker in the number column (`:h cpo-n`).
vim.opt.cpo:append("n")

-- nvim-neoclip's sqlite backend dlopens libsqlite3 through sqlite.lua, which on
-- NixOS is nowhere in the paths it probes (only /usr/lib and friends), so the
-- store path has to be handed to it explicitly via vim.g.sqlite_clib_path.
--
-- This runs at load time, before lazy.nvim and therefore before sqlite.lua is
-- required: sqlite.lua reads the variable once, when lua/sqlite/defs.lua is first
-- loaded, and a later assignment is ignored. Ship the lib in the user profile
-- with `nix profile install nixpkgs#sqlite`; LIBSQLITE in the environment wins
-- over the search.
local function find_sqlite_clib()
  local from_env = vim.env.LIBSQLITE
  if from_env and from_env ~= "" and vim.uv.fs_stat(from_env) then
    return from_env
  end

  local dirs = {
    vim.fn.expand("~/.nix-profile/lib"),
    "/run/current-system/sw/lib",
    "/nix/var/nix/profiles/default/lib",
  }
  for entry in vim.gsplit(vim.env.LD_LIBRARY_PATH or "", ":", { trimempty = true }) do
    dirs[#dirs + 1] = entry
  end
  dirs[#dirs + 1] = "/usr/lib"

  for _, dir in ipairs(dirs) do
    for _, name in ipairs({ "libsqlite3.so", "libsqlite3.so.0" }) do
      local path = dir .. "/" .. name
      if vim.uv.fs_stat(path) then
        return path
      end
    end
  end
end

local sqlite_clib = find_sqlite_clib()
if sqlite_clib then
  vim.g.sqlite_clib_path = sqlite_clib
end
