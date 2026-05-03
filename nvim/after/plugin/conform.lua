require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black" },
		rust = { "rustfmt", lsp_format = "fallback" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier" },
	},
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true }, function(err, did_edit)
		-- if not err and did_edit then
		-- 	vim.notify("Code formatted", vim.log.levels.INFO, { title = "Conform" })
		-- end
	end)
end, { desc = "Format buffer" })
