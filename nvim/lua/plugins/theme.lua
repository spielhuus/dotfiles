return {
	{
		"Mofiqul/dracula.nvim",
		enabled = false,
		lazy = false,
		priority = 1000,
		config = function()
			local dracula = require("dracula")
			dracula.setup({
				-- customize dracula color palette
				colors = {
					bg = "#282A36",
					fg = "#F8F8F2",
					selection = "#44475A",
					comment = "#6272A4",
					red = "#FF5555",
					orange = "#FFB86C",
					yellow = "#F1FA8C",
					green = "#50fa7b",
					purple = "#BD93F9",
					cyan = "#8BE9FD",
					pink = "#FF79C6",
					bright_red = "#FF6E6E",
					bright_green = "#69FF94",
					bright_yellow = "#FFFFA5",
					bright_blue = "#D6ACFF",
					bright_magenta = "#FF92DF",
					bright_cyan = "#A4FFFF",
					bright_white = "#FFFFFF",
					menu = "#21222C",
					visual = "#3E4452",
					gutter_fg = "#4B5263",
					nontext = "#3B4048",
				},
				-- show the '~' characters after the end of buffers
				show_end_of_buffer = true, -- default false
				-- use transparent background
				transparent_bg = true, -- default false
				-- set custom lualine background color
				lualine_bg_color = "#000000", -- "#44475a", -- default nil
				-- set italic comment
				italic_comment = true, -- default false
				-- overrides the default highlights see `:h synIDattr`
				overrides = {
					-- Examples
					-- NonText = { fg = dracula.colors().white }, -- set NonText fg to white
					-- NvimTreeIndentMarker = { link = "NonText" }, -- link to NonText highlight
					-- Nothing = {} -- clear highlight of Nothing
				},
			})
			vim.cmd([[colorscheme dracula]])
		end,

		--  -- Theme inspired by Atom
		--  'navarasu/onedark.nvim',
		--  priority = 1000,
		--  lazy = false,
		--  config = function()
		--    require('onedark').setup {
		--      -- Set a style preset. 'dark' is default.
		--      style = 'darker', -- dark, darker, cool, deep, warm, warmer, light
		--    }
		--    require('onedark').load()
		--  end,
	},
	-- {
	--         dir = "/home/etienne/.dotfiles/nvim/zenbones.nvim",
	--         enabled = true,
	--         dependencies = {
	--                 "rktjmp/lush.nvim"
	--         },
	--         config = function()
	--                 vim.g.zenbones_solid_line_nr = true
	--                 vim.g.zenbones_darken_comments = 45
	--                 vim.g.zenbones_transparent_background = true
	--                 vim.g.zenbones_darkness = 'stark'
	--                 vim.g.zenbones_solid_float_border = true
	--                 vim.g.zenbones_darken_noncurrent_window = true
	--                 vim.g.zenbones_darken_line_nr = 100
	--
	--                 vim.g.zenwritten_solid_line_nr = true
	--                 vim.g.zenwritten_darken_comments = 45
	--                 vim.g.zenwritten_transparent_background = true
	--                 vim.g.zenwritten_darkness = 'stark'
	--                 vim.g.zenwritten_solid_float_border = true
	--                 vim.g.zenwritten_darken_noncurrent_window = true
	--                 vim.g.zenwritten_darken_line_nr = 100
	--
	--                 vim.g.neoboorland_transparent_background = true
	--                 vim.g.neoboorland_darken_comments = 45
	--                 vim.g.neoboorland_darkness = 'stark'
	--                 vim.g.neoboorland_solid_float_border = true
	--                 vim.g.neoboorland_darken_noncurrent_window = true
	--                 vim.g.neoboorland_darken_line_nr = 100
	--
	--                 vim.cmd 'colorscheme neoboorland'
	--         end
	-- },
	{
		{
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
		},
	},
}
