return {
  "MunifTanjim/nui.nvim",
  "grapp-dev/nui-components.nvim",

  "echasnovski/mini.icons",
  { "lewis6991/satellite.nvim", opts = {} },
  -- mini plugins
  { "echasnovski/mini.indentscope", version = false, opts = {} },
  { "echasnovski/mini.cursorword", version = false, opts = {} },
  { "echasnovski/mini.doc", version = false, opts = {} },
  -- git plugins
  { "lewis6991/gitsigns.nvim", opts = {} },

  { "tzachar/cmp-ai", dependencies = "nvim-lua/plenary.nvim" },
  { "hrsh7th/nvim-cmp", dependencies = { "tzachar/cmp-ai" } },
}
