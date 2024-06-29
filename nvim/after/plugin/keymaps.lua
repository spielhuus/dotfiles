-- Map leader to space
vim.g.mapleader = ' '

-- local keymap = vim.api.nvim_set_keymap
local keymap = vim.keymap.set
local default_opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, expr = true, silent = true }

-- Better escape using jk in insert and terminal mode
--[[ keymap("i", "jk", "<ESC>", default_opts)
keymap("t", "jk", "<C-\\><C-n>", default_opts)
keymap("t", "<C-h>", "<C-\\><C-n><C-w>h", default_opts)
keymap("t", "<C-j>", "<C-\\><C-n><C-w>j", default_opts)
keymap("t", "<C-k>", "<C-\\><C-n><C-w>k", default_opts)
keymap("t", "<C-l>", "<C-\\><C-n><C-w>l", default_opts) ]]

-- Center search results
keymap("n", "n", "nzz", default_opts)
keymap("n", "N", "Nzz", default_opts)

-- Visual line wraps
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", expr_opts)
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", expr_opts)

-- -- Always center
-- keymap("n", "k", "kzz", default_opts)
-- keymap("n", "j", "jzz", default_opts)
-- keymap("n", "G", "Gzz", default_opts)

-- Better indent
keymap("v", "<", "<gv", default_opts)
keymap("v", ">", ">gv", default_opts)

-- Paste over currently selected text without yanking it
keymap("v", "p", '"_dP', default_opts)

-- Switch buffer
-- keymap("n", "<S-h>", ":BufferLineCyclePrev<CR>", default_opts)
-- keymap("n", "<S-l>", ":BufferLineCycleNext<CR>", default_opts)

-- Cancel search highlighting with ESC
keymap("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", default_opts)

-- Move selected line / block of text in visual mode
keymap("x", "K", ":move '<-2<CR>gv-gv", default_opts)
keymap("x", "J", ":move '>+1<CR>gv-gv", default_opts)

-- Resizing panes
-- keymap("n", "<Left>", ":vertical resize +1<CR>", default_opts)
-- keymap("n", "<Right>", ":vertical resize -1<CR>", default_opts)
-- keymap("n", "<Up>", ":resize -1<CR>", default_opts)
-- keymap("n", "<Down>", ":resize +1<CR>", default_opts)

-- Insert blank line
keymap("n", "]<Space>", "o<Esc>", default_opts)
keymap("n", "[<Space>", "O<Esc>", default_opts)

-- Browser search
keymap("n", "gx", "<Plug>(openbrowser-smart-search)", default_opts)
keymap("x", "gx", "<Plug>(openbrowser-smart-search)", default_opts)

-- Some plugin keymaps
keymap("n", "<C-s>", ":Telescope lsp_document_symbols<CR>", default_opts)
keymap("n", "<leader>g", ":Telescope live_grep_args<CR>", default_opts)

keymap("n", "<leader>sf", require('fzf-lua').files, { desc = "[S]earch [F]iles " } )
keymap("n", "<leader>sr", require('fzf-lua').resume, { desc = "[S]earch [R]esume" } )
keymap("n", "<leader>sb", require('fzf-lua').buffers, { desc = "[S]earch [B]uffers" } )
keymap("n", "<leader>sq", require('fzf-lua').quickfix, { desc = "[S]earch [Q]uickfix" } )
keymap("n", "<leader>sl", require('fzf-lua').lines, { desc = "[S]search [L]ines in buffer" } )
keymap("n", "<leader>sg", require('fzf-lua').live_grep, { desc = "[S]earch [G]rep in project" } )

--vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })

-- keymaps for lsp
keymap("n", 'gd', require('fzf-lua').lsp_definitions, { desc = 'LSP - [G]oto [D]efinition' } )
keymap("n", 'gr', require('fzf-lua').lsp_references, { desc = 'LSP - [G]oto [R]eferences' } )
keymap("n", 'gI', require('fzf-lua').lsp_implementations,{ desc = 'LSP - [G]oto [I]mplementation' } )
-- nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
keymap("n", '<leader>ds', require('telescope.builtin').lsp_document_symbols, { desc = '[D]ocument [S]ymbols' } )
-- nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
keymap("n", "<leader>ds", require('fzf-lua').lsp_document_symbols, { desc = "LSP - [D]ocument [S]ymbols" } )
keymap("n", "<leader>ws", require('fzf-lua').lsp_workspace_symbols, { desc = "LSP - [W]orkspace [S]ymbols" } )
keymap("n", "<leader>wd", require('fzf-lua').lsp_workspace_diagnostics, { desc = "LSP - LSP : [W]orkspace [D]iagnostics" } )
