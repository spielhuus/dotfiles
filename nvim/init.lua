-- Map leader to space
vim.g.mapleader = ' '

local fn = vim.fn
local execute = vim.api.nvim_command

-- Sensible defaults
require('settings')

-- Auto install packer.nvim if not exists
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end
vim.cmd [[packadd packer.nvim]]
vim.cmd 'autocmd BufWritePost plugins.lua PackerCompile' -- Auto compile when there are changes in plugins.lua

-- Install plugins
require('plugins')
require('config.colorscheme')  -- color scheme

-- Key mappings
require('keymappings')
require('lsp_lua')
require('config')

require('config.completion')
require('config.fugitive')
require('nvim-telescope')
require('treesitter')
require('conf-lualine')
require('nvim-cmp')     -- cmp
require('nvim-yabs')     -- yabs
require('plugins/luasnip')     -- luasnip
require('debug')     -- yabs
require('dap-python').setup('~/.virtualenvs/debugpy/bin/python')
