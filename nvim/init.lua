-- init.lua
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', { command = 'source <afile> | PackerCompile', group = packer_group, pattern = 'init.lua' })

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use 'arcticicestudio/nord-vim'

  use { 'lewis6991/gitsigns.nvim',
        requires = { 'nvim-lua/plenary.nvim' } }
  use { 'liuchengxu/vista.vim' }
  use {
    'kyazdani42/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons' },
  }

  use 'machakann/vim-sandwich'
  use { 'numToStr/Comment.nvim', 
    config = function() require('Comment').setup{} end }
  use {
	"windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup{} end }

  use { 'nvim-telescope/telescope.nvim', 
        requires = {
            'nvim-lua/plenary.nvim',
            'kyazdani42/nvim-web-devicons' } }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  use 'nvim-treesitter/nvim-treesitter'
  use 'nvim-treesitter/nvim-treesitter-textobjects'

  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-nvim-lsp'
  use { "ray-x/lsp_signature.nvim", config = 
        function() require "lsp_signature".setup({
          handler_opts = {
              border = "none",
          },
          hint_enable = false,
      }) end }
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip'
  use "rafamadriz/friendly-snippets"
  use { 'j-hui/fidget.nvim',
        config = function() require('fidget').setup{} end }

  if packer_bootstrap then
      require('packer').sync()
    end
end)

vim.g.mapleader = ' '
vim.api.nvim_create_user_command(
  'Leaf',
  ":cd %:h",
  {bang = true}
)
vim.api.nvim_create_user_command(
  'Root',
  ":cd %:h | cd `git rev-parse --show-toplevel`",
  {bang = true}
)

vim.o.mouse = 'a'
vim.o.clipboard = 'unnamed'
vim.o.breakindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.completeopt = 'menuone,noselect'

vim.o.hlsearch = true
vim.wo.number = true
vim.o.termguicolors = true
vim.cmd [[colorscheme nord]]

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- Make For Go
vim.keymap.set({ 'n' }, '<Leader>mt', ':TmuxMakeGo<CR>', { silent = true })
vim.keymap.set({ 'n' }, '<Leader>mk', ':Make<CR>', { silent = true })
vim.api.nvim_create_user_command(
  'TmuxMakeGo',
  ':!tmux run-shell -t 1 "go clean -testcache && go test %:p:h -v"',
  {bang = true}
)
vim.api.nvim_create_user_command(
  'Make',
  "!go clean -testcache && go test %:p:h -v",
  {bang = true}
)

-- Gitsigns
require('gitsigns').setup {
 on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
    map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
    map('n', '<leader>hS', gs.stage_buffer)
    map('n', '<leader>hu', gs.undo_stage_hunk)
    map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>hp', gs.preview_hunk)
    map('n', '<leader>hb', function() gs.blame_line{full=true} end)
    map('n', '<leader>tb', gs.toggle_current_line_blame)
    map('n', '<leader>hd', gs.diffthis)
    map('n', '<leader>hD', function() gs.diffthis('~') end)
    map('n', '<leader>td', gs.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

-- Vista Mapping
vim.g["vista_default_executive"] = 'nvim_lsp'
vim.keymap.set({ 'n' }, '<C-t>', ':Vista!!<CR>', { silent = true })

--Enable nvim-tree
require'nvim-tree'.setup {
  update_focused_file = {
    enable = true,
  }
}
vim.keymap.set({ 'n' }, '<C-n>', ':NvimTreeToggle<CR>', { silent = true })

-- Telescope
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
    },
    lsp_document_symbols = {
      theme = "dropdown",
      previewer = false
    }
  }
}
-- Enable telescope fzf native
require('telescope').load_extension 'fzf'

--Add leader shortcuts
vim.keymap.set('n', '<C-f>', require('telescope.builtin').buffers)
vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files)
vim.keymap.set('n', '<C-g>', require('telescope.builtin').git_status)
vim.keymap.set('n', '<leader>re', require('telescope.builtin').resume)
vim.keymap.set('n', '<leader>rg', require('telescope.builtin').live_grep)
vim.keymap.set('n', '<leader>s', require('telescope.builtin').lsp_dynamic_workspace_symbols)
vim.keymap.set('n', '<leader>o', require('telescope.builtin').lsp_document_symbols)

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "python",
    "java",
    "yaml",
    "html",
    "css",
    "javascript",
    "jsdoc",
    "json",
    "typescript",
    "tsx",
    "dockerfile",
    "go" 
  } ,
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<CR>',
      scope_incremental = '<CR>',
      node_incremental = '<TAB>',
      node_decremental = '<S-TAB>',
    },
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>d', vim.diagnostic.setqflist)

-- LSP settings
local lspconfig = require 'lspconfig'
local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>ac', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>o', require('telescope.builtin').lsp_document_symbols, opts)
  vim.api.nvim_buf_create_user_command(bufnr, "Format", vim.lsp.buf.formatting, {})
end

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Enable the following language servers
local servers = { 
  'gopls',
  'pyright',
  'tsserver',
  'html',
  'cssmodules_ls',
  'cssls',
  'jsonls'
}
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- luasnip setup
local luasnip = require 'luasnip'
require("luasnip.loaders.from_vscode").lazy_load()

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'buffer' },
    { name = 'luasnip' },
  },
}
