"conig/nvim-gps.vim

lua <<EOF
require("nvim-gps").setup {}
EOF

func! NvimGps() abort
	return luaeval("require'nvim-gps'.is_available()") ?
		\ luaeval("require'nvim-gps'.get_location()") : ''
endf

set statusline=%<%t\ %h%m%r\ %{NvimGps()}\ %=%(%l,%c%V%)\ %P
