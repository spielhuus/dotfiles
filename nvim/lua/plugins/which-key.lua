return {
  -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  enabled = false,
  config = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
    require("which-key").setup {}
    local wk = require("which-key")
    wk.add(
  {
    { "<leader>b", group = "build" },
    { "<leader>bb", "<cmd>OverseerRun<cr>", desc = "Build Menu" },
    { "<leader>bo", "<cmd>OverseerToggle<cr>", desc = "Open Build Tasklist" },
    { "<leader>f", group = "file" },
  })

    wk.add(
  {
    { "<leader>l", group = "LSP" },
    { "<leader>la", "<cmd>Lspsaga code_action<cr>", desc = "Code action" },
    { "<leader>ld", "<cmd>Lspsaga peek_definition<cr>", desc = "Peek definition" },
    { "<leader>li", "<cmd>Lspsaga incoming_calls<cr>", desc = "Incomming calls" },
    { "<leader>lo", "<cmd>Lspsaga outgoing_calls<cr>", desc = "Outgoing calls" },
    { "<leader>lr", "<cmd>Lspsaga rename<cr>", desc = "Rename" },
    { "<leader>lt", "<cmd>Lspsaga peek_type_definition<cr>", desc = "Peek type definition" },
  })

    wk.add({
    { "<C-g>", "<cmd>Neogit<cr>", desc = "Open Neogit buffer." },
    { "\\", "<cmd>Triptych<cr>", desc = "File Browser." },
    })
  end
}
