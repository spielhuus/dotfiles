return {
	{
		"folke/lazydev.nvim",
		enabled = true,
		dependencies = {
			{ "LuaCATS/luassert", name = "luassert-types" },
			{ "LuaCATS/busted", name = "busted-types" },
		},
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
				{ path = "wezterm-types", mods = { "wezterm" } },
				{ path = "luassert-types/library", words = { "assert" } },
				{ path = "busted-types/library", words = { "describe" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
}
