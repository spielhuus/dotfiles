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
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/mrcjkb/rustaceanvim" },
  { src = "https://github.com/nwiizo/cargo.nvim" },
  { src = "https://github.com/saecki/crates.nvim" },
	{ src = "https://github.com/mbbill/undotree" },
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/igorlfs/nvim-dap-view" },
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/brenton-leighton/multiple-cursors.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/neogitorg/neogit"},
  { src = "https://github.com/nvim-lua/plenary.nvim"},
	{ src = "https://github.com/spielhuus/lungan" },
})

require("mason").setup()

vim.lsp.enable({
	"clangd",
	"wgsl_analyzer",
	"lua_ls",
	"ts_ls",
	"bash_ls",
	"html_ls",
	"python_ls",
	"cspell_ls",
	"ltex",
})

require("autocommands")
require('vim._core.ui2').enable({
  enable = true, -- Whether to enable or disable the UI.
  msg = { -- Options related to the message module.
    ---@type 'cmd'|'msg' Default message target, either in the
    ---cmdline or in a separate ephemeral message window.
    ---@type string|table<string, 'cmd'|'msg'|'pager'> Default message target
    ---or table mapping |ui-messages| kinds and triggers to a target.
    targets = 'cmd',
    cmd = { -- Options related to messages in the cmdline window.
      height = 0.5 -- Maximum height while expanded for messages beyond 'cmdheight'.
    },
    dialog = { -- Options related to dialog window.
      height = 0.5, -- Maximum height.
    },
    msg = { -- Options related to msg window.
      height = 0.5, -- Maximum height.
      timeout = 4000, -- Time a message is visible in the message window.
    },
    pager = { -- Options related to message window.
      height = 1, -- Maximum height.
    },
  },
})
