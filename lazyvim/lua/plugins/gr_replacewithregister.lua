return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "gr", false },
            { "gR", vim.lsp.buf.references, desc = "References", nowait = true },
            { "gRr", vim.lsp.buf.references, desc = "References", nowait = true },
            { "gRn", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
            { "gRa", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "x" }, has = "codeAction" },
            { "gRi", vim.lsp.buf.implementation, desc = "Goto Implementation" },
            { "gRt", vim.lsp.buf.type_definition, desc = "Goto Type Definition" },
          },
        },
      },
    },
  },
  {
    "inkarkat/vim-ReplaceWithRegister",
    lazy = false,
  },
}
