return ({
  'spielhuus/elektron-nvim',
  enabled = false,
  config = function()
    require('elektron').setup()
  end,
})
