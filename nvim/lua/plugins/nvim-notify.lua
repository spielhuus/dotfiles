return {
	"rcarriga/nvim-notify",
	enabled = false,
	config = function()
		require("notify").setup({
			background_colour = "NotifyBackground",
			fps = 30,
			icons = {
				DEBUG = "",
				ERROR = "",
				INFO = "",
				TRACE = "✎",
				WARN = "",
			},
			level = 2,
			minimum_width = 50,
			render = "compact",
			stages = "slide",
			time_formats = {
				notification = "%T",
				notification_history = "%FT%T",
			},
			timeout = 5000,
			top_down = true,
			on_open = function(win)
				vim.api.nvim_win_set_config(win, { zindex = 200 })
			end,
		})
		vim.notify = require("notify")
	end,
}
