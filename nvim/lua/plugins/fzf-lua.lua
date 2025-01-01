return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("fzf-lua").setup({
      { "default-title" }, -- base profile
      desc = "match telescope default highlights|keybinds",
      -- fzf_opts   = { ["--layout"] = "default", ["--marker"] = "+" },
      winopts = { row = 1, col = 0, split = "belowright new" },
      keymap = {
        fzf = {
          ["ctrl-q"] = "select-all+accept",
        },
      },
    })
  end,
}
