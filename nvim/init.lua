vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.wo.number = true
vim.o.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.completeopt = 'menuone,noselect'
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.autoread = true
vim.o.swapfile = false
vim.api.nvim_command 'packadd Cfilter'

-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Floats are disabled by default: https://github.com/neovim/neovim/pull/16230
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'tpope/vim-surround',
  {
    'm4xshen/autoclose.nvim',
    event = 'InsertEnter',
    opts = { options = {
      disabled_filetypes = { 'TelescopePrompt' },
      disable_command_mode = true,
    } },
  },

  -- TODO: Remove subscription
  -- { 'supermaven-inc/supermaven-nvim', opts = { ignore_filetypes = { 'TelescopePrompt', 'text' } } },

  -- Git
  {
    'sindrets/diffview.nvim',
    config = function()
      require('diffview').setup {
        view = { merge_tool = { layout = 'diff1_plain', disable_diagnostics = false } },
      }
    end,
  },

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end)

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end)

        vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, { buffer = bufnr })
        vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, { buffer = bufnr })
        vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, { buffer = bufnr })
        vim.keymap.set('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { buffer = bufnr })
        vim.keymap.set('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { buffer = bufnr })
        vim.keymap.set('n', '<leader>hu', gitsigns.undo_stage_hunk, { buffer = bufnr })
        vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, { buffer = bufnr })

        vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      end,
    },
  },

  -- LSP and Completion
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'j-hui/fidget.nvim', opts = {} },
      { 'folke/neodev.nvim' },
    },
    config = function()
      require('neodev').setup()

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf })
          end

          map('crn', vim.lsp.buf.rename)
          map('crr', vim.lsp.buf.code_action)

          map('gd', require('telescope.builtin').lsp_definitions)
          map('gD', vim.lsp.buf.declaration)
          map('gt', require('telescope.builtin').lsp_type_definitions)
          map('gr', require('telescope.builtin').lsp_references)
          map('gI', require('telescope.builtin').lsp_implementations)
          map('<leader>o', require('telescope.builtin').lsp_document_symbols)
          map('<leader>t', require('telescope.builtin').lsp_dynamic_workspace_symbols)

          map('<C-k>', vim.lsp.buf.signature_help, { 'i', 'n' })
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        ts_ls = {},
        html = { filetypes = { 'html', 'twig', 'hbs' } },
        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      }

      local mason_lspconfig = require 'mason-lspconfig'

      mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
      }

      local handlers = {
        ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' }),
        ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' }),
      }

      vim.diagnostic.config {
        float = { border = 'single' },
        severity_sort = true,
        virtual_text = false,
      }

      mason_lspconfig.setup_handlers {
        function(server_name)
          local server = servers[server_name] or {}
          server.handlers = handlers
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      }
    end,
  },

  {
    -- Formatter
    'stevearc/conform.nvim',
    config = function()
      local conform = require 'conform'

      conform.setup {
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'isort', 'black' },
          typescript = { 'prettierd', 'prettier', stop_after_first = true },
          typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        },
      }

      vim.keymap.set('n', '<leader>f', function()
        conform.format { async = true }
      end)
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
    config = function()
      local cmp = require 'cmp'
      cmp.setup {
        window = {
          documentation = cmp.config.window.bordered {
            winhighlight = 'Normal:NormalFloat',
            border = 'single',
          },
        },
        preselect = cmp.PreselectMode.None,
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm { select = true },
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'nvim_lsp_signature_help' },
        },
      }
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
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
      vim.api.nvim_set_hl(0, 'TelescopeNormal', { link = 'NormalFloat' })

      pcall(require('telescope').load_extension, 'fzf')
      local actions = require 'telescope.actions'
      require('telescope').setup {
        defaults = {
          file_ignore_patterns = { 'node_modules' },
          path_display = { 'truncate' },
          borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
          layout_strategy = 'vertical',
          vimgrep_arguments = {
            'rg',
            '--multiline',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
          },
        },
        pickers = {
          lsp_references = { show_line = false },
          find_files = { previewer = false, hidden = true },
          buffers = {
            previewer = false,
            ignore_current_buffer = true,
            -- sort_lastused = true,
            sort_mru = true,
            mappings = { i = { ['<c-d>'] = actions.delete_buffer } },
          },
        },
      }

      vim.keymap.set('n', '<C-f>', require('telescope.builtin').buffers)
      vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files)
      vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_status)
      vim.keymap.set('n', '<leader>gs', require('telescope.builtin').grep_string)
      vim.keymap.set('n', '<leader>lg', require('telescope.builtin').live_grep)
      vim.keymap.set('n', '<leader>d', require('telescope.builtin').diagnostics)
      vim.keymap.set('n', '<leader>re', require('telescope.builtin').resume)
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',

    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-context',
        config = function()
          vim.api.nvim_set_hl(0, 'TreesitterContext', { bg = 'NONE' })
          vim.api.nvim_set_hl(0, 'TreesitterContextSeparator', { link = 'LineNr' })
          vim.keymap.set('n', '[t', function()
            require('treesitter-context').go_to_context(vim.v.count1)
          end, { silent = true })
          require('treesitter-context').setup {
            max_lines = 3,
            trim_scope = 'inner',
            separator = '─',
          }
        end,
      },
      'nvim-treesitter/nvim-treesitter-textobjects',
      {
        'Wansmer/treesj',
        config = function()
          require('treesj').setup { use_default_keymaps = false }

          vim.keymap.set('n', '<leader>m', require('treesj').toggle)
          vim.keymap.set('n', '<leader>M', function()
            require('treesj').toggle { split = { recursive = true } }
          end)
        end,
      },
      { 'folke/ts-comments.nvim', opts = {}, event = 'VeryLazy' },
      { 'windwp/nvim-ts-autotag', opts = {} },
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
        auto_install = true,
        modules = {},
        ignore_install = {},
        sync_install = false,
        highlight = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true,
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
        },
      }
    end,
  },

  {
    'echasnovski/mini.files',
    version = false,
    config = function()
      require('mini.files').setup()

      _G.minifiles_toggle = function(...)
        if not MiniFiles.close() then
          MiniFiles.open(...)
          MiniFiles.reveal_cwd()
        end
      end

      vim.keymap.set('n', '<leader>n', ':lua _G.minifiles_toggle(vim.api.nvim_buf_get_name(0))<CR>')
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    config = function()
      local active_hl = { bg = 'NvimDarkGrey3', fg = 'NvimLightGrey2' }
      local inactive_hl = { bg = 'NvimDarkGrey1', fg = 'NvimLightGrey2' }

      vim.api.nvim_set_hl(0, 'StatusLine', active_hl)
      vim.api.nvim_set_hl(0, 'StatusLineNC', inactive_hl)

      local lualine_theme = {
        normal = { a = active_hl, b = active_hl, c = active_hl },
        inactive = { c = inactive_hl },
      }

      require('lualine').setup {
        options = {
          theme = lualine_theme,
          icons_enabled = false,
          component_separators = '',
        },
        sections = {
          lualine_a = {},
          lualine_b = { 'branch', 'diff' },
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = { 'diagnostics' },
        },
        inactive_sections = { lualine_c = { { 'filename', path = 1 } } },
      }
    end,
  },
}, {})
