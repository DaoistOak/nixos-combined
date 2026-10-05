-- Custom binds. Copilot Chat maps live here (not in the plugin spec) because
-- lazy.nvim merges `keys` of two specs for the same plugin positionally, and
-- the ai.copilot-chat extra would overwrite the tail of that list.
-- Visual Copilot maps use `:` so the `'<,'>` range is kept; `<cmd>` drops it.
vim.keymap.set("n", "qq", ":q!<CR>", { desc = "Force Quit Neovim" })

local wk = require("which-key")

--- Rewrites a keymap lhs back into <leader> form so it can be compared and passed
--- to vim.keymap.* , which is how nvim_get_keymap spells it.
---@param lhs string
---@return string
local function to_spec(lhs)
	return (lhs:gsub("^" .. vim.pesc(vim.g.mapleader or "\\"), "<leader>"))
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
			wk.add({ { entry.lhs, group = desc:sub(2) } })
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
end

-- <leader>b splits below, so the buffer keys move to <leader>B: the ones set
-- below plus the ones lazy.nvim's specs add (pick, pin, delete left/right).
move_prefix("<leader>b", "<leader>B")
wk.add({ { "<leader>B", group = "buffers" } })

for i = 1, 10 do
	vim.keymap.set("n", ("<leader>B%d"):format(i == 10 and 0 or i), ("<cmd>BufferLineGoToIndex %d<cr>"):format(i), {
		desc = ("Buffer %d"):format(i),
	})
end

vim.keymap.set("n", "<leader>Bn", "<cmd>enew<cr>", { desc = "New buffer" })

-- LazyVim's default split keys give way to these two.
for _, lhs in ipairs({ "<leader>|", "<leader>-" }) do
	pcall(vim.keymap.del, "n", lhs)
end

vim.keymap.set("n", "<leader>v", "<cmd>vsplit<cr>", { desc = "Split Right" })
vim.keymap.set("n", "<leader>b", "<cmd>split<cr>", { desc = "Split Below" })

-- <leader>t becomes the terminal layer, so the test group moves to <leader>T.
move_prefix("<leader>t", "<leader>T")
wk.add({ { "<leader>T", group = "test" } })

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

wk.add({ { "<leader>t", group = "terminal" } })
vim.keymap.set("n", "<leader>cc", "<cmd>CopilotChat<cr>", { desc = "CopilotChat" })
vim.keymap.set("n", "<leader>co", "<cmd>CopilotChatOpen<cr>", { desc = "CopilotChatOpen" })
vim.keymap.set("n", "<leader>cq", "<cmd>CopilotChatClose<cr>", { desc = "CopilotChatClose" })

vim.keymap.set("x", "<leader>ce", ":CopilotChat Explain<CR>", { desc = "CopilotChat Explain" })
vim.keymap.set("x", "<leader>cf", ":CopilotChat Fix<CR>", { desc = "CopilotChat Fix" })
vim.keymap.set("x", "<leader>cr", ":CopilotChat Refactor<CR>", { desc = "CopilotChat Refactor" })
vim.keymap.set("x", "<leader>ct", ":CopilotChat Tests<CR>", { desc = "CopilotChat Tests" })
