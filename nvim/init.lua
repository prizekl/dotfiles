vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

  -- My Essentials
  'tpope/vim-surround',
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-sleuth',
  'tpope/vim-abolish',
  'github/copilot.vim',
  {
    'numToStr/Comment.nvim',
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    config = function()
      require('Comment').setup {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
      }
    end
  },

  {
    'Wansmer/treesj',
    keys = { '<space>m', '<space>j', '<space>s' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('treesj').setup({ --[[ your config ]] })
    end,
  },

  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim',       opts = {} },
      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Formatter
    'stevearc/conform.nvim',
    config = function()
      require('conform').setup {
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "isort", "black" },
          typescript = { { 'prettierd', "prettier" } },
          typescriptreact = { { 'prettierd', "prettier" } },
        },
      }
    end,
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-nvim-lsp',
      'rafamadriz/friendly-snippets',
      'hrsh7th/cmp-buffer',
    },
  },
  {
    "windwp/nvim-autopairs",
    -- Optional dependency
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      require("nvim-autopairs").setup {}
      -- If you want to automatically add `(` after selecting a function or method
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done()
      )
    end,
  },

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk, { buffer = bufnr })

        vim.keymap.set('n', '<leader>hs', require('gitsigns').stage_hunk, { buffer = bufnr })
        vim.keymap.set('n', '<leader>hr', require('gitsigns').reset_hunk, { buffer = bufnr })
        vim.keymap.set('v', '<leader>hs',
          function() require('gitsigns').stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
          { buffer = bufnr })
        vim.keymap.set('v', '<leader>hr',
          function() require('gitsigns').reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
          { buffer = bufnr })
        vim.keymap.set('n', '<leader>hu', require('gitsigns').undo_stage_hunk, { buffer = bufnr })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr })
      end,
    },
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        theme = 'iceberg_dark',
        icons_enabled = false,
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { 'filename', path = 1, } },
        lualine_x = {},
        lualine_y = { 'progress', },
        lualine_z = { 'location', },
      },
    },
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    opts = {
      indent = { char = "▏" },
      whitespace = {
        remove_blankline_trail = true,
      },
      scope = {
        enabled = false,
      }
    },
  },

  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'radyz/telescope-gitsigns',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          window = {
            mappings = {
              -- disable fuzzy finder
              ["/"] = "none",
              ["?"] = "none",
              ["g?"] = "show_help",
              ["z"] = "none",
            }
          }
        }
      })
      vim.keymap.set('n', '<leader>n', ':Neotree toggle reveal<CR>')
    end,
  }
}, {})

-- [[ Setting options ]]
vim.wo.number = true
vim.o.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true
vim.o.showmode = false
vim.o.undofile = true

-- default tabs/spaces
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4

-- [[ Basic Keymaps ]]
-- Keymaps for better default experience
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[Telescope Settings]]
-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'gitsigns')
local actions = require "telescope.actions"
require('telescope').setup {
  defaults = {
    path_display = { "smart" },
    layout_strategy = "vertical",
  },
  pickers = {
    find_files = {
      hidden = true,
    },
    buffers = {
      sort_lastused = true,
      sort_mru = true,
      mappings = {
        i = {
          ["<c-d>"] = actions.delete_buffer
        }
      },
    },
  }
}

vim.keymap.set('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end)
vim.keymap.set('n', '<C-f>', require('telescope.builtin').buffers)
vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files)
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_status)
vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_bcommits)
vim.keymap.set('n', '<leader>gh', ':Telescope git_signs<CR>')
vim.keymap.set('n', '<leader>gs', require('telescope.builtin').grep_string)
vim.keymap.set('n', '<leader>lg', require('telescope.builtin').live_grep)
vim.keymap.set('n', '<leader>d', require('telescope.builtin').diagnostics)
vim.keymap.set('n', '<leader>re', require('telescope.builtin').resume)

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'go', 'lua', 'python', 'tsx', 'javascript', 'typescript' },
  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = true,
  modules = {},
  ignore_install = {},
  sync_install = false,
  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  local nmap = function(keys, func)
    vim.keymap.set('n', keys, func, { buffer = bufnr })
  end

  nmap('<leader>rn', vim.lsp.buf.rename)
  nmap('<leader>ca', vim.lsp.buf.code_action)

  -- nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gd', require('telescope.builtin').lsp_definitions)
  nmap('gt', require('telescope.builtin').lsp_type_definitions)
  nmap('gr', require('telescope.builtin').lsp_references)
  nmap('gI', require('telescope.builtin').lsp_implementations)
  nmap('<leader>o', require('telescope.builtin').lsp_document_symbols)
  nmap('<leader>t', require('telescope.builtin').lsp_dynamic_workspace_symbols)

  nmap('K', vim.lsp.buf.hover)
  -- Signature Documentation
  vim.keymap.set({ 'i', 'n' }, '<C-k>', vim.lsp.buf.signature_help, { buffer = bufnr })

  nmap('gD', vim.lsp.buf.declaration)
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder)
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder)
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end)
end

vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true })

-- Enable the following language servers
local servers = {
  tsserver = {},
  html = { filetypes = { 'html', 'twig', 'hbs' } },
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm {
      select = true,
    },
  },
  sources = {
    { name = 'luasnip' },
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'nvim_lsp_signature_help' },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
