" config/telescope.vim
lua <<EOF
require('telescope').setup{
defaults = {
  path_display = { "smart" },
  layout_strategy = "vertical",
  mappings = {
    i = {
      -- map actions.which_key to <C-h> (default: <C-/>)
      -- actions.which_key shows the mappings for your picker,
      -- e.g. git_{create, delete, ...}_branch for the git_branches picker
      }
    }
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
    sort_lastused = true,
    mappings = {
      i = {
        ["<c-d>"] = "delete_buffer",
        }
      }
    }
  },
extensions = {
  }
}
EOF

nnoremap <C-p> :Telescope find_files<CR>
nnoremap <C-f> :Telescope buffers<CR>
nnoremap <C-g> :Telescope git_status<CR>
command! Rg :Telescope live_grep<CR>
