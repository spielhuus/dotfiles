return {
  "L3MON4D3/LuaSnip",
  dependencies = { "rafamadriz/friendly-snippets" },
  version = "v2.*",
  build = "make install_jsregexp",
  config = function()
    require("luasnip").filetype_extend("typescript", { "javascript" })
    require("luasnip.loaders.from_vscode").lazy_load()
  end,
}
