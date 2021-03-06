

-- Map leader to space
vim.g.mapleader = ' '

local utils = require('utils')

utils.opt('o', 'completeopt', 'menuone,noinsert,noselect')
vim.cmd [[set shortmess+=c]]
vim.g.completion_confirm_key = ""
vim.g.completion_matching_strategy_list = {'exact', 'substring', 'fuzzy'}

-- <Tab> to navigate the completion menu
utils.map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', {expr = true})
utils.map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})

-- utils.map('n', '<C-h>', '<cmd>bp<CR>') -- previous buffer
-- utils.map('n', '<C-l>', '<cmd>bn<CR>') -- next buffer
utils.map('n', '<C-p>', '<cmd>Telescope projects<CR>') -- open projects
utils.map('n', '<leader>t', '<cmd>Telescope yabs tasks<CR>') -- open run tasks

-- mappings for quicklist
utils.map('n', '<leader>j', '<cmd>cn<CR>') -- next item in quicklist
utils.map('n', '<leader>k', '<cmd>cb<CR>') -- previous item in quicklist
--
-- debug mappings
utils.map('n', '<leader>B', '<cmd>lua require\'dap\'.toggle_breakpoint()<CR>') -- open run tasks
utils.map('n', '<leader>C', '<cmd>lua require\'dap\'.continue()<CR>') -- open run tasks
utils.map('n', '<leader>R', '<cmd>lua require\'dap\'.repl.open()<CR>') -- open run tasks
utils.map('n', '<leader>S', '<cmd>lua require\'utils\'.open_sidebar()<CR>') -- open run tasks
-- utils.map('n', '<C-o>', '<cmd>lua require\'dap\'.step_over()<CR>') -- open run tasks
utils.map('n', '<C-i>', '<cmd>lua require\'dap\'.step_into()<CR>') -- open run tasks

utils.map('i', 'jk', '<Esc>')           -- jk to escape

