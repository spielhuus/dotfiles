local M = {}

local on_attach = function(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

function M.setup()

  -- Mappings.
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  local opts = { noremap = true, silent = true }
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '<space>d[', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', '<space>d]', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<leader>dd', '<cmd>Telescope diagnostics<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  require'lspconfig'.esbonio.setup{
    on_attach = on_attach,
    flags = lsp_flags,
  }
  require'lspconfig'.ltex.setup{
    on_attach = on_attach,
    flags = lsp_flags,
  }
  require'lspconfig'.dockerls.setup{
    on_attach = on_attach,
    flags = lsp_flags,
  }
  require'lspconfig'.grammarly.setup{
    on_attach = on_attach,
    flags = lsp_flags,
  }
  require('lspconfig')['clangd'].setup {
    on_attach = on_attach,
    flags = lsp_flags,
  }
  require('lspconfig')['pyright'].setup {
    on_attach = on_attach,
    flags = lsp_flags,
  }
  require('lspconfig')['tsserver'].setup {
    on_attach = on_attach,
    flags = lsp_flags,
  }
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  require'lspconfig'.html.setup {
    capabilities = capabilities,
  }
  require('lspconfig')['html'].setup {
    on_attach = on_attach,
    flags = lsp_flags,
    settings = {
      css = {
        lint = {
          validProperties = {},
        },
      },
    },
  }

  require 'lspconfig'.lua_ls.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  }
end

return M
