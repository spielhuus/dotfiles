return {
	"mfussenegger/nvim-dap",
	enabled = true,
	dependencies = {
		-- "rcarriga/nvim-dap-ui",
		"jbyuki/one-small-step-for-vimkind",
	},
	config = function()
		local dap = require("dap") --, require("dapui")
		-- local dap = require("dap")
		dap.configurations.lua = {
			{
				type = "nlua",
				request = "attach",
				name = "Attach to running Neovim instance",
			},
		}

-- dap.adapters.codelldb = {
--   type = 'server',
--    port = "${port}",
--    executable = {
--     command = '/usr/bin/codelldb',
--    args = {"--port", "${port}"},
--   }
-- }
-- dap.configurations.rust = {
--   {
--     name = "Rust debug",
--     type = "codelldb",
--     request = "launch",
--     program = function()
--       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
--     end,
--     cwd = '${workspaceFolder}',
--     stopOnEntry = true,
--   },
-- }
		-- configure neovim plugin debugging
		dap.adapters.nlua = function(callback, config)
			callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
		end

		-- dap.listeners.before.attach.dapui_config = function()
		-- 	dapui.open()
		-- end
		-- dap.listeners.before.launch.dapui_config = function()
		-- 	dapui.open()
		-- end
		-- dap.listeners.before.event_terminated.dapui_config = function()
		-- 	dapui.close()
		-- end
		-- dap.listeners.before.event_exited.dapui_config = function()
		-- 	dapui.close()
		-- end
	end,
}
