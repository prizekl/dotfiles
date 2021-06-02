" ~/.vimrc
" :g/^$/    
" :g/>/norm ctwself.assertEqual(JA,
" :'<,'>Tab /=
" macros :norm @q"
" case sensitive :%s/foo\C/bar/g
" :CocCommand eslint.showOutputChannel
" :nohl

" --Mappings
imap jk <Esc>
nnoremap <Leader>cd :cd %:p:h<CR> :pwd<CR>
nnoremap <Leader>x /\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgn
nnoremap <Leader>X ?\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgN
nnoremap ,m :!python3 %

"buffer management
function Debuf()
  echo("[buffer list]")
  ls t
  call inputsave()
  const buffername = input('debuf: ', '', 'buffer')
  call inputrestore()
  if buffername == "aec"
    %bdelete|edit#|bdelete#
  elseif len(buffername) >= 1
    for i in split(buffername)
      execute "bd " . i
    endfor
  endif
endfunction
nnoremap <silent> <Leader>f :call Debuf()<CR>

" --Vim Defaults
syntax on
set encoding=utf8
set fileencoding=utf-8
set nocompatible
set hidden
set noswapfile
set nobackup
set nowritebackup
set belloff=all
set backspace=2
set clipboard=unnamed
set mouse=a
set incsearch
set hlsearch
set ignorecase
set smartcase
set wildmenu
set ruler
set number
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

call plug#begin('~/.vim/plugged')
"COC (auto-complete, linting, snippets, formatter, file explorer)
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'dsznajder/vscode-es7-javascript-react-snippets', { 'do': 'yarn install --frozen-lockfile && yarn compile' }
Plug 'mattn/emmet-vim'
"Navigation
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'wfxr/minimap.vim'
Plug 'liuchengxu/vista.vim'
Plug 'wellle/context.vim'
"Utilities (auto-brackets, comments, column-align)
Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-abolish'
Plug 'godlygeek/tabular'
Plug 'mbbill/undotree'
"Syntax Highlighting
let g:polyglot_disabled = ['typescript', 'sensible']
Plug 'sheerun/vim-polyglot'
"Colorschemes
Plug 'tomasiser/vim-code-dark'
Plug 'romgrk/doom-one.vim'
Plug 'sainnhe/gruvbox-material'
"Git support
" Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
"Appearance
Plug 'Yggdroot/indentLine'
Plug 'vim-airline/vim-airline'
Plug 'ryanoasis/vim-devicons'
call plug#end()

" --emmet
let g:user_emmet_leader_key='<Leader>'
imap ,, <Leader>,

" --Vista (replaces tagbar for now)
let g:vista_default_executive = 'coc'
nmap <Leader>t :Vista finder<CR>
let g:vista_fzf_preview = ['right:50%']
function Toggy()
  let vistawinnr = bufwinnr('__vista__')
  let minimapwinnr = bufwinnr('-MINIMAP-')
  if vistawinnr!= -1
    echo('closing vista and opening minimap')
    Vista!
    Minimap
  elseif minimapwinnr != -1
    echo('closing minimap and opening vista')
    MinimapClose
    Vista
  else
    echo('opening minimap')
    Minimap
  endif
endfunction
nnoremap <C-t> :call Toggy()<CR>

" --FZF
nmap <C-p> :Files<CR>
nmap <C-f> :Buffers<CR>

" --UndoTree
nnoremap <Leader>u :UndotreeToggle<CR>

" --Context
let g:context_enabled = 1
let g:context_filetype_blacklist = ['coc-explorer']

" --DelimitMate
let delimitMate_matchpairs = "(:),[:],{:},<:>"

" --Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#show_tab_count = 0
let g:airline#extensions#whitespace#enabled = 0

" --Indentline
let g:vim_json_conceal = 0
let g:indentLine_char = '│'
let g:indentLine_first_char = '│'
let g:indentLine_showFirstIndentLevel = 1
let g:indentLine_fileTypeExclude=['coc-explorer']
let g:indentLine_bufTypeExclude = ['help', 'terminal']
let g:indentLine_bufNameExclude = ['_.*', 'NERD_tree.*']

" --Colorscheme Settings
let g:gruvbox_material_background = 'soft'

" {{{ User Interface }}}

" --Colors
" tmux color fix
if exists('$TMUX')
 let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
 let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
