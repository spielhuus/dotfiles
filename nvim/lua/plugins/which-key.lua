return {
  -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  enabled = true,
  config = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
    require("which-key").setup {}
    local wk = require("which-key")
    wk.register({
      f = {
        name = "file", -- optional group name
      },

      b = {
        name = "build",
        b = { "<cmd>OverseerRun<cr>", "Build Menu" }, -- create a binding with label
        o = { "<cmd>OverseerToggle<cr>", "Open Build Tasklist" }, -- create a binding with label
      },
    }, { prefix = "<leader>" }
    )

    wk.register({
      l = {
        name = "LSP", -- optional group name
        i = { "<cmd>Lspsaga incoming_calls<cr>", "Incomming calls" },
        o = { "<cmd>Lspsaga outgoing_calls<cr>", "Outgoing calls" },
        a = { "<cmd>Lspsaga code_action<cr>", "Code action" },
        d = { "<cmd>Lspsaga peek_definition<cr>", "Peek definition" },
        t = { "<cmd>Lspsaga peek_type_definition<cr>", "Peek type definition" },
        r = { "<cmd>Lspsaga rename<cr>", "Rename" },
      },
    }, { prefix = "<leader>" }
    )

    wk.register({
      ["<C-g>"] = { "<cmd>Neogit<cr>", "Open Neogit buffer." },
      ["\\"] = { "<cmd>Triptych<cr>", "File Browser." },
    })
  end
}
