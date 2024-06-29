return({
        'gsuuon/model.nvim',
        enabled = false,

        -- Don't need these if lazy = false
        cmd = { 'M', 'Model', 'Mchat' },
        init = function()
                vim.filetype.add({
                        extension = {
                                mchat = 'mchat',
                        }
                })
        end,
        config = function()

                require('model').setup({
                        prompts = {
                                ['ollama:starling'] = {
                                        provider = ollama,
                                        params = {
                                                model = 'starling-lm'
                                        },
                                        builder = function(input)
                                                return {
                                                        prompt = 'GPT4 Correct User: ' .. input .. '<|end_of_turn|>GPT4 Correct Assistant: '
                                                }
                                        end
                                },
                        },
                        chats = {
                                llama = {
                                        provider = llamacpp,
                                        options = {
                                                -- create = "Hello> ",
                                                -- run = "Hello> ",
                                                model = 'models/llama-2-7b.Q4_0.gguf',
                                                args = {
                                                        '-n', 400,
                                                        '-ngl', 33,
                                                        '-sm', 'layer',
                                                }
                                        },
                                        builder = function(input, context)
                                                return {
                                                        prompt =
                                                        '<|system|>'
                                                        .. (context.args or 'You are a helpful assistant')
                                                        .. '\n</s>\n<|user|>\n'
                                                        .. input
                                                        .. '</s>\n<|assistant|>',
                                                        stops = { '</s>' }
                                                }
                                        end
                                }
                        }
                })
        end,
        ft = 'mchat',

        keys = {
                {'<C-m>d', ':Mdelete<cr>', mode = 'n'},
                {'<C-m>s', ':Mselect<cr>', mode = 'n'},
                {'<C-m><space>', ':Mchat<cr>', mode = 'n' }
        },
})


