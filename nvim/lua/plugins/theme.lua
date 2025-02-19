return {
	"catppuccin/nvim",
	enabled = true,
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			transparent_background = true,
			show_end_of_buffer = true,
			dim_inactive = {
				enabled = false, -- dims the background color of inactive window
				shade = "dark",
				percentage = 0.15, -- percentage of the shade to apply to the inactive window
			},
		})
		vim.cmd("colorscheme catppuccin")
	end,
}
