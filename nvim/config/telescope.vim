" config/telescope.vim
lua <<EOF
require('telescope').setup {
defaults = {
  path_display = { "smart" },
  layout_strategy = "vertical",
  },
pickers = {
  find_files = {
    theme = "dropdown",
    previewer = false,
    hidden = true
    },
  buffers = {
    theme = "dropdown",
    previewer = false,
    show_all_buffers = true,
    ignore_current_buffer = true,
    sort_mru = true,
    mappings = { i = { ["<c-d>"] = "delete_buffer", } }
    }
  },
extensions = {}
}

require('telescope').load_extension('coc')
EOF

nnoremap <C-p> :Telescope find_files<CR>
nnoremap <C-f> :Telescope buffers<CR>
nnoremap <C-g> :Telescope git_status<CR>
command! Rg :Telescope live_grep

nnoremap <silent><nowait> <leader>d  :Telescope coc diagnostics<CR>
nnoremap <silent><nowait> <leader>o  :Telescope coc document_symbols<CR>
nnoremap <silent><nowait> <leader>s  :Telescope coc workleader_symbols<CR>
nnoremap <silent><nowait> <leader>e  :Telescope resume<CR>
nnoremap <silent><nowait> gd :Telescope coc definitions<CR>
nnoremap <silent><nowait> gr :Telescope coc references<CR>
nnoremap <silent><nowait> gy :Telescope coc type_definitions<CR>
nnoremap <silent><nowait> gi :Telescope coc implementations<CR>
