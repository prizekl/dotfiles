vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.api.nvim_set_keymap('n', '<c-l>', '<nop>', { noremap = true, silent = true })

vim.wo.number = true
vim.opt.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.completeopt = 'menuone,noselect'
vim.o.undofile = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.swapfile = false
vim.api.nvim_command 'packadd Cfilter'

-- Floats are disabled by default: https://github.com/neovim/neovim/pull/16230
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- [[ Colorscheme ]]
vim.o.termguicolors = true
vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })

-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Statusline ]]
vim.api.nvim_set_hl(0, 'StatusLine', { bg = '#343434', fg = 'white' })
vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = '#000000', fg = 'lightgrey' })
vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#343434' })

vim.opt.showmode = false
vim.opt.showcmd = false

-- adapted from MariaSol0s https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lua/statusline.lua

local M = {}

M.diagnostic_cache = {}
M.highlight_cache = {}

local DIAGNOSTIC_ICONS = { ERROR = 'E:', WARN = 'W:', INFO = 'I:', HINT = 'H:' }
local SEVERITY_ORDER = { 'ERROR', 'WARN', 'HINT', 'INFO' }

function M.get_diagnostics_component(bufnr, is_active)
  if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
    return M.diagnostic_cache[bufnr] or ''
  end

  local counts = vim.iter(vim.diagnostic.get(bufnr)):fold({}, function(acc, diagnostic)
    local severity = vim.diagnostic.severity[diagnostic.severity]
    acc[severity] = (acc[severity] or 0) + 1
    return acc
  end)

  local parts = {}

  for _, severity in ipairs(SEVERITY_ORDER) do
    local count = counts[severity] or 0
    if count > 0 then
      local hl = 'Diagnostic' .. severity
      table.insert(parts, string.format('%%#%s#%s%d', M.create_hl(hl, is_active), DIAGNOSTIC_ICONS[severity], count))
    end
  end

  local diagnostics_str = table.concat(parts, ' ')

  diagnostics_str = diagnostics_str .. (is_active and '%#StatusLine#' or '%#StatusLineNC#')

  M.diagnostic_cache[bufnr] = diagnostics_str
  return diagnostics_str
end

function M.create_hl(hl, is_active)
  local hl_name = 'StatusLine' .. hl .. (is_active and 'Active' or 'Inactive')
  if M.highlight_cache[hl_name] then
    return hl_name
  end

  local bg_group = is_active and 'StatusLine' or 'StatusLineNC'
  local bg_hl = vim.api.nvim_get_hl(0, { name = bg_group })
  local fg_hl = vim.api.nvim_get_hl(0, { name = hl })

  vim.api.nvim_set_hl(0, hl_name, { bg = ('#%06x'):format(bg_hl.bg), fg = ('#%06x'):format(fg_hl.fg) })

  return hl_name
end

-- Ripped from lualine https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/utils/mode.lua

local MODE_MAP = {
  ['n'] = 'NORMAL',
  ['no'] = 'O-PENDING',
  ['nov'] = 'O-PENDING',
  ['noV'] = 'O-PENDING',
  ['no\22'] = 'O-PENDING',
  ['niI'] = 'NORMAL',
  ['niR'] = 'NORMAL',
  ['niV'] = 'NORMAL',
  ['nt'] = 'NORMAL',
  ['ntT'] = 'NORMAL',
  ['v'] = 'VISUAL',
  ['vs'] = 'VISUAL',
  ['V'] = 'V-LINE',
  ['Vs'] = 'V-LINE',
  ['\22'] = 'V-BLOCK',
  ['\22s'] = 'V-BLOCK',
  ['s'] = 'SELECT',
  ['S'] = 'S-LINE',
  ['\19'] = 'S-BLOCK',
  ['i'] = 'INSERT',
  ['ic'] = 'INSERT',
  ['ix'] = 'INSERT',
  ['R'] = 'REPLACE',
  ['Rc'] = 'REPLACE',
  ['Rx'] = 'REPLACE',
  ['Rv'] = 'V-REPLACE',
  ['Rvc'] = 'V-REPLACE',
  ['Rvx'] = 'V-REPLACE',
  ['c'] = 'COMMAND',
  ['cv'] = 'EX',
  ['ce'] = 'EX',
  ['r'] = 'REPLACE',
  ['rm'] = 'MORE',
  ['r?'] = 'CONFIRM',
  ['!'] = 'SHELL',
  ['t'] = 'TERMINAL',
}

