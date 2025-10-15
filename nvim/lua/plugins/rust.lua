-- vim.g.rustaceanvim = function()
-- 	return {
-- 		-- other rustacean settings. --
-- 		server = {
-- 			on_attach = function(client, bufnr)
-- 				local nmap = function(keys, func, desc)
-- 					if desc then
-- 						desc = "LSP: " .. desc
-- 					end
--
-- 					vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
-- 				end
--
-- 				vim.keymap.set("n", "gd", function()
-- 					require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
-- 				end, { desc = "LSP - [G]oto [D]efinition" })
-- 				vim.keymap.set("n", "gr", function()
-- 					require("fzf-lua").lsp_references({ jump_to_single_result = true })
-- 				end, { desc = "LSP - [G]oto [R]eferences" })
-- 				vim.keymap.set("n", "gI", function()
-- 					require("fzf-lua").lsp_implementations({ jump_to_single_result = true })
-- 				end, { desc = "LSP - [G]oto [I]mplementation" })
-- 				vim.keymap.set(
-- 					"n",
-- 					"<leader>ds",
-- 					require("fzf-lua").lsp_document_symbols,
-- 					{ desc = "LSP - [D]ocument [S]ymbols" }
-- 				)
-- 				vim.keymap.set(
-- 					"n",
-- 					"<leader>ws",
-- 					require("fzf-lua").lsp_workspace_symbols,
-- 					{ desc = "LSP - [W]orkspace [S]ymbols" }
-- 				)
-- 				vim.keymap.set(
-- 					"n",
-- 					"<leader>wd",
-- 					require("fzf-lua").lsp_workspace_diagnostics,
-- 					{ desc = "LSP - LSP : [W]orkspace [D]iagnostics" }
-- 				)
-- 				vim.keymap.set("n", "<leader>h", function()
-- 					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
-- 				end)
-- 				vim.keymap.set("n", "ca", function()
-- 					vim.cmd.RustLsp("codeAction")
-- 				end, { buffer = bufnr })
-- 				vim.keymap.set("n", "rd", function()
-- 					vim.cmd.RustLsp("renderDiagnostic")
-- 				end, { buffer = bufnr })
-- 				vim.keymap.set(
-- 					"n",
-- 					"[d",
-- 					vim.diagnostic.goto_prev,
-- 					{ desc = "LSP: go to previous diagnostic.", buffer = bufnr }
-- 				)
-- 				vim.keymap.set("n", "[e", function()
-- 					vim.diagnostic.goto_prev({
-- 						severity = vim.diagnostic.severity.ERROR,
-- 						wrap = true,
-- 					})
-- 				end, { desc = "LSP go to previous error diagnostic.", buffer = bufnr })
-- 				vim.keymap.set(
-- 					"n",
-- 					"]d",
-- 					vim.diagnostic.goto_next,
-- 					{ desc = "LSP go to next diagnostic.", buffer = bufnr }
-- 				)
-- 				vim.keymap.set("n", "]e", function()
-- 					vim.diagnostic.goto_next({
-- 						severity = vim.diagnostic.severity.ERROR,
-- 						wrap = true,
-- 					})
-- 				end, { desc = "LSP go to next error diagnostic.", buffer = bufnr })
-- 				vim.keymap.set(
-- 					"n",
-- 					"<C-k>",
-- 					vim.lsp.buf.signature_help,
-- 					{ desc = "LSP signature help.", buffer = bufnr }
-- 				)
-- 				vim.keymap.set(
-- 					"n",
-- 					"<leader>rn",
-- 					vim.lsp.buf.rename,
-- 					{ desc = "LSP [R]ena[m]e symbol under cusror.", buffer = bufnr }
-- 				)
-- 				vim.keymap.set(
-- 					"n",
-- 					"<leader>e",
-- 					vim.diagnostic.open_float,
-- 					{ desc = "LSP open diagnostic as floating window.", buffer = bufnr }
-- 				)
-- 				vim.keymap.set(
-- 					"n",
-- 					"<leader>f",
-- 					"<cmd>RustFmt<cr>",
-- 					{ desc = "LSP [f]ormat document.", buffer = bufnr }
-- 				)
-- 			end,
--
-- 			default_settings = {
-- 				-- rust-analyzer language server configuration
-- 				["rust-analyzer"] = {
-- 					cargo = {
-- 						allFeatures = true,
-- 						loadOutDirsFromCheck = true,
-- 						runBuildScripts = true,
-- 					},
-- 					-- Add clippy lints for Rust.
-- 					checkOnSave = {
-- 						allFeatures = true,
-- 						command = "clippy",
-- 						extraArgs = { "--no-deps" },
-- 					},
-- 					procMacro = {
-- 						enable = true,
-- 						ignored = {
-- 							["async-trait"] = { "async_trait" },
-- 							["napi-derive"] = { "napi" },
-- 							["async-recursion"] = { "async_recursion" },
-- 						},
-- 					},
-- 					diagnostics = {
-- 						enable = true,
-- 					},
-- 					inlayHints = {
-- 						lifetimeElisionHints = {
-- 							enable = true,
-- 							useParameterNames = true,
-- 						},
-- 					},
-- 				},
-- 			},
-- 		},
-- 	}
-- end

vim.g.rustaceanvim = function()
      return {
        -- Plugin configuration
        tools = {
        },
        -- LSP configuration
        server = {
                on_attach = function(client, bufnr)
                        -- you can also put keymaps in here
                end,
                default_settings = {
                        -- rust-analyzer language server configuration
                        ['rust-analyzer'] = {
                                cargo = {
                                        allTargets = true,
                                        allFeatures = true,
                                },
                                check = {
                                        command = "clippy",
                                },
                                procMacro = {
                                        enable = true,
                                },
                                diagnostics = {
                                        enable = false,
                                },
                        },
                },
        },

        -- DAP configuration
        dap = {
          adapter = require('rustaceanvim.config').get_codelldb_adapter('/usr/bin/codelldb', '/usr/lib/codelldb/lldb/lib/liblldb.so');
        },
}
end

-- set some vim diagnostic options
-- vim.diagnostic.config({
-- 	virtual_lines = true,
-- 	virtual_text = {
-- 		source = true,
-- 		prefix = "■",
-- 	},
-- 	-- virtual_text = false,
-- 	float = {
-- 		source = true,
-- 		border = "rounded",
-- 	},
-- 	signs = true,
-- 	underline = false,
-- 	update_in_insert = false,
-- 	severity_sort = true,
-- })

return {
        {
                "mrcjkb/rustaceanvim",
                enabled = true,
                lazy = false,
                version = "^6",
        },
        {
                "saecki/crates.nvim",
                tag = "stable",
                event = { "BufRead Cargo.toml" },
                dependencies = {
                        "nvim-lua/plenary.nvim",
                },
                config = function()
                        require("crates").setup()
                end,
        },
}
