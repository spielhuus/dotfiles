--vim.g.moonflyCursorColor = 1
--vim.g.moonflyNormalFloat = 1
--vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
--  vim.lsp.handlers.hover, {
--    border = 'single'
--  }
--)
--vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
--  vim.lsp.handlers.signatureHelp, {
--    border = 'single'
--  }
--)
--local opts = {noremap = true, silent = true}
--vim.api.nvim_buf_set_keymap(0, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next({severity_limit = "Warning", popup_opts = {border = "single"}})<CR>', opts)
--vim.api.nvim_buf_set_keymap(0, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev({severity_limit = "Warning", popup_opts = {border = "single"}})<CR>', opts)
--vim.g.moonflyTransparent = 0
--vim.g.moonflyUnderlineMatchParen = 1
--vim.g.moonflyWinSeparator = 2

--vim.cmd [[colorscheme moonfly]]


--vim.g.dracula_colors = {
--  bg = "#000000",
--  fg = "#F8F8F2",
----  selection = "#FF0000",
----  comment = "#6272A4",
----  red = "#FF5555",
----  orange = "#FFB86C",
--d  yellow = "#0000FF",
----  green = "#50fa7b",
----  purple = "#BD93F9",
----  cyan = "#8BE9FD",
----  pink = "#FF79C6",
----  bright_red = "#FF6E6E",
----  bright_green = "#69FF94",
--    bright_yellow = "#0000FF",
----  bright_blue = "#D6ACFF",
----  bright_magenta = "#FF92DF",
----  bright_cyan = "#A4FFFF",
----  bright_white = "#FFFFFF",
----  menu = "#21222C",
---- visual = "#AAAAAA",
----  gutter_fg = "#4B5263",
--    gutter_fg = "#00FF00",
----  nontext = "#3B4048",
--}
---- show the '~' characters after the end of buffers
--vim.g.dracula_show_end_of_buffer = true
---- use transparent background
--vim.g.dracula_transparent_bg = true
---- set custom lualine background color
--vim.g.dracula_lualine_bg_color = "#FF0000"
---- set italic comment
--vim.g.dracula_italic_comment = true
--vim.cmd[[colorscheme dracula]]
--


-- vim.cmd[[colorscheme codedark]]


vim.cmd [[colorscheme moonfly]]
vim.g.moonflyTransparent = 1
