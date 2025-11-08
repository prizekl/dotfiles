vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.expandtab = true

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath }
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup({ { 'tpope/vim-surround' } })

local vscode = require('vscode')

vim.keymap.set('n', '<leader>f', function()
    vscode.action('editor.action.formatDocument')
end)

vim.keymap.set('n', '[t', function()
    vscode.action('breadcrumbs.focus')
end)

vim.keymap.set('n', ']c', function()
    vscode.action('workbench.action.compareEditor.nextChange')
end)
vim.keymap.set('n', ']c', function()
    vscode.action('workbench.action.editor.nextChange')
end)

vim.keymap.set('n', '[c', function()
    vscode.action('workbench.action.compareEditor.previousChange')
end)
vim.keymap.set('n', '[c', function()
    vscode.action('workbench.action.editor.previousChange')
end)

vim.keymap.set('n', '<leader>hr', function()
    vscode.action('git.revertSelectedRanges')
end)

vim.keymap.set('n', ']d', function()
    vscode.action('editor.action.marker.next')
end)
vim.keymap.set('n', '[d', function()
    vscode.action('editor.action.marker.prev')
end)
