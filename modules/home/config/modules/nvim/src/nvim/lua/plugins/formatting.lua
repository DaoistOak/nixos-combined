return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        -- LazyVim ships no formatter for C/C++, so conform had an empty table
        -- for them and <leader>f silently did nothing on a .cpp file.
        -- clang-format comes from the clang-tools package already in
        -- extraPackages; style comes from the .clang-format in each project,
        -- and absent one LLVM style is the default.
        c = { "clang_format" },
        cpp = { "clang_format" },
        objc = { "clang_format" },
      },
    },
  },
}
