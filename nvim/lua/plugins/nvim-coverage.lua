return {
	"andythigpen/nvim-coverage",
	version = "*",
  enabled = false,
	config = function()
		require("coverage").setup({
			auto_reload = true,
		})
	end,
}
