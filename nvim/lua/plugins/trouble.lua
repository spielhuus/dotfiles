return {
  "folke/trouble.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    'folke/which-key.nvim',
  },
  opts = function ()
    require("trouble").setup()
    require("which-key").register({
      x = {
        name = "Trouble", -- optional group name
        x = {function() require("trouble").toggle() end, "Trouble toggle" },
        t = {"<cmd>TodoTrouble<CR>", "Trouble TODO" },
        w = {function() require("trouble").toggle("workspace_diagnostics") end, "Trouble open workspace diagnostics" },
        d = {function() require("trouble").toggle("document_diagnostics") end, "Trouble open document diagnostics" },
        q = {function() require("trouble").toggle("quickfix") end, "Trouble open quickfix" },
        l = {function() require("trouble").toggle("locallist") end, "Trouble open loclist" },
      },
    }, { prefix = "<leader>" })

    require("which-key").register({
      g = {
        name = "Trouble", -- optional group name
        R = {function() require("trouble").toggle("lsp_references") end, "Trouble LSP refrences" },
      },
    })

    -- vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end)
    -- vim.keymap.set("n", "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end)
    -- vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("document_diagnostics") end)
    -- vim.keymap.set("n", "<leader>xq", function() require("trouble").toggle("quickfix") end)
    -- vim.keymap.set("n", "<leader>xl", function() require("trouble").toggle("loclist") end)
    -- vim.keymap.set("n", "gR", function() require("trouble").toggle("lsp_references") end)
  end
}
