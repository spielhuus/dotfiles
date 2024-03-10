return ({
  "jinzhongjia/LspUI.nvim",
  branch = "legacy",
  config = function()
    require("LspUI").setup({
      prompt = false,
      -- config options go here
    })
  end
})
