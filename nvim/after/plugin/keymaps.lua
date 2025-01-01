-- Map leader to space
vim.g.mapleader = " "

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
-- keymap("n", "<C-s>", ":Telescope lsp_document_symbols<CR>", default_opts)
keymap("n", "<leader>g", ":Telescope live_grep_args<CR>", default_opts)

-- See `:help telescope.builtin`
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>sp", "<cmd>Telescope repo<cr>", { desc = "[S]earch for [R]epositories" })

-- set the DAP keymaps
vim.keymap.set(
  "n",
  "<leader>db",
  require("dap").toggle_breakpoint,
  { noremap = true, desc = "[D]ebug toggle [B]reakpoint" }
)
vim.keymap.set("n", "<leader>dc", require("dap").continue, { noremap = true, desc = "[D]ebug [C]ontinue" })
vim.keymap.set("n", "<leader>do", require("dap").step_over, { noremap = true, desc = "[D]ebug step [O]ver" })
vim.keymap.set("n", "<leader>di", require("dap").step_into, { noremap = true, desc = "[D]ebug step [I]nto" })
vim.keymap.set("n", "<leader>dr", require("osv").run_this, { noremap = true, desc = "[D]ebug [R]un" })

vim.keymap.set("n", "<leader>dl", function()
  require("osv").launch({ port = 8086 })
end, { noremap = true, desc = "[D]ebug [L]aunch server" })

vim.keymap.set("n", "<leader>dw", function()
  local widgets = require("dap.ui.widgets")
  widgets.hover()
end)

vim.keymap.set("n", "<leader>df", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.frames)
end)

-- keymap("n", "<leader>sf", require('fzf-lua').files, { desc = "[S]earch [F]iles " } )
-- keymap("n", "<leader>sr", require('fzf-lua').resume, { desc = "[S]earch [R]esume" } )
-- keymap("n", "<leader>sb", require('fzf-lua').buffers, { desc = "[S]earch [B]uffers" } )
-- keymap("n", "<leader>sq", require('fzf-lua').quickfix, { desc = "[S]earch [Q]uickfix" } )
-- keymap("n", "<leader>sl", require('fzf-lua').lines, { desc = "[S]search [L]ines in buffer" } )
-- keymap("n", "<leader>sg", require('fzf-lua').live_grep, { desc = "[S]earch [G]rep in project" } )

-- keymap("n", "<leader>ms", require('gen').select_model, { desc = "[M]odel [S]elect " } )
-- keymap("v", "<leader>mr", ":'<,'>Gen Review_Code<CR>", { desc = "[M]odel [R]eview Code " } )

--vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })

-- keymaps for codecompanion
-- vim.api.nvim_set_keymap("n", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<LocalLeader>a", "<cmd>CodeCompanionToggle<cr>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "<LocalLeader>a", "<cmd>CodeCompanionToggle<cr>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "ga", "<cmd>CodeCompanionAdd<cr>", { noremap = true, silent = true })
