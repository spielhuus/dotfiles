local turbo = {}

local colors = require('turbo').colors()

bg = colors.lualine_bg_color

turbo.normal = {
  a = {fg = colors.white, bg = colors.gray, gui = 'bold'},
  b = {fg = colors.yellow, bg = bg},
  c = {fg = colors.white, bg = bg},
}

turbo.visual = {
  a = {fg = colors.black, bg = colors.blue, gui = 'bold'},
  b = {fg = colors.red, bg = bg},
}

turbo.inactive = {
  a = {fg = colors.white, bg = colors.bg, gui = 'bold'},
  b = {fg = colors.black, bg = colors.white},
}

turbo.replace = {
  a = {fg = colors.black, bg = colors.yellow, gui = 'bold'},
  b = {fg = colors.yellow, bg = bg},
  c = {fg = colors.white, bg = bg},
}

turbo.insert = {
  a = {fg = colors.black, bg = colors.green, gui = 'bold'},
  b = {fg = colors.visual, bg = bg},
  c = {fg = colors.white, bg = bg},
}

return turbo
