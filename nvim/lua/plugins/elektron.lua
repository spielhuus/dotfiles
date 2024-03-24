return ({
  'spielhuus/elektron-nvim',
  enabled = true,
  config = function()
    require('elektron').setup()
  end,
})
