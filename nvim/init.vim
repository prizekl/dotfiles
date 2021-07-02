" ~/.vimrc cut cmd+opt+v
" qq (macro) /pattern a(^MEa)^M
" :g/>/norm ctwself.assertEqual(JA,
" :'<,'>Tab /=
" macros :norm @q"
" case sensitive :%s/foo\C/bar/g
"
" if exists('$TMUX')
"  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
"  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
" endif

" --Mappings
imap jk <Esc>
nnoremap <Leader>f :b#<CR>
nnoremap <Leader>cd :cd %:p:h<CR> :pwd<CR>
nnoremap <Leader>x /\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgn
nnoremap <Leader>X ?\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgN
nnoremap ,m :!python3 %

" --Vim Defaults
syntax on
set hidden
set noswapfile
set nobackup
set nowritebackup
set clipboard=unnamed
set mouse=a
set ignorecase
set smartcase
set number
set relativenumber
set shiftwidth=2
set tabstop=2
set smartindent
set expandtab

" {{{ Plugins }}}

" --vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')
"COC (auto-complete, linting, snippets, formatter, file explorer)
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'mattn/emmet-vim'
"Navigation
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'liuchengxu/vista.vim'
" Plug 'wellle/context.vim'
"Utilities (auto-brackets, comments, column-align)
Plug 'Raimondi/delimitMate'
Plug 'machakann/vim-sandwich'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-abolish'
Plug 'godlygeek/tabular'
Plug 'mbbill/undotree'
"Syntax Highlighting
let g:polyglot_disabled = ['sensible']
Plug 'sheerun/vim-polyglot'
"Git support
" Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
"Appearance
Plug 'tomasiser/vim-code-dark'
Plug 'Yggdroot/indentLine'
Plug 'vim-airline/vim-airline'
Plug 'ryanoasis/vim-devicons'
call plug#end()

" --Emmet
let g:user_emmet_leader_key='<Leader>'
imap ,, <Leader>,

" --FZF
nmap <C-p> :Files<CR>
nmap <C-f> :Buffers<CR>
let $FZF_DEFAULT_COMMAND = 'rg --files --hidden'

" --Vista (replaces tagbar for now) 
let g:vista_default_executive = 'coc'
let g:vista_fzf_preview = ['right:0%']
nmap <Leader>t :Vista finder<CR>
nnoremap <C-t> :Vista!!<CR>

" --Context
let g:context_enabled = 1
let g:context_filetype_blacklist = ['coc-explorer']

" --DelimitMate
let delimitMate_matchpairs = "(:),[:],{:},<:>"

" --UndoTree
nnoremap <Leader>b :UndotreeToggle<CR>

" --IndentLines
let g:vim_json_conceal = 0
let g:indentLine_showFirstIndentLevel = 1
let g:indentLine_first_char = '│'
let g:indentLine_char = '│'
let g:indentLine_fileTypeExclude=['coc-explorer']
let g:indentLine_bufTypeExclude = ['help', 'terminal']
let g:indentLine_bufNameExclude = ['_.*', 'NERD_tree.*']

" --Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#show_tab_count = 0
let g:airline#extensions#whitespace#enabled = 0

" {{{ User Interface }}}

" --Colors
set fillchars+=eob:\ 
set signcolumn=yes
set termguicolors
set background=dark
colo codedark
set indentkeys-=<:> "??

" {{{ COC }}}

nnoremap <C-n> :CocCommand explorer<CR>
command EditSnippets execute 'CocCommand snippets.editSnippets'

let g:coc_disable_transparent_cursor = 1
highlight CocHintSign ctermfg=yellow guifg=#ff0000
highlight CocHintFloat ctermfg=yellow guifg=#ff0000
highlight CocErrorSign guifg=#c7463e

" --COC Defaults
nnoremap <silent> <space>d :<C-u>CocList diagnostics<cr>
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
set updatetime=300
set shortmess+=c
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
nmap <leader>rn <Plug>(coc-rename)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
command! -nargs=0 Format :call CocAction('format')
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
