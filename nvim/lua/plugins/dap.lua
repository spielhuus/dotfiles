return({
  "mfussenegger/nvim-dap",
  enabled = true,
  dependencies = {
    'rcarriga/nvim-dap-ui',
  },
  conf = function ()
    require("neodev").setup({
      library = { plugins = { "nvim-dap-ui" }, types = true },
    })
    local dap, dapui = require("dap"), require("dapui")
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
  end
})
