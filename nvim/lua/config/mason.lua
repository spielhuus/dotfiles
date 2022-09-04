local M = {}

function M.setup()
	require("mason").setup()
	require("mason-lspconfig").setup({
	    ensure_installed = { "sumneko_lua", "rust_analyzer", "bashls", "clangd", "cmake", "cssls", "dockerls", "eslint", "html", "tsserver", "texlab", "r_language_server" },
	    automatic_installation = true,
	})
  require'mason-tool-installer'.setup {

    -- a list of all tools you want to ensure are installed upon
    -- start; they should be the names Mason uses for each tool
    ensure_installed = {

        'shellcheck',
        'codelldb',

    },
    auto_update = false,
    run_on_start = true,
    start_delay = 3000  -- 3 second delay
}

end

return M
