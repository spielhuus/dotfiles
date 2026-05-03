
-- Remap leader and local leader to <Space>
vim.keymap.set("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "

-- g.vimsyn_embed = "lPr" -- Syntax embedding for Lua, Python and Ruby

vim.opt.title = true
vim.opt.termguicolors = true -- Enable colors in terminal
vim.opt.relativenumber = true --Make relative number default-
vim.opt.clipboard = "unnamedplus" -- Access system clipboard
vim.opt.number = true --Make line numbers default
vim.opt.relativenumber = true --Make relative number default-
-- -- opt.breakindent = true --Enable break indent
vim.opt.undofile = true --Save undo history

vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.laststatus = 0 -- hide the statusline

local groups = { "Normal", "NormalNC", "Comment", "Constant", "Special", "Identifier", 
                 "Statement", "PreProc", "Type", "Underlined", "Todo", "String", 
                 "Function", "Conditional", "Repeat", "Operator", "Structure", 
                 "LineNr", "NonText", "SignColumn", "CursorLine", "CursorLineNr", 
                 "EndOfBuffer" }

for _, group in ipairs(groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
    if ok then
        local new_hl = vim.deepcopy(hl)
        new_hl.bg = "NONE"
        new_hl.ctermbg = "NONE"
        vim.api.nvim_set_hl(0, group, new_hl)
    end
end
