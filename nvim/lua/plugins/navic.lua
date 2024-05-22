return({
  "SmiteshP/nvim-navic",
  enabled = true,
  opts = {

            lsp = {
              auto_attach = true,
              preference = nil,
            },
            highlight = true,
            separator = " > ",
            depth_limit = 0,
            depth_limit_indicator = "..",
            safe_output = true,
            lazy_update_context = false,
            click = true,
  }
})
