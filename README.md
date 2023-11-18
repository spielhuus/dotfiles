# dotfiles

## Plugins

[packer.nvim](https://github.com/wbthomason/packer.nvim) -  A use-package inspired plugin manager for Neovim

[Pocco81/DAPInstall.nvim](https://github.com/Pocco81/DAPInstall.nvim) - DAPInstall.nvim is a NeoVim plugin written in Lua that extends nvim-dap's functionality for managing various debuggers.

[rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) - A UI for nvim-dap

[nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) Find, Filter, Preview, Pick. All lua, all the time.

[rcarriga/vim-ultest](https://github.com/rcarriga/vim-ultest) - The ultimate testing plugin for (Neo)Vim.

[nvim-treesitter/nvim-treesitter]() -

[hrsh7th/nvim-cmp]() -

[neovim/nvim-lspconfig]() -

[romgrk/barbar.nvim](https://github.com/romgrk/barbar.nvim) - The neovim tabline plugin.

[folke/lsp-colors.nvim]() -

[]() -
[]() -
[]() -
[]() -
[]() -


 use { "rcarriga/vim-ultest", requires = {"vim-test/vim-test"}, run = ":UpdateRemotePlugins" }
  use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }
  use { 'szw/vim-maximizer' }
  use { 'mfussenegger/nvim-dap-python' }


# Keypaps

|plugin|key|method|
|neotest|<leader>tn|Run the nearest test.|
||<leader>tf|Run the tests in the current file.|
||<leader>ts|Show test summary.|
||<leader>tr|Show test reports.|