function M.get_mode_component()
  local mode_code = vim.api.nvim_get_mode().mode
  if MODE_MAP[mode_code] == nil then
    return mode_code
  end
  return MODE_MAP[mode_code]
end

function M.render_statusline()
  local active_winid = vim.api.nvim_get_current_win()
  local status_winid = vim.g.statusline_winid
  local is_active = (active_winid == status_winid)

  local bufnr = vim.api.nvim_win_get_buf(status_winid)
  local diagnostics = M.get_diagnostics_component(bufnr, is_active)
  local mode = M.get_mode_component()

  local pad = '\x20'

  local components = {
    pad,
    is_active and (mode:sub(1, 3) .. pad:rep(3)) or pad:rep(6),
    '%<%f %h%m%r',
    '%=',
    diagnostics,
    pad:rep(3),
    '%l/%L,%c%V%',
    pad:rep(2),
  }

  return table.concat(components)
end

_G.render_statusline = M.render_statusline
vim.o.statusline = '%!v:lua.render_statusline()'

vim.api.nvim_create_autocmd('DiagnosticChanged', {
  callback = function()
    vim.cmd 'redrawstatus!'
  end,
})

-- [[ Plugins ]]

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
  { 'tpope/vim-abolish', cmd = { 'S', 'Abolish', 'Subvert' } },
  { 'tpope/vim-surround', keys = { 'ds', 'cs', 'ys', { 'S', mode = 'v' } } },
  {
    'm4xshen/autoclose.nvim',
    event = 'InsertEnter',
    opts = { options = {
      disabled_filetypes = { 'TelescopePrompt' },
      disable_command_mode = true,
    } },
  },

  -- Git
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    opts = {
      view = { merge_tool = { layout = 'diff1_plain', disable_diagnostics = false } },
    },
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
    keys = { {
      '<leader>f',
      function()
        require('conform').format { async = true }
      end,
    } },
    config = function()
      require('conform').setup {
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'isort', 'black' },
          typescript = { 'prettierd', 'prettier', stop_after_first = true },
          typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
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
      require('telescope').setup {
        defaults = {
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
            mappings = { i = { ['<c-d>'] = require('telescope.actions').delete_buffer } },
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
            multiline_threshold = 1,
            separator = '─',
          }
        end,
      },
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
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = 'all',
      auto_install = true,
      sync_install = false,
      highlight = {
        enable = true,
        disable = function(_, buf)
          local max_filesize = 1000 * 1024 -- 1 MB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          return ok and stats and stats.size > max_filesize
        end,
      },
      indent = { enable = true },
    },
  },

  {
    'echasnovski/mini.files',
    keys = {
      {
        '<leader>n',
        function()
          require('mini.files').open(vim.api.nvim_buf_get_name(0), false)
          require('mini.files').reveal_cwd()
        end,
      },
    },
    opts = {},
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    config = function()
      vim.keymap.set('n', '<leader>rm', require('render-markdown').toggle)

      vim.api.nvim_set_hl(0, 'Done', { fg = 'green' })
      vim.api.nvim_set_hl(0, 'Priority', { fg = 'red' })
      vim.api.nvim_set_hl(0, 'Ongoing', { fg = 'orange' })
      vim.api.nvim_set_hl(0, 'Postponed', { fg = 'magenta' })

      require('render-markdown').setup {
        overrides = { buftype = { nofile = { enabled = false } } },
        checkbox = {
          unchecked = { highlight = 'Normal' },
          checked = { highlight = 'Done' },
          custom = {
            ongoing = { raw = '[o]', rendered = '󰄱 ', highlight = 'Ongoing' },
            priority = { raw = '[!]', rendered = '󰄱 ', highlight = 'Priority' },
            cancelled = { raw = '[~]', rendered = '󰄱 ', highlight = 'Postponed' },
          },
        },
      }
    end,
  },
}, {})

-- Typescript compiling
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'typescript', 'typescriptreact' },
  callback = function()
    vim.cmd.compiler 'tsc'
  end,
})
