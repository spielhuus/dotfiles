-- Map leader to space
vim.g.mapleader = " "

-- local keymap = vim.api.nvim_set_keymap
local keymap = vim.keymap.set
local default_opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, expr = true, silent = true }

-- Center search results
keymap("n", "n", "nzz", default_opts)
keymap("n", "N", "Nzz", default_opts)

-- Switch buffers
keymap("n", "<C-l>", "<cmd>bnext<CR>", default_opts)
keymap("n", "<C-h>", "<cmd>bprev<CR>", default_opts)

-- trigger autocomletion
keymap('i', '<c-space>', function() vim.lsp.completion.get() end)

-- Visual line wraps
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", expr_opts)
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", expr_opts)

-- Better indent
keymap("v", "<", "<gv", default_opts)
keymap("v", ">", ">gv", default_opts)

-- Paste over currently selected text without yanking it
keymap("v", "p", '"_dP', default_opts)

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

-- set the DAP keymaps
-- vim.keymap.set(
-- 	"n",
-- 	"<leader>db",
-- 	require("dap").toggle_breakpoint,
-- 	{ noremap = true, desc = "[D]ebug toggle [B]reakpoint" }
-- )
-- vim.keymap.set("n", "<leader>dc", require("dap").continue, { noremap = true, desc = "[D]ebug [C]ontinue" })
-- vim.keymap.set("n", "<leader>do", require("dap").step_over, { noremap = true, desc = "[D]ebug step [O]ver" })
-- vim.keymap.set("n", "<leader>di", require("dap").step_into, { noremap = true, desc = "[D]ebug step [I]nto" })
-- -- vim.keymap.set("n", "<leader>dr", require("osv").run_this, { noremap = true, desc = "[D]ebug [R]un" })
--
-- vim.keymap.set("n", "<leader>dl", function()
-- 	require("osv").launch({ port = 8086 })
-- end, { noremap = true, desc = "[D]ebug [L]aunch server" })
--
-- vim.keymap.set("n", "<leader>dw", function()
-- 	local widgets = require("dap.ui.widgets")
-- 	widgets.hover()
-- end)
--
-- vim.keymap.set("n", "<leader>df", function()
-- 	local widgets = require("dap.ui.widgets")
-- 	widgets.centered_float(widgets.frames)
-- end, { noremap = true, desc = "[D]apUI Widgets" })

local diagnostics_active = true
vim.keymap.set('n', '<leader>d', function()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.show()
  else
    vim.diagnostic.hide()
  end
end)
