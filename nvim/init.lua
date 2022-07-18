-- Map leader to space
require('packer_init')

-- Sensible defaults
require('turbo')
require('config/options')
require('config/colors')
require('config/mappings')

-- configure plugins
require('plugins/treesitter')
require('plugins/luasnip')
require('plugins/telescope')
require('plugins/nvim-lspconfig')
require('plugins/nvim-cmp')
require('plugins/neotest')
-- require('plugins/nvim-dap')
require('dap-python').setup('~/.virtualenvs/debugpy/bin/python')
require('kommentary.config').use_extended_mappings()
require 'lspconfig'.gopls.setup {
    on_attach = function(client)
        -- [[ other on_attach code ]]
        require 'illuminate'.on_attach(client)
    end,
}
