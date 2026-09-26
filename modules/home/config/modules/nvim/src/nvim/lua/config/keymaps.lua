-- Custom binds only: the Copilot Chat set from the old NvChad config
-- (lua/plugins/init.lua) plus qq. NvChad's ";" and "jk" are deliberately not
-- carried over; flash.nvim owns ";" as its remap key.
-- The Copilot Chat maps live here rather than in lua/plugins/copilot-chat.lua
-- because lazy.nvim merges the `keys` of two specs for the same plugin
-- positionally, so the ai.copilot-chat extra's longer list overwrites the tail
-- of the spec's own. Loaded from here (after every plugin spec set its keys)
-- they merge by lhs instead.
-- <leader>cf is deliberately visual-mode only: LazyVim v16 formats with it in
-- normal mode, and the old visual mapping was CopilotChat Fix.
vim.keymap.set("n", "qq", ":q!<CR>", { desc = "Force Quit Neovim" })

local normal = {
  "<leader>cc CopilotChat",
  "<leader>co CopilotChatOpen",
  "<leader>cq CopilotChatClose",
}

local visual = {
  "<leader>ce CopilotChat Explain",
  "<leader>cf CopilotChat Fix",
  "<leader>cr CopilotChat Refactor",
  "<leader>ct CopilotChat Tests",
}

for _, action in ipairs(normal) do
  local lhs, cmd = action:match("^(%S+) (.*)$")
  vim.keymap.set("n", lhs, ("<cmd>%s<cr>"):format(cmd), { desc = cmd })
end

for _, action in ipairs(visual) do
  local lhs, cmd = action:match("^(%S+) (.*)$")
  vim.keymap.set("x", lhs, ("<cmd>%s<cr>"):format(cmd), { desc = cmd })
end
