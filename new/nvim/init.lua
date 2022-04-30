require('pack')
require('nvim-cmp')
require('lsp')
require('lsp-installer')

vim.keymap.set('i', 'jk', '<Esc>')
vim.opt.path:append('**')
vim.cmd([[colorscheme codedark]])
