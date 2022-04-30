function Bufx()
  buffers
  call inputsave()
  const bufname = input('bufx: ', '', 'buffer')
  call inputrestore()
  if bufname == ""
    buffer #
  elseif bufname == "d"
    %bd|e#|bd#
  else
    exe "b " . bufname
  endif
endfunction

nnoremap <silent> <C-f> :call Bufx()<CR>
