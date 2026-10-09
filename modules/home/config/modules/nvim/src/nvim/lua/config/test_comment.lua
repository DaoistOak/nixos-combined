-- TEST: paint every comment group with no explicit foreground, so comments
-- render in Normal's colour. Revert after testing.
return function()
  for _, group in ipairs({ "Comment", "TSComment", "@comment", "@lsp.type.comment" }) do
    vim.api.nvim_set_hl(0, group, {})
  end
end
