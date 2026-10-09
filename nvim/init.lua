vim.cmd([[colorscheme catppuccin]])
require("config")
require("keymaps")

-- vim.api.nvim_create_autocmd('PackChanged', { callback = function(ev)
--   local name, kind = ev.data.spec.name, ev.data.kind
--   print("PackChanged: " .. name .. ", kind: " .. kind)
--
--   if name == 'fzf-lua' and kind == 'update' then
--     if not ev.data.active then vim.cmd.packadd('fzf-lua') end
--     vim.cmd('make install_jsregexp')
--   end
--
--   if name == 'blink.cmp' and kind == 'install' then
--     if not ev.data.active then vim.cmd.packadd('blink.cmp') end
--     print('RUN: cargo build --release')
--     vim.cmd('!cargo build --release')
--   end
--
--   if name == 'nvim-treesitter' and kind == 'install' then
--     if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
--     vim.cmd('TSUpdate')
--   end
-- end })


vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/saghen/blink.lib" },
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/mrcjkb/rustaceanvim" },
  { src = "https://github.com/nwiizo/cargo.nvim" },
  { src = "https://github.com/saecki/crates.nvim" },
	{ src = "https://github.com/mbbill/undotree" },
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	-- { src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/igorlfs/nvim-dap-view" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	-- { src = "https://github.com/brenton-leighton/multiple-cursors.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/neogitorg/neogit"},
  { src = "https://github.com/nvim-lua/plenary.nvim"},
	-- { src = "https://github.com/spielhuus/lungan-rs" },
  -- { src = "https://github.com/t-troebst/perfanno.nvim" },
})

vim.opt.rtp:append("/home/etienne/github/lungan-rs")

require("mason").setup()

vim.lsp.enable({
	"clangd",
	"wgsl_analyzer",
	"lua_ls",
	"ts_ls",
	"bash_ls",
	"html_ls",
	"python_ls",
	-- "cspell_ls",
	"ltex",
})

vim.api.nvim_create_autocmd("LspProgress", {
    callback = function(ev)
        local value = ev.data.params.value or {}
        if not value.kind then return end

        local status = value.kind == "end" and 0 or 1
        local percent = value.percentage or 0

        local osc_seq = string.format("\27]9;4;%d;%d\a", status, percent)

        if os.getenv("TMUX") then
            osc_seq = string.format("\27Ptmux;\27%s\27\\", osc_seq)
        end

        io.stdout:write(osc_seq)
        io.stdout:flush()
    end,
})
