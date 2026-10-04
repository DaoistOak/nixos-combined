-- Custom binds. Copilot Chat maps live here (not in the plugin spec) because
-- lazy.nvim merges `keys` of two specs for the same plugin positionally, and
-- the ai.copilot-chat extra would overwrite the tail of that list.
-- Visual Copilot maps use `:` so the `'<,'>` range is kept; `<cmd>` drops it.
vim.keymap.set("n", "qq", ":q!<CR>", { desc = "Force Quit Neovim" })

for i = 1, 10 do
	vim.keymap.set("n", ("<leader>b%d"):format(i == 10 and 0 or i), ("<cmd>BufferLineGoToIndex %d<cr>"):format(i), {
		desc = ("Buffer %d"):format(i),
	})
end

vim.keymap.set("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New buffer" })
vim.keymap.set("n", "<leader>cc", "<cmd>CopilotChat<cr>", { desc = "CopilotChat" })
vim.keymap.set("n", "<leader>co", "<cmd>CopilotChatOpen<cr>", { desc = "CopilotChatOpen" })
vim.keymap.set("n", "<leader>cq", "<cmd>CopilotChatClose<cr>", { desc = "CopilotChatClose" })

vim.keymap.set("x", "<leader>ce", ":CopilotChat Explain<CR>", { desc = "CopilotChat Explain" })
vim.keymap.set("x", "<leader>cf", ":CopilotChat Fix<CR>", { desc = "CopilotChat Fix" })
vim.keymap.set("x", "<leader>cr", ":CopilotChat Refactor<CR>", { desc = "CopilotChat Refactor" })
vim.keymap.set("x", "<leader>ct", ":CopilotChat Tests<CR>", { desc = "CopilotChat Tests" })
