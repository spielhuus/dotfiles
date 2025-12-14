return {
	-- "spielhuus/lungan",
	name = "lungan",
	dir = "~/github/lungan",
	enabled = true,
	config = function()
		require("lungan.nvim").setup({
			model = "tinyllama",
			host = "127.0.0.1",
			port = "11434",
		})
		-- vim.keymap.set("n", "<leader>ms", "<cmd>Llama Model<cr>", { desc = "[M]odel [S]elect " })
		vim.keymap.set("n", "<leader>wc", "<cmd>Workbench Chat<cr>", { desc = "[W]orkbench [C]hat " })
		vim.keymap.set("v", "<leader>wc", ":Workbench Chatcr>", { desc = "[W]orkbench [C]hat " })
		-- vim.keymap.set("n", "<leader>mr", "<cmd>Llama Chat<cr>", { desc = "[M]odel [R]un " })
		-- vim.keymap.set("v", "<leader>mr", "<cmd>'<,'>Llama Chat<cr>", { desc = "[M]odel [R]un " })
	end,
}
