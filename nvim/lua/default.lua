local g = vim.g
local opt = vim.opt

-- disable netrw for other filemanager
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Remap leader and local leader to <Space>
vim.keymap.set("", "<Space>", "<Nop>", { noremap = true, silent = true })
g.mapleader = " "
-- g.vimsyn_embed = "lPr" -- Syntax embedding for Lua, Python and Ruby
--
opt.title = true
opt.termguicolors = true -- Enable colors in terminal
opt.hlsearch = true --Set highlight on search
opt.number = true --Make line numbers default
opt.relativenumber = true --Make relative number default-
-- -- opt.breakindent = true --Enable break indent
opt.undofile = true --Save undo history
opt.ignorecase = true --Case insensitive searching unless /C or capital in search
opt.smartcase = true -- Smart case
-- opt.updatetime = 250 --Decrease update time
opt.clipboard = "unnamedplus" -- Access system clipboard
-- opt.timeoutlen = 300 --	Time in milliseconds to wait for a mapped sequence to complete.
-- opt.showmode = false -- Do not need to show the mode. We use the statusline instead.
-- opt.scrolloff = 8 -- Lines of context
-- opt.joinspaces = false -- No double spaces with join after a dot
-- opt.sessionoptions = "buffers,curdir,help,tabpages,winsize,winpos,terminal"
opt.smartindent = true --Smart indent
opt.expandtab = true
opt.smarttab = true
-- opt.textwidth = 0
-- opt.autoindent = true
-- opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
-- opt.splitbelow = true
-- opt.splitright = true
-- opt.laststatus = 3 -- Global statusline
-- opt.cmdheight = 0
-- opt.scrollback = 100000
--
-- -- go to previous/next line with h,l,left arrow and right arrow when cursor reaches end/beginning of line
-- opt.whichwrap:append("<>[]hl")
--
-- -- disable nvim intro
-- opt.shortmess:append("sI")
--
-- -- Better search
-- opt.path:remove("/usr/include")
-- opt.path:append("**")
-- -- vim.cmd [[set path=.,,,$PWD/**]] -- Set the path directly
--
-- opt.wildignorecase = true
-- opt.wildignore:append("**/node_modules/*")
-- opt.wildignore:append("**/.git/*")
--
-- -- Treesitter based folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- -- vim.opt.foldcolumn = "0"
-- vim.opt.foldtext = ""
-- vim.opt.foldlevel = 99
-- -- vim.opt.foldlevelstart = 1
-- vim.opt.foldnestmax = 2

-- opt.foldlevel = 20
-- opt.foldmethod = "expr"
-- opt.foldexpr = "nvim_treesitter#foldexpr()"
--
-- opt.foldcolumn = "1"
-- opt.foldlevel = 99
-- opt.foldlevelstart = -1
-- opt.foldenable = true

-- GUI
-- opt.guifont = "Fira_Code:h14"
--

-- icons for diagnostic errors:
-- vim.fn.sign_define("DiagnosticSignError",
--   { text = " ", texthl = "DiagnosticSignError" })
-- vim.fn.sign_define("DiagnosticSignWarn",
--   { text = " ", texthl = "DiagnosticSignWarn" })
-- vim.fn.sign_define("DiagnosticSignInfo",
--   { text = " ", texthl = "DiagnosticSignInfo" })
-- vim.fn.sign_define("DiagnosticSignHint",
--   { text = "", texthl = "DiagnosticSignHint" })

local transparent_highlights = {
  "Normal",
  "NormalNC",
  "LineNr",
  "Folded",
  "NonText",
  "SpecialKey",
  "VertSplit",
  "SignColumn",
  "EndOfBuffer",
  "TablineFill", -- this might be preference
}

for _, hl in ipairs(transparent_highlights) do
  vim.cmd.highlight(hl .. " guibg=NONE ctermbg=NONE")
end
