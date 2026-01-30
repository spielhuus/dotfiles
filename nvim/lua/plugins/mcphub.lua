return ({
  "ravitemer/mcphub.nvim",
  enabled = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  build = "npm install mcp-hub@latest", -- Installs `mcp-hub` node binary globally
  config = function()
    require("mcphub").setup()
  end
})
