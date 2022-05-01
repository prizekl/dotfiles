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
set shiftwidth=2
set tabstop=2
set smartindent
set expandtab
set clipboard=unnamed
set mouse=a

set number
set termguicolors
set fillchars+=eob:\ 
set signcolumn=yes
set statusline=%<%t\ %h%m%r\ %=%-14.(%l,%c%V%)\ %P

source ~/.config/nvim/config/vim-plug.vim
source ~/.config/nvim/config/codedark.vim
source ~/.config/nvim/config/indent-blankline.vim
source ~/.config/nvim/config/treesitter.vim
source ~/.config/nvim/config/telescope.vim
source ~/.config/nvim/config/coc.vim
source ~/.config/nvim/config/vista.vim
source ~/.config/nvim/config/fugitive.vim
source ~/.config/nvim/config/gitsigns.vim
source ~/.config/nvim/config/delimitmate.vim
source ~/.config/nvim/config/emmet.vim
source ~/.config/nvim/config/bufx.vim
