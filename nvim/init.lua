require('config.options')
require('config.keymaps')
require('config.auto-commands')
require('config.lazy')
require('setup.telescope')
require('config.lsp')
require('config.mini')

vim.cmd.colorscheme 'tokyonight-night'
vim.opt.clipboard = "unnamedplus"
