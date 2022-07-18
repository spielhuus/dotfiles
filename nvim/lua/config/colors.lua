vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signatureHelp, {
    border = 'none'
  }
)
vim.g.turbo_show_end_of_buffer = true
-- use transparent background
vim.g.turbo_transparent_bg = true
-- set custom lualine background color
-- vim.g.turbo_lualine_bg_color = "#44475a"
-- set italic comment
vim.g.turbo_italic_comment = true
vim.cmd[[colorscheme turbo]]
