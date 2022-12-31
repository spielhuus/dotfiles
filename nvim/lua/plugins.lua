local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
    install_path })
  vim.cmd [[packadd packer.nvim]]
end

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

return require('packer').startup({ function(use)

  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- GUI tools

  -- Icons
  use("kyazdani42/nvim-web-devicons")

  use({
    "hood/popui.nvim",
    requires = { "RishabhRD/popfix" },
  })

  --notify
  use({
    "rcarriga/nvim-notify",
    config = function()
      require("config.notify").setup()
    end,
  })

  use { "RRethy/vim-illuminate" }

  -- Indent line
  use("lukas-reineke/indent-blankline.nvim")

  use({
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    disable = true,
    requires = { "RishabhRD/popfix" },
  })

  -- NeoTree (Filebrowser)
  use({
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    requires = {
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      {
        -- only needed if you want to use the commands with "_with_window_picker" suffix
        's1n7ax/nvim-window-picker',
        tag = "v1.*",
        config = function()
          require 'window-picker'.setup({
            autoselect_one = true,
            include_current = false,
            filter_rules = {
              -- filter using buffer options
              bo = {
                -- if the file type is one of following, the window will be ignored
                filetype = { 'neo-tree', "neo-tree-popup", "notify", "quickfix" },

                -- if the buffer type is one of following, the window will be ignored
                buftype = { 'terminal' },
              },
            },
            other_win_hl_color = '#e35e4f',
          })
        end,
      }
    },
    config = function()
      require("config.neotree").setup()
    end,
  })

  --autosave
  use({
    "Pocco81/auto-save.nvim",
    disable = true,
    config = function()
      require("auto-save").setup {}
    end,
  })

  -- trouble.nvim
  use({
    "folke/trouble.nvim",
    wants = "nvim-web-devicons",
    cmd = { "TroubleToggle", "Trouble" },
    config = function()
      require("trouble").setup({
        use_diagnostic_signs = true,
      })
    end,
  })

  -- kommentary
  use("b3nj5m1n/kommentary")

  -- fold
  use { 'anuvyklack/pretty-fold.nvim',
    config = function()
      require('pretty-fold').setup()
    end
  }

  -- scrollbar
  use({
    "lewis6991/satellite.nvim",
    config = function()
      require("satellite").setup()
    end,
  })

  use {
    "karb94/neoscroll.nvim",
    config = function()
      require("config.neoscroll").setup()
    end
  }

  -- Buffer line
  use({
    "akinsho/nvim-bufferline.lua",
    wants = "nvim-web-devicons",
    config = function()
      require("bufferline").setup()
    end,
  })

  -- Statusline
  use({
    "nvim-lualine/lualine.nvim",
    config = function()
      require("config.lualine").setup()
    end,
  })

  -- User interface
  use({
    "stevearc/dressing.nvim",
    event = "BufReadPre",
    config = function()
      require("config.dressing").setup()
    end,
  })

  use({
    "ziontee113/icon-picker.nvim",
    config = function()
      require("icon-picker").setup({
        disable_legacy_commands = true
      })
    end,
  })

  -- TODO manager
  use {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {}
    end
  }

  -- Terminal
  use({ "akinsho/toggleterm.nvim", config = function()
    require("config.toggleterm").setup()
  end })

  -- Code documentation
  use({
    "danymat/neogen",
    config = function()
      require("config.neogen").setup()
    end,
    cmd = { "Neogen" },
    module = "neogen",
    disable = false,
  })

  -- lastplace, opens file at last edited position
  use({
    "ethanholz/nvim-lastplace",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
        lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
        lastplace_open_folds = true,
      })
    end,
  })

  -- show popup when switching buffers
  use({
    "ghillb/cybu.nvim",
    branch = "v1.x", -- won't receive breaking changes
    -- branch = "main", -- timely updates
    requires = { "kyazdani42/nvim-web-devicons" }, --optional
    config = function()
      local ok, cybu = pcall(require, "cybu")
      if not ok then
        return
      end
      cybu.setup()
      vim.keymap.set("n", "<C-h>", "<Plug>(CybuPrev)")
      vim.keymap.set("n", "<C-l>", "<Plug>(CybuNext)")
      vim.keymap.set({ "n", "v" }, "<c-s-tab>", "<plug>(CybuLastusedPrev)")
      vim.keymap.set({ "n", "v" }, "<c-tab>", "<plug>(CybuLastusedNext)")
    end,
  })

  -- Treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    --[[ opt = true,
    event = "BufReadPre", ]]
    run = ":TSUpdate",
    config = function()
      require("config.treesitter").setup()
    end,
    requires = {
      { "nvim-treesitter/nvim-treesitter-textobjects", event = "BufReadPre" },
      { "windwp/nvim-ts-autotag", event = "InsertEnter",
        config = function()
          require('nvim-ts-autotag').setup()
        end
      },
      { "RRethy/nvim-treesitter-textsubjects", event = "BufReadPre" },
      { "theHamsta/nvim-treesitter-pairs" },
      { "nvim-treesitter/nvim-treesitter-context",
        config = function()
          require('config.treesitter_context').setup()
        end
      },
    },
  }

  -- Auto pairs
  use({
    "windwp/nvim-autopairs",
    opt = true,
    event = "InsertEnter",
    wants = "nvim-treesitter",
    module = { "nvim-autopairs.completion.cmp", "nvim-autopairs" },
    config = function()
      require("config.autopairs").setup()
    end,
  })

  -- Auto tag
  use({
    "windwp/nvim-ts-autotag",
    opt = true,
    wants = "nvim-treesitter",
    event = "InsertEnter",
    config = function()
      require("nvim-ts-autotag").setup({ enable = true })
    end,
  })

  -- Mason
  use {
    "williamboman/mason.nvim",
    requires = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "WhoIsSethDaniel/mason-tool-installer.nvim"
    },
    config = function()
      require("config.mason").setup()
    end,
  }

  -- LSP
  use {
    'neovim/nvim-lspconfig',
    config = function()
      require("config.lsp").setup()
    end,
    requires = {
      -- "williamboman/nvim-lsp-installer",
      -- { "lvimuser/lsp-inlayhints.nvim", branch = "readme" },
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "folke/lua-dev.nvim",
      "RRethy/vim-illuminate",
      -- "jose-elias-alvarez/null-ls.nvim",
      {
        "j-hui/fidget.nvim",
        config = function()
          require("fidget").setup({})
        end,
      },
      "b0o/schemastore.nvim",
      "jose-elias-alvarez/typescript.nvim",
      {
        "SmiteshP/nvim-navic",
        config = function()
          require("nvim-navic").setup({})
        end,
        module = { "nvim-navic" },
      },
      {
        "simrat39/inlay-hints.nvim",
        config = function()
          require("inlay-hints").setup()
        end,
      },
    },
  }

  -- Completion
  use({
    "hrsh7th/nvim-cmp",
    --[[ opt = true,
    event = "InsertEnter", ]]
    config = function()
      require("config.cmp").setup()
    end,
    wants = { "LuaSnip" },
    requires = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "ray-x/cmp-treesitter",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "lukas-reineke/cmp-rg",
      "davidsierradz/cmp-conventionalcommits",
      {
        "L3MON4D3/LuaSnip",
        wants = { "friendly-snippets", "vim-snippets" },
        config = function()
          require("config.snip").setup()
        end,
      },
      "rafamadriz/friendly-snippets",
      "honza/vim-snippets",
    },
  })


  -- fzf
  use { 'ibhagwan/fzf-lua',
    -- optional for icon support
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim',
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-project.nvim",
    },
    wants = { 'nvim-telescope/telescope-fzf-native.nvim' },
    config = function()
      require("config.telescope").setup()
    end,
  }
  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
  }

  -- Test
  use {
    "nvim-neotest/neotest",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-plenary",
      "rouge8/neotest-rust",
    },
    config = function()
      require("config.neotest").setup()
    end,
    disable = true,
  }
  -- Debugger
  use({
    "mfussenegger/nvim-dap",
    requires = {
      -- "alpha2phi/DAPInstall.nvim",
      -- { "Pocco81/dap-buddy.nvim", branch = "dev" },
      "theHamsta/nvim-dap-virtual-text",
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "nvim-telescope/telescope-dap.nvim",
      { "leoluz/nvim-dap-go", module = "dap-go" },
      { "jbyuki/one-small-step-for-vimkind", module = "osv" },
    },
    config = function()
      require("config.dap").setup()
    end,
  })

  -- git labels
  use({
    "lewis6991/gitsigns.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup()
    end,
  })

  -- Language Support

  -- Rust
  use({
    "simrat39/rust-tools.nvim",
    requires = { "nvim-lua/plenary.nvim", "rust-lang/rust.vim" },
    config = function()
      require("config/rust").setup()
    end
  })
  use {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    requires = { { "nvim-lua/plenary.nvim" } },
    config = function()
      require("crates").setup {
      }
    end,
  }

  -- R
  -- use 'jalvesaq/Nvim-R'

  -- parse codeblocks in markdown files
  use {
    "jubnzv/mdeval.nvim",
    config = function()
      require('config/mdeval').setup()
    end,
  }

  use { 'michaelb/sniprun', run = 'bash ./install.sh'}

  use {
    'AckslD/nvim-FeMaco.lua',
    config = 'require("femaco").setup()',
  }

  if packer_bootstrap then
    require('packer').sync()
  end
end,
  config = {
    display = {
      open_fn = function()
        return require('packer.util').float({ border = 'single' })
      end
    }
  } })
