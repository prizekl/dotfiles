-- [[ Core settings ]]

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- Search in visual mode selection '<Esc>/\\%V')
-- vim.keymap.set('n', '/', 'mf/')
-- go to end of search match //e

vim.wo.number = true
vim.wo.signcolumn = 'yes'
vim.opt.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.o.undofile = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.swapfile = false
vim.o.termguicolors = true
vim.api.nvim_command 'packadd Cfilter'

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
  --- Text Editing ---
  { 'tpope/vim-surround', keys = { 'ds', 'cs', 'ys', { 'S', mode = 'v' } } },

  --- AI ---
  { 'supermaven-inc/supermaven-nvim', opts = { ignore_filetypes = { 'TelescopePrompt', 'text' } } },
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    keys = {
      { '<leader>s', '<cmd>CodeCompanionChat Toggle<cr>', mode = 'n', noremap = true, silent = true },
      { '<leader>ae', '<cmd>CodeCompanionChat Add<cr>', mode = 'v', noremap = true, silent = true },
      { '<leader>ac', '<cmd>CodeCompanionChat<cr>', mode = { 'n', 'v' }, noremap = true, silent = true },
    },
    opts = {
      display = { chat = { window = { width = 0.25 } } },
      strategies = {
        chat = {
          slash_commands = {
            ['buffer'] = { opts = { provider = 'telescope' } },
            ['file'] = { opts = { provider = 'telescope' } },
            ['symbols'] = { opts = { provider = 'telescope' } },
          },
          keymaps = {
            pin = { modes = { n = 'gb' }, index = 9, callback = 'keymaps.pin_reference' },
            next_chat = { modes = { n = 'gn' }, index = 11, callback = 'keymaps.next_chat' },
            previous_chat = { modes = { n = 'gp' }, index = 12, callback = 'keymaps.previous_chat' },
            completion = { modes = { i = '<C-/>' }, index = 1, callback = 'keymaps.completion' },
          },
          adapter = 'anthropic',
        },
        inline = { adapter = 'anthropic' },
      },
    },
  },

  --- Git ---
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    opts = {
      default_args = { DiffviewOpen = { '--imply-local' } },
      view = { merge_tool = { layout = 'diff1_plain', disable_diagnostics = false } },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'
        local function map_key(modes, lhs, rhs)
          vim.keymap.set(modes, lhs, rhs, { buffer = bufnr })
        end

        local function map_hunk_navigation(key, direction)
          map_key('n', key, function()
            if vim.wo.diff then
              vim.cmd.normal { key, bang = true }
            else
              gitsigns.nav_hunk(direction)
            end
          end)
        end

        map_hunk_navigation(']c', 'next')
        map_hunk_navigation('[c', 'prev')
        map_key('n', '<leader>hp', gitsigns.preview_hunk)
        map_key('n', '<leader>hs', gitsigns.stage_hunk)
        map_key('n', '<leader>hr', gitsigns.reset_hunk)
        map_key('n', '<leader>hR', gitsigns.reset_buffer)
        map_key('n', '<leader>hd', gitsigns.diffthis)
        map_key({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        map_key('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end)
        map_key('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end)
      end,
    },
  },

  --- LSP ---
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

          map('gd', require('telescope.builtin').lsp_definitions)
          map('gD', vim.lsp.buf.declaration)
          map('grt', require('telescope.builtin').lsp_type_definitions)
          map('grr', require('telescope.builtin').lsp_references)
          map('gri', require('telescope.builtin').lsp_implementations)
          map('gO', require('telescope.builtin').lsp_document_symbols)
          map('<leader>t', require('telescope.builtin').lsp_dynamic_workspace_symbols)

          map('<C-k>', vim.lsp.buf.signature_help, { 'i', 'n' })
        end,
      })

      local servers = {
        ts_ls = {
          commands = {
            OrganizeImports = {
              function()
                local bufnr = vim.api.nvim_get_current_buf()
                local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'ts_ls' })[1]
                client:exec_cmd { title = 'Orgnize Imports', command = '_typescript.organizeImports', arguments = { vim.fn.expand '%:p' } }
              end,
            },
          },
        },
        html = { filetypes = { 'html', 'twig', 'hbs' } },
        gopls = {},
        pyright = {},
        lua_ls = { settings = { Lua = { diagnostics = { disable = { 'missing-fields' } } } } },
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local mason_lspconfig = require 'mason-lspconfig'
      mason_lspconfig.setup { ensure_installed = vim.tbl_keys(servers) }
      mason_lspconfig.setup_handlers {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      }
    end,
  },
  {
    'stevearc/conform.nvim',
    keys = { {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
    } },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
      },
    },
  },

  --- File Navigation ---
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
    'nvim-telescope/telescope.nvim',
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
      -- Temporary fix for https://github.com/nvim-telescope/telescope.nvim/issues/3436
      vim.api.nvim_create_autocmd('User', {
        pattern = 'TelescopeFindPre',
        callback = function()
          vim.opt_local.winborder = 'none'
          vim.api.nvim_create_autocmd('WinLeave', {
            once = true,
            callback = function()
              vim.opt_local.winborder = 'single'
            end,
          })
        end,
      })

      pcall(require('telescope').load_extension, 'fzf')
      require('telescope').setup {
        defaults = {
          path_display = { 'truncate' },
          borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
          layout_strategy = 'vertical',
          vimgrep_arguments = { 'rg', '--multiline', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' },
        },
        pickers = {
          lsp_references = { show_line = false },
          find_files = { previewer = false, hidden = true },
          buffers = {
            previewer = false,
            ignore_current_buffer = true,
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

  --- Treesitter ---
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
            multiwindow = true,
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
    opts = { ensure_installed = 'all', auto_install = true, sync_install = false, indent = { enable = true } },
  },
}, {})

-- [[ Diagnostics ]]

vim.diagnostic.config { jump = { float = true }, severity_sort = true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- [[ Completion & LSP ]]

vim.o.completeopt = 'menuone,noselect,noinsert,popup'
vim.keymap.set('i', '<CR>', function()
  return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
end, { expr = true })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    client.server_capabilities.completionProvider.triggerCharacters = vim.split('qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM. ', '')
    vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
  end,
})

