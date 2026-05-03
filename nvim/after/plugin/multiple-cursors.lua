require("multiple-cursors").setup()


local keymap = vim.keymap.set
 keymap({"n", "x"}, "<C-j>", "<Cmd>MultipleCursorsAddDown<CR>")
 keymap({"n", "x"}, "<C-k>", "<Cmd>MultipleCursorsAddUp<CR>")
 keymap({"n", "i", "x"}, "<C-Up>", "<Cmd>MultipleCursorsAddUp<CR>")
 keymap({"n", "i", "x"}, "<C-Down>", "<Cmd>MultipleCursorsAddDown<CR>")
 keymap({"n", "i"}, "<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>")
 keymap({"x"}, "<Leader>m", "<Cmd>MultipleCursorsAddVisualArea<CR>")
 keymap({"n", "x"}, "<C-n>", "<Cmd>MultipleCursorsAddMatches<CR>")
 keymap({"n", "x"}, "<Leader>A", "<Cmd>MultipleCursorsAddMatchesV<CR>")
 keymap({"n", "x"}, "<Leader>d", "<Cmd>MultipleCursorsAddJumpNextMatch<CR>")
 keymap({"n", "x"}, "<Leader>D", "<Cmd>MultipleCursorsJumpNextMatch<CR>")
 keymap({"n", "x"}, "<Leader>l", "<Cmd>MultipleCursorsLock<CR>")
