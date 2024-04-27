return {
  -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  config = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
    require("which-key").setup {}
    local wk = require("which-key")
    wk.register({
      f = {
        name = "file", -- optional group name
        f = { "<cmd>Telescope find_files<cr>", "Find File" }, -- create a binding with label
        -- r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File", noremap=false, buffer = bufnr }, -- additional options for creating the keymap
        b = { function() print("bar") end, "Foobar" } -- you can also pass functions!
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
