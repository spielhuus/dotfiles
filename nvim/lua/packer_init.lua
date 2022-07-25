-----------------------------------------------------------
-- Plugin manager configuration file
-----------------------------------------------------------

-- Plugin manager: packer.nvim
-- url: https://github.com/wbthomason/packer.nvim

-- For information about installed plugins see the README:
-- neovim-lua/README.md
-- https://github.com/brainfucksec/neovim-lua#readme


-- Automatically install packer
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({
        'git',
        'clone',
        '--depth',
        '1',
        'https://github.com/wbthomason/packer.nvim',
        install_path
    })
    vim.o.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath
end

-- Autocommand that reloads neovim whenever you save the packer_init.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost packer_init.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, 'packer')
if not status_ok then
    return
end

-- Install plugins
return packer.startup(function(use)
--    -- Add you plugins here:
    use 'wbthomason/packer.nvim' -- packer can manage itself

    -- Icons
    use "kyazdani42/nvim-web-devicons"

    -- File explorer
    -- use 'kyazdani42/nvim-tree.lua'

    -- Indent line
    -- use 'lukas-reineke/indent-blankline.nvim'

    use({
      "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
      config = function()
        require("lsp_lines").setup()
      end,
    })

    -- kommentary
    use 'b3nj5m1n/kommentary'

    -- scrollbar
    use {
        'lewis6991/satellite.nvim',
        config = function()
            require('satellite').setup()
        end
    }

    -- lastplace, opens file at last edited position
    use { 'ethanholz/nvim-lastplace',
        config = function()
            require 'nvim-lastplace'.setup {
                lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
                lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
                lastplace_open_folds = true
            }
        end
    }

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

    -- TODO manager
    use {
        "folke/todo-comments.nvim",
        requires = "nvim-lua/plenary.nvim",
        config = function()
            require("todo-comments").setup { }
        end
    }

    -- Treesitter interface
    use {
        'nvim-treesitter/nvim-treesitter',
        requires = { { 'mfussenegger/nvim-ts-hint-textobject' }, { 'theHamsta/nvim-treesitter-pairs' },
            { 'romgrk/nvim-treesitter-context' }, { 'windwp/nvim-ts-autotag' } },
        run = ':TSUpdate'
    }

    -- LSP
    use 'neovim/nvim-lspconfig'
    use { "williamboman/mason.nvim" }
    --- use { "williamboman/nvim-lsp-installer", }
    use { 'simrat39/rust-tools.nvim' }
    use {
        'saecki/crates.nvim',
        tag = 'v0.2.1',
        requires = { 'nvim-lua/plenary.nvim' },
        config = function()
            require('crates').setup()
        end,
    }
    use { 'folke/lsp-colors.nvim' }
    use { "j-hui/fidget.nvim", -- lsp status
        config = function()
            require('fidget').setup()
        end
    }
    use { "RRethy/vim-illuminate" }

    -- Unit test runner
    use {
        "nvim-neotest/neotest",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-neotest/neotest-python",
            "nvim-neotest/neotest-vim-test",
            "vim-test/vim-test",
        }
    }

    -- Debugger
    use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
    use { 'Pocco81/DAPInstall.nvim' }
    use { 'szw/vim-maximizer' }
    use { 'mfussenegger/nvim-dap-python' }

    -- Autocomplete
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'L3MON4D3/LuaSnip',
            'hrsh7th/cmp-nvim-lsp',
            'rafamadriz/friendly-snippets',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-buffer',
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-nvim-lsp-signature-help',
        },
    }

    -- Statusline
    use { 'nvim-lualine/lualine.nvim',
        config = function()
            require('lualine').setup {
                options = {
                    icons_enabled = true,
                    theme = 'turbo',
                    component_separators = { left = '', right = '' },
                    section_separators = { left = '', right = '' },
                    disabled_filetypes = {},
                    always_divide_middle = true,
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff', 'diagnostics' },
                    lualine_c = { 'filename' },
                    lualine_x = { 'encoding', 'fileformat', 'filetype' },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' }
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { 'filename' },
                    lualine_x = { 'location' },
                    lualine_y = {},
                    lualine_z = {}
                },
                tabline = {},
                extensions = {}
            }
        end
    }

    -- git labels
    use {
       'lewis6991/gitsigns.nvim',
       requires = { 'nvim-lua/plenary.nvim' },
       config = function()
           require('gitsigns').setup()
       end
   }

    -- Telescope and integrations
    use {
        'nvim-telescope/telescope.nvim',
        requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' } }
    }
    use { 'ibhagwan/fzf-lua',
        -- optional for icon support
        requires = { 'kyazdani42/nvim-web-devicons' }
    }
    use {
        'ahmedkhalf/project.nvim',
        config = function()
            require("project_nvim").setup {
                -- configuration
            }
        end
    }

    -- perfanno, show results from perf
    --[[ use {
       't-troebst/perfanno.nvim',
        config = function()
            require("perfanno").setup {
               -- configuration
            }
        end
    } ]]
    

    -- File browser
    use {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        requires = {
            "nvim-lua/plenary.nvim",
            "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim"
        },
        config = function()
            -- Unless you are still migrating, remove the deprecated commands from v1.x
            vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

            -- If you want icons for diagnostic errors, you'll need to define them somewhere:
            vim.fn.sign_define("DiagnosticSignError",
                { text = " ", texthl = "DiagnosticSignError" })
            vim.fn.sign_define("DiagnosticSignWarn",
                { text = " ", texthl = "DiagnosticSignWarn" })
            vim.fn.sign_define("DiagnosticSignInfo",
                { text = " ", texthl = "DiagnosticSignInfo" })
            vim.fn.sign_define("DiagnosticSignHint",
                { text = "", texthl = "DiagnosticSignHint" })
            -- NOTE: this is changed from v1.x, which used the old style of highlight groups
            -- in the form "LspDiagnosticsSignWarning"

            require("neo-tree").setup({
                close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
                popup_border_style = "rounded",
                enable_git_status = true,
                enable_diagnostics = true,
                default_component_configs = {
                    indent = {
                        indent_size = 2,
                        padding = 1, -- extra padding on left hand side
                        -- indent guides
                        with_markers = true,
                        indent_marker = "│",
                        last_indent_marker = "└",
                        highlight = "NeoTreeIndentMarker",
                        -- expander config, needed for nesting files
                        with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
                        expander_collapsed = "",
                        expander_expanded = "",
                        expander_highlight = "NeoTreeExpander",
                    },
                    icon = {
                        folder_closed = "",
                        folder_open = "",
                        folder_empty = "ﰊ",
                        default = "*",
                    },
                    name = {
                        trailing_slash = false,
                        use_git_status_colors = true,
                    },
                    git_status = {
                        symbols = {
                            -- Change type
                            added     = "✚",
                            deleted   = "✖",
                            modified  = "",
                            renamed   = "",
                            -- Status type
                            untracked = "",
                            ignored   = "",
                            unstaged  = "",
                            staged    = "",
                            conflict  = "",
                        }
                    },
                },
                window = {
                    position = "left",
                    width = 40,
                    mappings = {
                        ["<space>"] = "toggle_node",
                        ["<2-LeftMouse>"] = "open",
                        ["<cr>"] = "open",
                        ["S"] = "open_split",
                        ["s"] = "open_vsplit",
                        ["C"] = "close_node",
                        ["<bs>"] = "navigate_up",
                        ["."] = "set_root",
                        ["H"] = "toggle_hidden",
                        ["R"] = "refresh",
                        ["/"] = "fuzzy_finder",
                        ["f"] = "filter_on_submit",
                        ["<c-x>"] = "clear_filter",
                        ["a"] = "add",
                        ["A"] = "add_directory",
                        ["d"] = "delete",
                        ["r"] = "rename",
                        ["y"] = "copy_to_clipboard",
                        ["x"] = "cut_to_clipboard",
                        ["p"] = "paste_from_clipboard",
                        ["c"] = "copy", -- takes text input for destination
                        ["m"] = "move", -- takes text input for destination
                        ["q"] = "close_window",
                    }
                },
                nesting_rules = {},
                filesystem = {
                    filtered_items = {
                        visible = false, -- when true, they will just be displayed differently than normal items
                        hide_dotfiles = true,
                        hide_gitignored = true,
                        hide_by_name = {
                            ".DS_Store",
                            "thumbs.db"
                            --"node_modules"
                        },
                        never_show = { -- remains hidden even if visible is toggled to true
                            --".DS_Store",
                            --"thumbs.db"
                        },
                    },
                    follow_current_file = true, -- This will find and focus the file in the active buffer every
                    -- time the current file is changed while the tree is open.
                    hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
                    -- in whatever position is specified in window.position
                    -- "open_current",  -- netrw disabled, opening a directory opens within the
                    -- window like netrw would, regardless of window.position
                    -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
                    use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
                    -- instead of relying on nvim autocmd events.
                },
                buffers = {
                    show_unloaded = true,
                    window = {
                        mappings = {
                            ["bd"] = "buffer_delete",
                        }
                    },
                },
                git_status = {
                    window = {
                        position = "float",
                        mappings = {
                            ["A"]  = "git_add_all",
                            ["gu"] = "git_unstage_file",
                            ["ga"] = "git_add_file",
                            ["gr"] = "git_revert_file",
                            ["gc"] = "git_commit",
                            ["gp"] = "git_push",
                            ["gg"] = "git_commit_and_push",
                        }
                    }
                }
            })
            vim.cmd([[nnoremap \ :Neotree reveal<cr>]])
        end
    }
    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)
