return {
	"rcarriga/nvim-dap-ui",
	enabled = false,
	dependencies = {},
	keys = {
		{
			"<leader>du",
			function()
				require("dapui").toggle()
			end,
			silent = true,
		},
	},
	opts = {
		icons = { expanded = "", collapsed = "󰘕", circular = "Ⓢ" },
		mappings = {
			expand = { "<CR>", "<2-LeftMouse>" },
			open = "o",
			remove = "d",
			edit = "e",
			repl = "r",
			toggle = "t",
		},
		layouts = {
			{
				elements = {
					{ id = "repl", size = 0.30 },
					{ id = "console", size = 0.70 },
				},
				size = 0.19,
				position = "bottom",
			},
			{
				elements = {
					{ id = "scopes", size = 0.30 },
					{ id = "breakpoints", size = 0.20 },
					{ id = "stacks", size = 0.10 },
					{ id = "watches", size = 0.30 },
				},
				size = 0.20,
				position = "right",
			},
		},
		controls = {
			enabled = true,
			element = "repl",
			icons = {
				pause = "",
				play = "",
				step_into = "󰆹",
				step_over = " ",
				step_out = "",
				step_back = "",
				run_last = "",
				terminate = "",
			},
		},
		floating = {
			max_height = 0.9,
			max_width = 0.5,
			border = vim.g.border_chars,
			mappings = {
				close = { "q", "<Esc>" },
			},
		},
	},
	config = function(_, opts)
		require("dapui").setup(opts)

		-- require("which-key").register({
		--   d = {
		--     name = "Debug", -- optional group name
		--     u = { function() require("dapui").toggle() end, "Debug [U]I" },
		--   },
		-- }, { prefix = "<leader>" }
		-- )
	end,
}
