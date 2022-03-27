-- Map leader to space
vim.g.mapleader = ' '

local fn = vim.fn
local execute = vim.api.nvim_command

-- Sensible defaults
require('config/settings')
require('config/colorscheme')
require('config/mappings')
require('config/fugitive')

-- Auto install packer.nvim if not exists
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end
vim.cmd [[packadd packer.nvim]]
vim.cmd 'autocmd BufWritePost plugins.lua PackerCompile' -- Auto compile when there are changes in plugins.lua

-- Install plugins
require('plugins')

-- configure plugins
require('plugins/treesitter')
require('plugins/luasnip')
require('plugins/telescope')
require('plugins/nvim-cmp')
require('plugins/nvim-lspconfig')
require('plugins/ultest')
require('nvim-yabs')
-- require('plugins/nvim-dap')
require('dap-python').setup('~/.virtualenvs/debugpy/bin/python')
