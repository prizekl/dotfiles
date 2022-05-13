" config/gitsigns.vim
lua <<EOF
require('gitsigns').setup {
  signs = {
    add = {
      hl = 'GitSignsAdd',
      text = '┃',
      numhl='GitSignsAddNr',
      linehl='GitSignsAddLn'
      },
    change = {
      hl = 'GitSignsChange',
      text = '┃',
      numhl='GitSignsChangeNr',
      linehl='GitSignsChangeLn'
      },
    delete = {
      hl = 'GitSignsDelete',
      text = '▁',
      numhl='GitSignsDeleteNr',
      linehl='GitSignsDeleteLn'
      },
    topdelete = {
      hl = 'GitSignsDelete',
      text = '▔',
      numhl='GitSignsDeleteNr',
      linehl='GitSignsDeleteLn'
      },
    changedelete = {
      hl = 'GitSignsChange',
      text = '┃',
      numhl='GitSignsChangeNr',
      linehl='GitSignsChangeLn'
      },
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
  map('n', '<space>hs', ':Gitsigns stage_hunk<CR>')
  map('v', '<space>hs', ':Gitsigns stage_hunk<CR>')
  map('n', '<space>hr', ':Gitsigns reset_hunk<CR>')
  map('v', '<space>hr', ':Gitsigns reset_hunk<CR>')
  map('n', '<space>hS', '<cmd>Gitsigns stage_buffer<CR>')
  map('n', '<space>hu', '<cmd>Gitsigns undo_stage_hunk<CR>')
  map('n', '<space>hR', '<cmd>Gitsigns reset_buffer<CR>')
  map('n', '<space>hp', '<cmd>Gitsigns preview_hunk<CR>')
  map('n', '<space>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
  map('n', '<space>tb', '<cmd>Gitsigns toggle_current_line_blame<CR>')
  map('n', '<space>hd', '<cmd>Gitsigns diffthis<CR>')
  map('n', '<space>hD', '<cmd>lua require"gitsigns".diffthis("~")<CR>')
  map('n', '<space>td', '<cmd>Gitsigns toggle_deleted<CR>')
  -- Text object
  map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
  }
EOF

highlight GitSignsAdd    guifg=#587c0c ctermfg=2
highlight GitSignsChange guifg=#0c7d9d ctermfg=3
highlight GitSignsDelete guifg=#c7463e ctermfg=1
