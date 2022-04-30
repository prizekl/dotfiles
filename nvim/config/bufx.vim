function Bufx()
  ls
  call inputsave()
  const bufname = input('bufx: ', '', 'buffer')
  call inputrestore()
  if bufname == ""
    b#
  elseif bufname == "d"
    %bd|e#|bd#
  else
    exe "b " . bufname
  endif
endfunction
nnoremap <silent> <C-f> :call Bufx()<CR>