set fillchars+=vert:│,eob:\ 
set signcolumn=yes
set termguicolors
set background=dark
colo codedark
let g:minimap_width = 10
hi MinimapCurrentLine guifg=#00adb5
let g:minimap_highlight = 'MinimapCurrentLine'
nmap <Leader>m :MinimapClose<CR>

" {{{ COC }}}

" --COC EXPLORER
nnoremap <C-n> :CocCommand explorer<CR>

" --Snippets
command EditSnippets execute 'CocCommand snippets.editSnippets'

" --UI
let g:coc_disable_transparent_cursor = 1
highlight CocHintSign ctermfg=yellow guifg=#ff0000
highlight CocHintFloat ctermfg=yellow guifg=#ff0000
highlight CocErrorSign guifg=#c7463e

" --COC Defaults
nnoremap <silent> <space>d :<C-u>CocList diagnostics<cr>
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
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call CocAction('runCommand', 'editor.action.organizeImport')

" {{{ DEPRECATED CONFIGS }}}

""filetype indent (tabstop/ shiftwidth) -- replaced by polyglot
" autocmd FileType python set tabstop=4|set shiftwidth=4|set expandtab
" autocmd FileType java set tabstop=4|set shiftwidth=4|set expandtab
""Terminal Window
"set lines=36 columns=100
"command Sexl execute 'set columns=180 | vs'
"command Sex execute 'set columns=165 | vs'
"command Bigger execute 'set columns=140'
"command Big execute 'set columns=120'
"command Medium execute 'set columns=100'
"command Small execute 'set columns=90'
" let g:indentLine_concealcursor = ''
""Easymotion colors
"hi EasyMotionTarget ctermbg=115 ctermfg=black
"hi easymotiontarget2first ctermbg=152 ctermfg=black
"hi easymotiontarget2second ctermbg=152 ctermfg=black
"hi EasyMotionTarget cterm=bold ctermbg=NONE ctermfg=214
" " system based colorscheme (dark vs light mode)
" if system("defaults read -g AppleInterfaceStyle") =~ '^Dark'
"    set background=dark
"    colo codedark
" else
"   set background=light
"   colo gruvbox-material
" endif
" set t_Co=256
" open COCEx if no files specified
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | CocCommand explorer | endif
" autocmd VimEnter * nested :CocCommand explorer
" " --Tagbar
" let g:tagbar_width = 30
" let g:tagbar_sort = 0
" let g:no_status_line = 1
" nmap <C-t> :TagbarToggle<CR>
" " nnoremap <silent> <leader>s :call Warp0()<CR>
" " --Warp: fast buffer switch
" function Warp()
"   ls t
"   call inputsave()
"   const buffername = input('warp: ', '', 'buffer')
"   call inputrestore()
"   if empty(buffername)
"     buffer#
"   elseif buffername == "daec"
"     %bdelete|edit#|bdelete#
"   elseif len(buffername) > 1 && split(buffername)[0] == "d"
"     for i in split(buffername)[1:]
"       execute "bd " . i
"     endfor
"   else
"     execute "b " . buffername
"   endif
" endfunction
" " nnoremap <silent> <C-f> :call Warp()<CR>
"fast buffer switch
" function Warp()
"   ls t
"   call inputsave()
"   const buffername = input('warp: ', '', 'buffer')
"   call inputrestore()
"   if empty(buffername)
"     buffer#
"   elseif buffername == "daec"
"     %bdelete|edit#|bdelete#
"   elseif len(buffername) > 1 && split(buffername)[0] == "d"
"     for i in split(buffername)[1:]
"       execute "bd " . i
"     endfor
"   else
"     execute "b " . buffername
"   endif
" endfunction
" nnoremap <silent> <Leader>f :call Warp()<CR>
" " Highlight the symbol and its references when holding the cursor.
" autocmd CursorHold * silent call CocActionAsync('highlight')
" hi CocHighlightText guibg=grey
" let g:airline#extensions#tabline#show_splits = 0
" let g:airline#extensions#tabline#show_buffers = 0
" let g:airline#extensions#tabline#show_tab_type = 0
" let g:airline#extensions#tabline#show_tab_count = 0
" let g:airline#extensions#tabline#show_close_button = 0
" let g:airline#extensions#tagbar#enabled = 1
" let g:airline#extensions#tagbar#flags = 'f'
" let g:airline#extensions#tagbar#flags = 's'
"" Airline transparent tabbar background
" autocmd VimEnter * hi! airline_tabfill ctermbg=None guibg=NONE
" let g:airline_theme = 'cool'
" let g:airline_powerline_fonts = 0
