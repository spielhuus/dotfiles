return({
  "otavioschwanck/arrow.nvim",
  enabled = false,
  config = function()
    require("arrow").setup()
  end,
  opts = {
    show_icons = true,
    leader_key = ';', -- Recommended to be a single key
    buffer_leader_key = 'm', -- Per Buffer Mappings
  }
})
