require("snacks").setup({
	bigfile = { enabled = false },
	dashboard = {
		enabled = false,
	},
	explorer = { enabled = false },
	indent = { enabled = false },
	input = { enabled = false },
	notifier = {
		enabled = true,
		timeout = 3000,
	},
	picker = { enabled = true, layout = { preset = "ivy", layout = { position = "bottom" } } },
	quickfile = { enabled = false },
	scope = { enabled = false },
	scroll = { enabled = false },
	statuscolumn = { enabled = false },
	words = { enabled = false },
	styles = {
		notification = {
			-- wo = { wrap = true } -- Wrap notifications
		},
	},
})
