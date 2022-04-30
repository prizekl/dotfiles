" init.vim
imap jk <Esc>
let mapleader=" "
command! Leaf :cd %:h
command! Root :cd %:h | cd `git rev-parse --show-toplevel`
nnoremap <Leader>w /\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgn
nnoremap <Leader>W ?\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgN
nnoremap <Leader>m :!python3 %<CR>

syntax on
set hidden
set noswapfile
set nobackup
set nowritebackup
set ignorecase
set smartcase
set shiftwidth=4
set tabstop=4
set smartindent
set expandtab
set clipboard=unnamed
set mouse=a

set number
set termguicolors
set fillchars+=eob:\ 
set signcolumn=yes
set statusline=%<%t\ %h%m%r\ %=%-14.(%l,%c%V%)\ %P

source config/vim-plug.vim
source config/codedark.vim
source config/indent-blankline.vim
source config/treesitter.vim
source config/coc.vim
source config/vista.vim
source config/fugitive.vim
source config/gitsigns.vim
source config/delimitmate.vim
source config/emmet.vim
source config/bufx.vim