vim.api.nvim_create_autocmd('LspDetach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    vim.lsp.completion.enable(false, client.id, args.buf)
  end,
})

-- [[ Utilities ]]

vim.api.nvim_create_user_command('RelPath', function()
  local filepath = vim.fn.expand '%'
  vim.fn.setreg('+', filepath)
end, {})

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Typescript compiling
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'typescript', 'typescriptreact' },
  callback = function()
    vim.cmd.compiler 'tsc'
  end,
})

-- [[ UI Settings ]]

vim.opt.showmode = false
vim.opt.shortmess:append 'c'
vim.o.winborder = 'single'

local function match_words()
  vim.cmd "syntax match Priority '\\[!\\]'"
  vim.cmd "syntax match Ongoing '\\[o\\]'"
  vim.cmd "syntax match Done '\\[x\\]'"
  vim.cmd "syntax match Cancelled '\\[\\~\\]'"
  vim.cmd "syntax match Time '\\*\\*[^\\*]\\+\\*\\*'"
  vim.cmd "syntax match Heading '#.*'"
end

vim.api.nvim_create_autocmd({ 'BufReadPost', 'InsertLeave' }, {
  pattern = '*.txt',
  callback = match_words,
})

vim.api.nvim_set_hl(0, 'Priority', { fg = 'red' })
vim.api.nvim_set_hl(0, 'Ongoing', { fg = 'orange' })
vim.api.nvim_set_hl(0, 'Done', { fg = 'green' })
vim.api.nvim_set_hl(0, 'Cancelled', { fg = 'magenta' })
vim.api.nvim_set_hl(0, 'Time', { fg = 'pink' })
vim.api.nvim_set_hl(0, 'Heading', { bold = true })

vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'NvimDarkGrey3', fg = 'NvimLightGrey2' })
vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = 'NvimDarkGrey1', fg = 'NvimLightGrey3' })
vim.api.nvim_set_hl(0, 'WinSeparator', { link = 'LineNr' })
vim.api.nvim_set_hl(0, 'DiffAdd', { bg = 'NvimDarkGreen' })
vim.api.nvim_set_hl(0, 'DiffChange', { bg = 'NvimDarkGrey4' })
vim.api.nvim_set_hl(0, 'TelescopeNormal', { link = 'NormalFloat' })

-- [[ Statusline ]]
-- inspired by Helix's statusline
-- adapted from MariaSol0s https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lua/statusline.lua
-- ripped mode map from lualine https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/utils/mode.lua

