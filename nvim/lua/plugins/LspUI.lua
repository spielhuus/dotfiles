return ({
  "jinzhongjia/LspUI.nvim",
  enable = false,
  branch = "legacy",
  config = function()
    require("LspUI").setup({
      prompt = false,
      -- config options go here
    })
  end
})
