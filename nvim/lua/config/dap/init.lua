local M = {}

local function configure()

  local dap_breakpoint = {
    error = {
      text = "🟥",
      texthl = "LspDiagnosticsSignError",
      linehl = "",
      numhl = "",
    },
    rejected = {
      text = "",
      texthl = "LspDiagnosticsSignHint",
      linehl = "",
      numhl = "",
    },
    stopped = {
      text = "⭐️",
      texthl = "LspDiagnosticsSignInformation",
      linehl = "DiagnosticUnderlineInfo",
      numhl = "LspDiagnosticsSignInformation",
    },
  }

  vim.fn.sign_define("DapBreakpoint", dap_breakpoint.error)
  vim.fn.sign_define("DapStopped", dap_breakpoint.stopped)
  vim.fn.sign_define("DapBreakpointRejected", dap_breakpoint.rejected)
end

local function configure_exts()
  require("nvim-dap-virtual-text").setup {
    commented = true,
  }

  local dap, dapui = require "dap", require "dapui"
  dapui.setup {} -- use default
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end

local function configure_debuggers()
  -- require("config.dap.lua").setup()
  -- require("config.dap.python").setup()
  -- require("config.dap.rust").setup()
  -- require("config.dap.go").setup()
  -- require("config.dap.csharp").setup()
  -- require("config.dap.kotlin").setup()
  -- require("config.dap.typescript").setup()
end

local function map_over()
  local dap = require('dap')
  local api = vim.api
  local keymap_restore = {}
  dap.listeners.after['event_initialized']['me'] = function()
    for _, buf in pairs(api.nvim_list_bufs()) do
      local keymaps = api.nvim_buf_get_keymap(buf, 'n')
      for _, keymap in pairs(keymaps) do
        if keymap.lhs == "K" then
          table.insert(keymap_restore, keymap)
          api.nvim_buf_del_keymap(buf, 'n', 'K')
        end
      end
    end
    api.nvim_set_keymap(
      'n', 'K', '<Cmd>lua require("dap.ui.widgets").hover()<CR>', { silent = true })
  end

  dap.listeners.after['event_terminated']['me'] = function()
    for _, keymap in pairs(keymap_restore) do
      api.nvim_buf_set_keymap(
        keymap.buffer,
        keymap.mode,
        keymap.lhs,
        keymap.rhs,
        { silent = keymap.silent == 1 }
      )
    end
    keymap_restore = {}
  end
end

local function configure_keymaps()
  vim.keymap.set('n', '<leader>ds', function() require('dap').step_over() end)
  vim.keymap.set('n', '<leader>dS', function() require('dap').step_into() end)
  vim.keymap.set('n', '<leader>dk', function() require('dap').continue() end)
  vim.keymap.set('n', '<leader>dl', function() require('dap').run_last() end)
  vim.keymap.set("n", "<C-b>", function() require('dap').toggle_breakpoint() end)
end

function M.setup()
  configure() -- Configuration
  configure_exts() -- Extensions
  configure_debuggers() -- Debugger
  -- map_over() -- Debugger
  configure_keymaps() -- Debugger
end

return M