local DIAGNOSTIC_ICONS = { ERROR = 'E:', WARN = 'W:', INFO = 'I:', HINT = 'H:' }
local SEVERITY_ORDER = { 'ERROR', 'WARN', 'HINT', 'INFO' }
local MODE_ALIASES = {
  NORMAL = { 'n', 'no', 'nov', 'noV', 'no\22', 'niI', 'niR', 'niV', 'nt', 'ntT' },
  VISUAL = { 'v', 'vs' },
  ['V-LINE'] = { 'V', 'Vs' },
  ['V-BLOCK'] = { '\22', '\22s' },
  SELECT = { 's' },
  ['S-LINE'] = { 'S' },
  ['S-BLOCK'] = { '\19' },
  INSERT = { 'i', 'ic', 'ix' },
  REPLACE = { 'R', 'Rc', 'Rx', 'r', 'r?' },
  ['V-REPLACE'] = { 'Rv', 'Rvc', 'Rvx' },
  COMMAND = { 'c' },
  EX = { 'cv', 'ce' },
  MORE = { 'rm' },
  CONFIRM = { 'r?' },
  SHELL = { '!' },
  TERMINAL = { 't' },
}
local MODE_MAP = {}
for pretty, codes in pairs(MODE_ALIASES) do
  for _, c in ipairs(codes) do
    MODE_MAP[c] = pretty
  end
end

local M = {}
M.diagnostic_counts = {}
M.diagnostic_cache = {}
M.highlight_cache = {}

function M.get_color(name, attr)
  return string.format('#%06x', vim.api.nvim_get_hl(0, { name = name, link = false })[attr])
end

function M.create_hl(hl, is_active)
  local hl_name = 'StatusLine' .. hl .. (is_active and 'Active' or 'Inactive')
  if M.highlight_cache[hl_name] then
    return hl_name
  end

  local bg_group = is_active and 'StatusLine' or 'StatusLineNC'

  vim.api.nvim_set_hl(0, hl_name, { bg = M.get_color(bg_group, 'bg'), fg = M.get_color(hl, 'fg') })
  M.highlight_cache[hl_name] = true
  return hl_name
end

function M.update_diagnostic_counts(bufnr)
  local counts = vim.iter(vim.diagnostic.get(bufnr)):fold({}, function(acc, diagnostic)
    local severity = vim.diagnostic.severity[diagnostic.severity]
    acc[severity] = (acc[severity] or 0) + 1
    return acc
  end)

  M.diagnostic_counts[bufnr] = counts
end

function M.get_diagnostics_component(bufnr, is_active)
  if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
    return M.diagnostic_cache[bufnr] or ''
  end

  local counts = M.diagnostic_counts[bufnr]
  if counts == nil then
    return ''
  end

  local parts = {}
  for _, severity in ipairs(SEVERITY_ORDER) do
    local count = counts[severity] or 0
    if count > 0 then
      local hl = 'Diagnostic' .. severity
      table.insert(parts, '%#' .. M.create_hl(hl, is_active) .. '#' .. DIAGNOSTIC_ICONS[severity] .. count)
    end
  end

  local diagnostics_str = table.concat(parts or {}, ' ') .. (is_active and '%#StatusLine#' or '%#StatusLineNC#')
  M.diagnostic_cache[bufnr] = diagnostics_str
  return diagnostics_str
end

function M.get_mode_component()
  local m = vim.api.nvim_get_mode().mode
  return MODE_MAP[m] or m
end

function M.render_statusline()
  local active_winid = vim.api.nvim_get_current_win()
  local status_winid = vim.g.statusline_winid
  local is_active = (active_winid == status_winid)

  local bufnr = vim.api.nvim_win_get_buf(status_winid)
  local diagnostics = M.get_diagnostics_component(bufnr, is_active)
  local mode = M.get_mode_component()

  local pad = '\x20'

  local components =
    { pad, is_active and (mode:sub(1, 3) .. pad:rep(3)) or pad:rep(6), '%<%f %h%m%r', '%=', diagnostics, pad:rep(3), '%l/%L,%c%V%', pad:rep(2) }

  return table.concat(components)
end

_G.render_statusline = M.render_statusline
vim.o.statusline = '%!v:lua.render_statusline()'

vim.api.nvim_create_autocmd('DiagnosticChanged', {
  callback = function(args)
    M.update_diagnostic_counts(args.buf)
    vim.cmd 'redrawstatus!'
  end,
})
