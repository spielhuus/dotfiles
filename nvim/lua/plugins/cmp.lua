return {
        'hrsh7th/nvim-cmp',
        enabled = true,
        dependencies = {
                -- Snippet Engine & its associated nvim-cmp source
                {
                        'L3MON4D3/LuaSnip',
                        build = (function()
                                if vim.fn.has 'win32' == 1 then
                                        return
                                end
                                return 'make install_jsregexp'
                        end)(),
                },
                'saadparwaiz1/cmp_luasnip',
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-path',
                'rafamadriz/friendly-snippets',
                'hrsh7th/cmp-cmdline',
                'rafamadriz/friendly-snippets',
                'onsails/lspkind.nvim',
        },

        config = function()
                local cmp = require 'cmp'

                cmp.setup({
                        snippet = {
                                -- REQUIRED - you must specify a snippet engine
                                expand = function(args)
                                        require'luasnip'.lsp_expand(args.body)
                                end,
                        },
                        window = {
                                completion = cmp.config.window.bordered(),
                                documentation = cmp.config.window.bordered(),
                        },
                        experimental = {
                                ghost_text = true
                        },
                        mapping = cmp.mapping.preset.insert({
                                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                                ['<C-Space>'] = cmp.mapping.complete(),
                                ['<C-e>'] = cmp.mapping.abort(),
                                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                        }),

                        sources = cmp.config.sources({
                                { name = "codeium" },
                                { name = 'nvim_lsp' },
                                -- { name = 'luasnip' },
                                -- { name = 'buffer' },
                                -- { name = 'cmp_tabnine' },
                        })
                })

                -- Set configuration for specific filetype.
                cmp.setup.filetype('gitcommit', {
                        sources = cmp.config.sources({
                                { name = 'git' },
                        }, {
                                { name = 'buffer' },
                        })
                })

                -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
                cmp.setup.cmdline({ '/', '?' }, {
                        mapping = cmp.mapping.preset.cmdline(),
                        sources = {
                                { name = 'buffer' }
                        }
                })

                -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
                cmp.setup.cmdline(':', {
                        mapping = cmp.mapping.preset.cmdline(),
                        sources = cmp.config.sources({
                                { name = 'path' }
                        }, {
                                { name = 'cmdline' }
                        })
                })

                local lspkind = require('lspkind')
                cmp.setup {
                        formatting = {
                                format = lspkind.cmp_format({
                                        mode = 'symbol_text', -- show only symbol annotations
                                        maxwidth = 50,
                                        ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                                        show_labelDetails = true,
                                        symbol_map = { Codeium = "", }
                                })
                        }
                }


                -- Set up lspconfig.
                local capabilities = require('cmp_nvim_lsp').default_capabilities()
                require("luasnip.loaders.from_vscode").lazy_load()
        end
}
