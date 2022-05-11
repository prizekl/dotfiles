" config/coc.vim
nnoremap <C-n> <Cmd>CocCommand explorer<CR>
highlight CocHintSign guifg=#FF8C00
highlight CocHintFloat guifg=#FF8C00
highlight CocErrorSign guifg=#c7463e
let g:coc_disable_transparent_cursor = 1
autocmd FileType list set winhighlight=CursorLine:CocUnderline

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
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
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction
nmap <leader>ac  <Plug>(coc-codeaction)
nmap <Leader>aw <Plug>(coc-codeaction-cursor)
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
command! -nargs=0 FO :call CocAction('format')
nnoremap <space>f :call CocAction('format')<CR>

" nmap <silent> gy <Plug>(coc-type-definition)
" nmap <silent> gi <Plug>(coc-implementation)
" nmap <silent> gd <Plug>(coc-definition)
" nmap <silent> gr <Plug>(coc-references)

" nnoremap <silent><nowait> <space>d  :<C-u>CocList diagnostics<cr>
" nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
