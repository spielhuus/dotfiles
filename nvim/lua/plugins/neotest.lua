return({
  "nvim-neotest/neotest",
  enabled = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/nvim-nio",
  },
  config = function ()
    require("neotest").setup({
      adapters = {
        require('rustaceanvim.neotest'),
      },
    })
    vim.keymap.set('n', '<leader>tr', require('neotest').run.run, { desc = '[T]est [R]un nearest nest.' })
    vim.keymap.set('n', '<leader>td', function() require('neotest').run.run({strategy = "dap"}) end, { desc = '[T]est [D]ebug nearest nest.' })
    vim.keymap.set('n', '<leader>ts', require('neotest').summary.open, { desc = '[T]est [S]ummary open.' })
    vim.keymap.set('n', '<leader>to', require('neotest').output_panel.open, { desc = '[T]est [O]output panel.' })
  end
})
