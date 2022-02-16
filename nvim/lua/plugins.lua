return require('packer').startup(function()

  -- Packer can manage itself as an optional plugin
  use {'wbthomason/packer.nvim', opt = true}

  -- Color scheme
  use { 'tomasiser/vim-code-dark' }
  use { 'navarasu/onedark.nvim' }
  use {"adisen99/codeschool.nvim", requires = {"rktjmp/lush.nvim"}}
  use { 'kyazdani42/nvim-web-devicons' }                  
  use { 'simrat39/symbols-outline.nvim' }
 
  -- Fuzzy finder
  use {
      'nvim-telescope/telescope.nvim',
      requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }
  use { 'sudormrfbin/cheatsheet.nvim' }
  -- Debugger and Runner
  use {
    'pianocomposer321/yabs.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }
  use { 'mfussenegger/nvim-dap' }
  use { 'Pocco81/DAPInstall.nvim' }
  use { 'szw/vim-maximizer' }
  use { 'mfussenegger/nvim-dap-python' }

  -- Treesitter and completion
  use {
        'nvim-treesitter/nvim-treesitter',
        requires = {{'mfussenegger/nvim-ts-hint-textobject'}, {'theHamsta/nvim-treesitter-pairs'}, 
                    {'romgrk/nvim-treesitter-context'}, {'windwp/nvim-ts-autotag'}},
        run = ':TSUpdate'
  }

  use {
        'hrsh7th/nvim-cmp',
        requires = {{'hrsh7th/cmp-nvim-lsp'}, {'hrsh7th/cmp-buffer'}, {'hrsh7th/cmp-path'}, {'hrsh7th/cmp-cmdline'}},
        run = ':TSUpdate'
  }

  -- LSP and completion
  use { 'neovim/nvim-lspconfig' }
  use { 'nvim-lua/completion-nvim' }
  use { 'folke/trouble.nvim' }
  use { 'romgrk/barbar.nvim' }
  use { 'folke/lsp-colors.nvim' }

 -- Snippet support
  use { "rafamadriz/friendly-snippets" }
  use { "L3MON4D3/LuaSnip" }

-- doge code documentation
  use { 'kkoomen/vim-doge' }

  -- use { 'mgedmin/coverage-highlight.vim' }
  -- Lua development
  -- use { 'tjdevries/nlua.nvim' }

  -- Vim dispatch
  use { 'tpope/vim-dispatch' }

  -- Fugitive for Git
  use { 'tpope/vim-fugitive' }

  -- Project management
  use {
    'ahmedkhalf/project.nvim',
    config = function()
      require("project_nvim").setup{
          -- configuration
      }
    end
  }
  use { 'ethanholz/nvim-lastplace' }
  use {'stevearc/aerial.nvim'}

   -- Status and tabline
  use { 'nvim-lualine/lualine.nvim' }

  -- Indent Blankline
  use { "lukas-reineke/indent-blankline.nvim" }

end)
