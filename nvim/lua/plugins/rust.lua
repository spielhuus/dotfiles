vim.g.rustaceanvim = function()
  return {
    tools = {
      -- inlay_hints = {
      --   enabled = true,
      --   -- automatically set inlay hints (type hints)
      --   -- default: true
      --   auto = true,
      --
      --   -- Only show inlay hints for the current line
      --   only_current_line = false,
      --
      --   -- whether to show parameter hints with the inlay hints or not
      --   -- default: true
      --   show_parameter_hints = true,
      --
      --   -- prefix for parameter hints
      --   -- default: "<-"
      --   parameter_hints_prefix = "<- ",
      --
      --   -- prefix for all the other hints (type, chaining)
      --   -- default: "=>"
      --   other_hints_prefix = "=> ",
      --
      --   -- whether to align to the length of the longest line in the file
      --   max_len_align = false,
      --
      --   -- padding from the left if max_len_align is true
      --   max_len_align_padding = 1,
      --
      --   -- whether to align to the extreme right or not
      --   right_align = false,
      --
      --   -- padding from the right if right_align is true
      --   right_align_padding = 7,
      --
      --   -- The color of the hints
      --   highlight = "Comment",
      -- },
    },

    -- other rustacean settings. --
    server = {
      on_attach = function(_, bufnr)
        vim.keymap.set("n", "ca", function() vim.cmd.RustLsp('codeAction') end, { buffer = bufnr })
        vim.keymap.set("n", "rd", function() vim.cmd.RustLsp('renderDiagnostic') end, { buffer = bufnr })
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP [g]o to [d]efinition.", buffer = bufnr })
        vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "LSP [g]o to [r]eferences.", buffer = bufnr })
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "LSP go to previous diagnostic.", buffer = bufnr })
        vim.keymap.set("n", "[e",
          function()
            vim.diagnostic.goto_prev({
              severity = vim.diagnostic.severity.ERROR,
              wrap = true
            })
          end, { desc = "LSP go to previous error diagnostic.", buffer = bufnr })
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "LSP go to next diagnostic.", buffer = bufnr })
        vim.keymap.set("n", "]e",
          function()
            vim.diagnostic.goto_next({
              severity = vim.diagnostic.severity.ERROR,
              wrap = true
            })
          end, { desc = "LSP go to previous error diagnostic.", buffer = bufnr })
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { desc = "LSP signature help.", buffer = bufnr })
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename,
          { desc = "LSP [R]ena[m]e symbol under cusror.", buffer = bufnr })
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float,
          { desc = "LSP open diagnostic as floating window.", buffer = bufnr })
      end,
      default_settings = {
        -- rust-analyzer language server configuration
        ['rust-analyzer'] = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
            runBuildScripts = true,
          },
          -- Add clippy lints for Rust.
          checkOnSave = {
            allFeatures = true,
            command = "clippy",
            extraArgs = { "--no-deps" },
          },
          procMacro = {
            enable = true,
            ignored = {
              ["async-trait"] = { "async_trait" },
              ["napi-derive"] = { "napi" },
              ["async-recursion"] = { "async_recursion" },
            },
          },
          diagnostics = {
            enable = true,
          },
          inlayHints = {
            lifetimeElisionHints = {
              enable = true,
              useParameterNames = true,
            },
          },
        },
      }
    }
  }
end

-- set some vim diagnostic options
vim.diagnostic.config {
  virtual_lines = true,
  virtual_text = {
    source = true,
    prefix = "■",
  },
  -- virtual_text = false,
  float = {
    source = true,
    border = "rounded",
  },
  signs = true,
  underline = false,
  update_in_insert = false,
  severity_sort = true,
}

return {
  {
    'mrcjkb/rustaceanvim',
    version = '^4', -- Recommended
    ft = { 'rust' },
    config = function()
    end
  },
  {
    'saecki/crates.nvim',
    tag = 'stable',
    event = { "BufRead Cargo.toml" },
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
    config = function()
      require('crates').setup()
    end,
  }
}
