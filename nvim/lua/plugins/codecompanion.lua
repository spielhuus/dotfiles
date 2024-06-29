return ({
        "olimorris/codecompanion.nvim",
        enabled = true,
        opts = {
                strategies = {
                        chat = "ollama",
                        inline = "ollama",
                        tools = "ollama",
                },


        },
        dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-treesitter/nvim-treesitter",
                "nvim-telescope/telescope.nvim", -- Optional
                {
                        "stevearc/dressing.nvim", -- Optional: Improves the default Neovim UI
                        opts = {},
                },
        },
        config = true
})
