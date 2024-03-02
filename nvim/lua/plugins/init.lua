return {
  -- Git related plugins
  -- 'tpope/vim-fugitive',
  -- 'tpope/vim-rhubarb',
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',
  'RRethy/vim-illuminate',

  -- TODO highlight and search
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = true,
  },
  -- Mini plugins
  {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
      require('mini.trailspace').setup()
      require('mini.sessions').setup()
      require('mini.comment').setup()
    end
  },
}
