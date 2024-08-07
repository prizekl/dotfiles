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
  {
    "quentingruber/timespent.nvim"
  },

  -- Essentials
  'tpope/vim-surround',
  'tpope/vim-sleuth',
  'tpope/vim-abolish',
  {
    'lewis6991/satellite.nvim',
    opts = {
      handlers = {
        marks = {
          enable = false
        },
        cursor = {
          enable = false
        },
        search = {
          enable = false
        },
      },
    }
  },

  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({})
    end,
  },

  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
  },

  {
    'Wansmer/treesj',
    keys = { '<leader>m' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('treesj').setup({})
    end,
  },

  -- Git
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup({
        view = {
          merge_tool = {
            layout = "diff1_plain"
          }
        }
      })
    end
  },

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gitsigns.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gitsigns.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr })

        vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, { buffer = bufnr })
        vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, { buffer = bufnr })
        vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, { buffer = bufnr })
        vim.keymap.set('v', '<leader>hs',
          function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
          { buffer = bufnr })
        vim.keymap.set('v', '<leader>hr',
          function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
          { buffer = bufnr })
        vim.keymap.set('n', '<leader>hu', gitsigns.undo_stage_hunk, { buffer = bufnr })

        -- Text object
        vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      end,
    },
  },


  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim',       opts = {} },
      'folke/neodev.nvim',
    },
  },

  {
    -- Formatter
    'stevearc/conform.nvim',
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
      },
    },
    config = function()
      require('conform').setup {
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "isort", "black" },
          typescript = { 'prettierd', "prettier", stop_after_first = true },
          typescriptreact = { 'prettierd', "prettier", stop_after_first = true },
        },
      }
    end,
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
    },
  },
  {
    "windwp/nvim-autopairs",
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
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      pcall(require('telescope').load_extension, 'fzf')
      local actions = require "telescope.actions"
      require('telescope').setup {
        defaults = {
          path_display = { "truncate" },
          layout_strategy = "vertical",
          borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
          vimgrep_arguments = {
            "rg",
            "-U", -- Multi-line search
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case"
          }
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
      vim.keymap.set('n', '<leader>gs', require('telescope.builtin').grep_string)
      vim.keymap.set('n', '<leader>lg', require('telescope.builtin').live_grep)
      vim.keymap.set('n', '<leader>d', require('telescope.builtin').diagnostics)
      vim.keymap.set('n', '<leader>re', require('telescope.builtin').resume)
    end
  },

  {
    'windwp/nvim-ts-autotag',
    opts = {}
  },

  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'go',
          'lua',
          'python',
          'tsx',
          'javascript',
          'typescript',
          'html',
        },
        -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
        auto_install = true,
        modules = {},
        ignore_install = {},
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          -- keymaps = {
          --   init_selection = "<leader>si",
          --   node_incremental = "<leader>si",
          --   scope_incremental = "<leader>sc",
          --   node_decremental = "<leader>sd",
          -- },
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
    end
  },

  {
    'stevearc/oil.nvim',
    config = function()
      require('oil').setup(
        {
          float = {
            winblend = 0,
            border = 'single'
          }
        }
      )

      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NvimDarkGrey2' })
      vim.keymap.set('n', '<leader>n', ':Oil --float<CR>')
    end
    -- Optional dependencies
    -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },

  {
    'echasnovski/mini.files',
    version = false,
    config = function()
      require('mini.files').setup()

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesWindowOpen',
        callback = function(args)
          local win_id = args.data.win_id
          vim.wo[win_id].winblend = 10
        end,
      })

      vim.api.nvim_exec([[
      highlight MiniFilesNormal guibg=NvimDarkGrey2
      highlight MiniFilesBorder guibg=NvimDarkGrey2
      ]], false)

      _G.minifiles_toggle = function(...)
        if not MiniFiles.close() then
          MiniFiles.open(...)
          MiniFiles.reveal_cwd()
        end
      end

      vim.keymap.set('n', '<leader>p', ':lua _G.minifiles_toggle(vim.api.nvim_buf_get_name(0))<CR>')
    end
  },

  {
    'nvim-lualine/lualine.nvim',
    config = function()
      local colors = {
        black        = 'NvimDarkGrey3',
        white        = 'NvimLightGrey2',
        inactivegray = 'NvimDarkGrey2',
      }

      local lualine_theme = {
        normal = {
          a = { bg = colors.black, fg = colors.white, gui = 'bold' },
          b = { bg = colors.black, fg = colors.white },
          c = { bg = colors.black, fg = colors.white }
        },
        inactive = {
          a = { bg = colors.inactivegray, fg = colors.white, gui = 'bold' },
          b = { bg = colors.inactivegray, fg = colors.white },
          c = { bg = colors.inactivegray, fg = colors.white }
        }
      }

      require('lualine').setup {
        options = {
          theme = lualine_theme,
          icons_enabled = false,
          component_separators = '',
          section_separators = '',
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', },
          lualine_c = { { 'filename', path = 1, } },
          lualine_x = { 'diagnostics' },
          lualine_y = { 'progress', },
          lualine_z = { 'location', },
        },
        inactive_sections = {
          lualine_c = { { 'filename', path = 1, } },
          lualine_x = { 'diagnostics' },
          lualine_y = { 'progress', },
          lualine_z = { 'location', },
        },
      }
    end
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
vim.o.undofile = true
vim.o.showmode = false
vim.api.nvim_command("packadd cFilter")

-- default tabs/spaces
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4

-- [[ Basic Keymaps ]]
-- Keymaps for better default experience
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
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


-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- [[ Configure LSP ]]
local on_attach = function(_, bufnr)
  local nmap = function(keys, func)
    vim.keymap.set('n', keys, func, { buffer = bufnr })
  end

  nmap('crn', vim.lsp.buf.rename)
  nmap('crr', vim.lsp.buf.code_action)

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

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

-- UI borders
local handlers = {
  ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
  ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' }),
}

vim.diagnostic.config { float = { border = "single" }, }

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      handlers = handlers,
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
cmp.setup {
  preselect = cmp.PreselectMode.None,
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
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'nvim_lsp_signature_help' },
  },
}
