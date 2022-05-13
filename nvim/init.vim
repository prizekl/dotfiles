" init.vim
imap jk <Esc>
let mapleader=" "
command! Leaf :cd %:h
command! Root :cd %:h | cd `git rev-parse --show-toplevel`
nnoremap <space>w /\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgn
nnoremap <space>W ?\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgN
nnoremap <space>m :!python3 %<CR>

set noswapfile
set clipboard=unnamed
set mouse=a

set ignorecase
set smartcase
set shiftwidth=2
set softtabstop=2
set smartindent
set expandtab

set termguicolors
set number

source ~/.config/nvim/config/vim-plug.vim
source ~/.config/nvim/config/codedark.vim
source ~/.config/nvim/config/indent-blankline.vim
source ~/.config/nvim/config/treesitter.vim
source ~/.config/nvim/config/nvim-gps.vim
source ~/.config/nvim/config/telescope.vim
source ~/.config/nvim/config/coc.vim
source ~/.config/nvim/config/vista.vim
source ~/.config/nvim/config/fugitive.vim
source ~/.config/nvim/config/gitsigns.vim
source ~/.config/nvim/config/emmet.vim
