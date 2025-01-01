return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = true,
    -- event = "BufReadPre", ]]
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "arduino", "bash", "c", "cmake", "cpp", "css", "dockerfile", "git_config",
                             "git_rebase", "gitattributes", "gitcommit", "gitignore", "html", "javascript",
                             "json", "lua", "make", "markdown", "markdown_inline", "python", "regex",
                             "rust", "scss", "yaml" },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        auto_install = true,

        -- List of parsers to ignore installing (for "all")
        ignore_install = {},

        highlight = {
          enable = true,
          disable = {},
          additional_vim_regex_highlighting = false,
        },

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
      }
    end,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", event = "BufReadPre", enabled = false },
      { "windwp/nvim-ts-autotag", event = "InsertEnter",
        config = function()
          require('nvim-ts-autotag').setup()
        end
      },
      { "RRethy/nvim-treesitter-textsubjects", event = "BufReadPre" },
      { "theHamsta/nvim-treesitter-pairs" },
      { "nvim-treesitter/nvim-treesitter-context",
        enabled = false,
        config = function()
          require 'treesitter-context'.setup {
            enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
            max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
            trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
            patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
              -- For all filetypes
              -- Note that setting an entry here replaces all other patterns for this entry.
              -- By setting the 'default' entry below, you can control which nodes you want to
              -- appear in the context window.
              default = {
                'class',
                'function',
                'method',
                'for', -- These won't appear in the context
                'while',
                'if',
                'switch',
                'case',
              },
              -- Example for a specific filetype.
              -- If a pattern is missing, *open a PR* so everyone can benefit.
              --   rust = {
              --       'impl_item',
              --   },
            },
            exact_patterns = {
              -- Example for a specific filetype with Lua patterns
              -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
              -- exactly match "impl_item" only)
              -- rust = true,
            },

            -- [!] The options below are exposed but shouldn't require your attention,
            --     you can safely ignore them.

            zindex = 20, -- The Z-index of the context window
            mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
            separator = nil, -- Separator between context and content. Should be a single character string, like '-'.
          }
        end
      },
    },
  },
}
