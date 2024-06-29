return({
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("fzf-lua").setup({
            winopts = { row = 1, col = 0, split = "belowright new" },
    })
  end
})
