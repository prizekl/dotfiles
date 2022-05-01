" config/treesitter.vim
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { 
    "python",
    "java",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "yaml",
    "json",
    "jsdoc",
    "dockerfile",
    "go" 
    },
  highlight = { enable = true, disable = { "vim" } },
  indent = { enable = true },
  -- ts-commentstring
  context_commentstring = { enable = true }
  }
EOF

autocmd FileType java setlocal shiftwidth=4 softtabstop=4 expandtab
