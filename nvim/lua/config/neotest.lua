local M = {}

function M.setup()
  require("neotest").setup {
    adapters = {
      require "neotest-python" {
        dap = { justMyCode = false },
        runner = "unittest",
      },
      require "neotest-plenary",
      require "neotest-rust",
    },
  }
end

return M
