" config/telescope.vim
lua <<EOF
require('telescope').setup{
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
    mappings = {
      i = {
        ["<c-d>"] = "delete_buffer",
        }
      }
    }
  },
extensions = {
  fzf = {
    fuzzy = true, 
    override_generic_sorter = true,
    override_file_sorter = true,  
    case_mode = "smart_case",     
    }
  }
}

require('telescope').load_extension('fzf')
require('telescope').load_extension('coc')
EOF

nnoremap <C-p> :Telescope find_files<CR>
nnoremap <C-f> :Telescope buffers<CR>
nnoremap <C-g> :Telescope git_status<CR>
command! Rg :Telescope live_grep<CR>

nnoremap <silent><nowait> <space>d  :Telescope coc diagnostics<cr>
nnoremap <silent><nowait> <space>o  :Telescope coc document_symbols<cr>
nnoremap <silent><nowait> <space>s  :Telescope coc workspace_symbols<cr>
