return {
	"saghen/blink.cmp",
	enabled = true,
	-- optional: provides snippets for the snippet source
	dependencies = { "rafamadriz/friendly-snippets", "lungan" },
	version = "*",
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = { preset = "super-tab" },
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},
		sources = {
			default = { "lazydev", "models", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					-- make lazydev completions top priority (see `:h blink.cmp`)
					score_offset = 100,
				},
				models = {
					name = "Models",
					module = "lungan.nvim.cmp.blink.frontmatter",
					score_offset = 100,
				},
			},
		},
	},
	opts_extend = { "sources.default" },
}
