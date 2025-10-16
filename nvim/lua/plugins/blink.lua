return {
	"saghen/blink.cmp",
	enabled = true,
	-- optional: provides snippets for the snippet source
	dependencies = { "rafamadriz/friendly-snippets", "lungan" },
	version = "*",
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = { preset = "default" },
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},
		snippets = { preset = "luasnip" },
		completion = {
			-- 'prefix' will fuzzy match on the text before the cursor
			-- 'full' will fuzzy match on the text before _and_ after the cursor
			-- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
			keyword = { range = "full" },

			-- Disable auto brackets
			-- NOTE: some LSPs may add auto brackets themselves anyway
			accept = { auto_brackets = { enabled = false } },

			-- Don't select by default, auto insert on selection
			list = { selection = { preselect = false, auto_insert = true } },
			-- or set either per mode via a function
			list = { selection = {
				preselect = function(ctx)
					return ctx.mode ~= "cmdline"
				end,
			} },

			menu = {
				-- Don't automatically show the completion menu
				auto_show = false,

				-- nvim-cmp style menu
				draw = {
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind" },
					},
				},
			},

			-- Show documentation when selecting a completion item
			documentation = { auto_show = true, auto_show_delay_ms = 500 },

			-- Display a preview of the selected item on the current line
			ghost_text = { enabled = true },
		},
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
				-- models = {
				-- 	name = "Models",
				-- 	module = "lungan.nvim.cmp.blink.frontmatter",
				-- 	score_offset = 100,
				-- },
			},
		},
	},
	opts_extend = { "sources.default" },
}
