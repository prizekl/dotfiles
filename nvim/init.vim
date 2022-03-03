" ~/.vimrc :f == cwd
" qq (macro) /pattern a(^MEa)^M
" :'<,'>Tab /=
" macros :norm @q"
" case sensitive :%s/foo\C/bar/g
" <leader>hp preview hunk | hs stage | hu undo | hr reset to git
" rename tag with srtt. delete tag with sdt. Surround a tag with vat,,

" --Mappings
imap jk <Esc>
let mapleader=" "
nnoremap <Leader>f :b#<CR>
nnoremap <Leader>cd :cd %:p:h<CR> :pwd<CR>
nnoremap <Leader>w /\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgn
nnoremap <Leader>W ?\<<C-R>=expand('<cword>')<CR>\>\C<CR>``cgN
nnoremap <Leader>m :!python3 %<CR>

" --Defaults
syntax on
set encoding=UTF-8
set hidden
set noswapfile
set nobackup
set nowritebackup
set clipboard=unnamed
set mouse=a
set ignorecase
set smartcase
set number
set shiftwidth=2
set tabstop=2
set smartindent
set expandtab

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
Plug 'liuchengxu/vista.vim', {'do': 'Vista!!'}
"Utilities (auto-brackets, comments, column-align)
Plug 'Raimondi/delimitMate'
Plug 'machakann/vim-sandwich'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-abolish', {'do': ':Substitute'}
Plug 'godlygeek/tabular', {'do': ':Tab'}
"Treesitter (ft syntax highlighting, indents)
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'jparise/vim-graphql', {'for': 'graphql'}
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
"Git support
Plug 'tpope/vim-fugitive'
Plug 'lewis6991/gitsigns.nvim'
Plug 'nvim-lua/plenary.nvim'
"Appearance
Plug 'tomasiser/vim-code-dark'
Plug 'lukas-reineke/indent-blankline.nvim'
call plug#end()

" --Vanilla UI
set fillchars+=eob:\ 
set signcolumn=yes
set termguicolors
colo codedark
set cursorline
hi cursorline guibg=NONE

set statusline=%<%t\ %h%m%r%{FugitiveStatusline()}%=%-14.(%l,%c%V%)\ %P
hi statusline guibg=#007ACC guifg=#FFFFFF

" --Gitsigns
lua <<EOF
require('gitsigns').setup {
  signs = {
    add = {hl = 'GitSignsAdd', text = '┃', numhl='GitSignsAddNr', linehl='GitSignsAddLn'},
    change = {hl = 'GitSignsChange', text = '┃', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    delete = {hl = 'GitSignsDelete', text = '▁', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    topdelete = {hl = 'GitSignsDelete', text = '▔', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    changedelete = {hl = 'GitSignsChange', text = '┃', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    },
  on_attach = function(bufnr)
  local function map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend('force', {noremap = true, silent = true}, opts or {})
  vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
end
-- Navigation
map('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", {expr=true})
map('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", {expr=true})
-- Actions
map('n', '<leader>hs', ':Gitsigns stage_hunk<CR>')
map('v', '<leader>hs', ':Gitsigns stage_hunk<CR>')
map('n', '<leader>hr', ':Gitsigns reset_hunk<CR>')
map('v', '<leader>hr', ':Gitsigns reset_hunk<CR>')
map('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>')
map('n', '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<CR>')
map('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>')
map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>')
map('n', '<leader>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
map('n', '<leader>tb', '<cmd>Gitsigns toggle_current_line_blame<CR>')
map('n', '<leader>hd', '<cmd>Gitsigns diffthis<CR>')
map('n', '<leader>hD', '<cmd>lua require"gitsigns".diffthis("~")<CR>')
map('n', '<leader>td', '<cmd>Gitsigns toggle_deleted<CR>')
-- Text object
map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
  }
EOF
highlight GitSignsAdd    guifg=#587c0c ctermfg=2
highlight GitSignsChange guifg=#0c7d9d ctermfg=3
highlight GitSignsDelete guifg=#c7463e ctermfg=1
"git diff colors
hi DiffAdd ctermfg=108 guifg=#87af87
hi DiffDelete ctermfg=131 guifg=#af5f5f

" --Emmet
let g:user_emmet_leader_key='\'
imap ,, \,
vmap ,, \,

" --FZF
nmap <C-p> :Files<CR>
nmap <C-f> :Buffers<CR>
nmap <C-g> :GFiles?<CR>
let $FZF_DEFAULT_COMMAND = 'rg --files --hidden'
let g:fzf_preview_window = ['up:50%', 'ctrl-o']
command! -bang -nargs=* Rg call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1, fzf#vim#with_preview({'options': '--delimiter : --nth 2..'}), <bang>0)

" --Vista
let g:vista_default_executive = 'coc'
let g:vista_fzf_preview = ['right:0%']
nmap <Leader>t :Vista finder<CR>
nnoremap <C-t> :Vista!!<CR>

" --DelimitMate
let delimitMate_matchpairs = "(:),[:],{:},<:>"

" --Treesitter, nvim-ts-autotag
lua <<EOF
require'nvim-treesitter.configs'.setup {
ensure_installed = { "python", "html", "css", "javascript", "typescript", "tsx", "yaml", "json", "jsdoc", "dockerfile", "go" },
highlight = { enable = true },
indent = { enable = true },
-- nvim-commentstring
context_commentstring = { enable = true }
}
EOF

" --Indent-blankline (need update)
let g:indent_blankline_show_first_indent_level = v:true
let g:indent_blankline_use_treesitter = v:true
let g:indent_blankline_char = '│'
let g:indent_blankline_filetype_exclude = ['coc-explorer', 'vista']
let g:indent_blankline_buftype_exclude = ['help', 'terminal']
let g:indent_blankline_show_trailing_blankline_indent = v:false
set colorcolumn=99999 "fix ghost column highlight

" {{{ COC }}}

nnoremap <C-n> <Cmd>CocCommand explorer<CR>
highlight CocHintSign guifg=#FF8C00
highlight CocHintFloat guifg=#FF8C00
highlight CocErrorSign guifg=#c7463e
let g:coc_disable_transparent_cursor = 1
autocmd FileType list set winhighlight=CursorLine:CocUnderline

" --COC defaults
nnoremap <silent> <space>d :<C-u>CocList diagnostics<cr>
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <leader>ac  <Plug>(coc-codeaction)
nmap <Leader>aw <Plug>(coc-codeaction-cursor)
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
