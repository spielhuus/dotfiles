return ({
  'mfussenegger/nvim-lint',
  enabled = false,
  config = function()
    require('lint').linters_by_ft = {
      make = { 'checkmake', },
      markdown = { 'vale', },
    }
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })
  end
})
