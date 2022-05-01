" function Bufx()
"   buffers
"   call inputsave()
"   const bufname = input('bufx: ', '', 'buffer')
"   call inputrestore()
"   if bufname == ""
"     buffer #
"   elseif bufname == "d"
"     exe Bufd()
"   else
"     exe "b " . bufname
"   endif
" endfunction

" function Bufd()
"   call inputsave()
"   const buflist = input('bufd: ', '', 'buffer')
"   call inputrestore()
"   if buflist == ""
"     %bd|e#|bd#
"   else
"     exe "bd " . buflist
"     buffers
"   endif 
" endfunction

" nnoremap <silent> <C-f> :call Bufx()<CR>
