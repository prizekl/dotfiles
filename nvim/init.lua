-- Search in visual mode selection: '<Esc>/\\%V'
-- No eager: \{-}, Start of match: \zs, End of match: \ze
-- Word boundary left: \< Word boundary right: \>
-- case sensitive: PCRE (?-i), multiline: \s*

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.wo.number = true
vim.wo.signcolumn = 'yes'
vim.o.clipboard = 'unnamedplus'
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
vim.opt.showmode = false
vim.opt.shortmess:append 'c'
vim.o.winborder = 'rounded'

vim.o.completeopt = 'menuone,noselect,noinsert,popup'
vim.keymap.set('i', '<CR>', function()
    return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
end, { expr = true })

vim.api.nvim_create_user_command('RelPath', function()
    vim.fn.setreg('+', vim.fn.expand '%')
end, {})

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' },
    { command = "if mode() != 'c' | checktime | endif" })

vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

local function gh(repo) return 'https://github.com/' .. repo end

vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if kind ~= 'install' and kind ~= 'update' then
            return
        end
        if name == 'nvim-treesitter' then
            require('nvim-treesitter.install').update({}, { summary = true })
        end
    end,
})

vim.pack.add {
    gh 'tpope/vim-surround',
    gh 'zbirenbaum/copilot.lua',
    gh 'sindrets/diffview.nvim',
    gh 'lewis6991/gitsigns.nvim',
    gh 'neovim/nvim-lspconfig',
    gh 'mason-org/mason.nvim',
    gh 'mason-org/mason-lspconfig.nvim',
    gh 'j-hui/fidget.nvim',
    gh 'folke/lazydev.nvim',
    gh 'stevearc/conform.nvim',
    gh 'stevearc/oil.nvim',
    gh 'ibhagwan/fzf-lua',
    gh 'nvim-mini/mini.icons',
    gh 'nvim-treesitter/nvim-treesitter-context',
    gh 'Wansmer/treesj',
    gh 'folke/ts-comments.nvim',
    gh 'windwp/nvim-ts-autotag',
    { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' },
}

require('copilot').setup {
    suggestion = { auto_trigger = true, hide_during_completion = false, keymap = { accept = '<tab>' } },
}

require('diffview').setup {
    default_args = { DiffviewOpen = { '--imply-local' } },
    view = { merge_tool = { layout = 'diff1_plain', disable_diagnostics = false } },
}
vim.keymap.set('n', '<leader>go', ':DiffviewOpen<CR>')
vim.keymap.set('n', '<leader>gc', ':DiffviewClose<CR>')
vim.keymap.set({ 'n', 'v' }, '<leader>gh', ':DiffviewFileHistory %<CR>')

require('gitsigns').setup {
    on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'
        local opts = { buffer = bufnr }
        local function map_hunk_navigation(key, direction)
            vim.keymap.set('n', key, function()
                if vim.wo.diff then
                    vim.cmd.normal { key, bang = true }
                else
                    gitsigns.nav_hunk(direction)
                end
            end, opts)
        end

        map_hunk_navigation(']c', 'next')
        map_hunk_navigation('[c', 'prev')
        vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, opts)
        vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, opts)
        vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, opts)
        vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, opts)
        vim.keymap.set('n', '<leader>hd', gitsigns.diffthis, opts)
        vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {
            buffer = bufnr,
        })
        vim.keymap.set('v', '<leader>hs', function()
            gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, opts)
        vim.keymap.set('v', '<leader>hr', function()
            gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, opts)
    end,
}

require('mini.icons').setup()
require('mini.icons').mock_nvim_web_devicons()
require('mason').setup()
require('fidget').setup {}
require('lazydev').setup { library = { { path = '${3rd}/luv/library' } } }

local servers = {
    ts_ls = {
        on_attach = function(client)
            vim.api.nvim_buf_create_user_command(0, 'OrganizeImports', function()
                client:exec_cmd {
                    command = '_typescript.organizeImports',
                    arguments = { vim.fn.expand '%:p' },
                }
            end, {})
        end,
    },
    html = { filetypes = { 'html', 'twig', 'hbs' } },
    gopls = {},
    pyright = {},
    lua_ls = {},
}
for name, opts in pairs(servers) do vim.lsp.config(name, opts) end
require('mason-lspconfig').setup { ensure_installed = vim.tbl_keys(servers) }

require('conform').setup {
    formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
    },
}
vim.keymap.set('n', '<leader>f', function()
    require('conform').format { async = true, lsp_format = 'fallback' }
end)

require('oil').setup { view_options = { show_hidden = true } }
vim.keymap.set('n', '<leader>n', '<CMD>Oil<CR>')

local fzf_lua = require 'fzf-lua'
fzf_lua.setup {
    winopts = { preview = { layout = 'vertical' } },
    grep = { rg_opts = '--column --line-number --no-heading --color=always --smart-case --multiline' },
    keymap = { builtin = {
        ['<C-d>'] = 'preview-page-down',
        ['<C-u>'] = 'preview-page-up',
    },
    },
}

vim.keymap.set('n', '<C-f>', function()
    fzf_lua.buffers { previewer = false, ignore_current_buffer = true, sort_lastused = true }
end)
vim.keymap.set('n', '<C-p>', function()
    fzf_lua.files { fd_opts = '--color=never --type f --type l --hidden --exclude .git' }
end)
vim.keymap.set('n', '<leader>gf', fzf_lua.git_status)
vim.keymap.set('n', '<leader>lg', fzf_lua.live_grep)
vim.keymap.set('n', '<leader>d', fzf_lua.diagnostics_workspace)
vim.keymap.set('n', '<leader>re', fzf_lua.resume)

require('treesitter-context').setup {
    multiwindow = true,
    multiline_threshold = 1,
    separator = '─',
}
vim.keymap.set('n', '[t', function()
    require('treesitter-context').go_to_context(vim.v.count1)
end, { silent = true })

require('treesj').setup { use_default_keymaps = false }
vim.keymap.set('n', '<leader>m', require('treesj').toggle)
vim.keymap.set('n', '<leader>M', function()
    require('treesj').toggle { split = { recursive = true } }
end)

require('ts-comments').setup()
require('nvim-ts-autotag').setup {}

vim.api.nvim_create_autocmd('FileType', {
    callback = function() pcall(vim.treesitter.start) end
})

vim.diagnostic.config { jump = { float = true }, severity_sort = true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setqflist)

local ascii_triggers = {}
for i = 32, 126 do ascii_triggers[#ascii_triggers + 1] = string.char(i) end
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('native-lsp-completion', { clear = true }),
    callback = function(e)
        local client = vim.lsp.get_client_by_id(e.data.client_id)
        if client and client:supports_method 'textDocument/completion' then
            client.server_capabilities.completionProvider.triggerCharacters = ascii_triggers
            vim.lsp.completion.enable(true, client.id, e.buf, { autotrigger = true })
        end
    end,
})

vim.api.nvim_create_autocmd('LspDetach', {
    callback = function(e)
        vim.lsp.completion.enable(false, e.data.client_id, e.buf)
    end,
})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('keymaps-lsp-attach', { clear = true }),
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set('n', 'gd', fzf_lua.lsp_definitions, opts)
        vim.keymap.set('n', 'grr', fzf_lua.lsp_references, opts)
        vim.keymap.set('n', 'gri', fzf_lua.lsp_implementations, opts)
        vim.keymap.set('n', 'grt', fzf_lua.lsp_typedefs, opts)
        vim.keymap.set('n', 'gO', fzf_lua.lsp_document_symbols, opts)
        vim.keymap.set('n', '<leader>t', fzf_lua.lsp_live_workspace_symbols, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set({ 'i', 'n' }, '<C-k>', vim.lsp.buf.signature_help, opts)
    end,
})

function _G.render_statusline()
    local status = vim.diagnostic.status(vim.api.nvim_win_get_buf(vim.g.statusline_winid))
    local d = status ~= '' and (status .. '  ') or ''
    return table.concat { '%<', '%f %h%w%m%r', '%=', d, '%-14.(%l/%L,%c%V%) %P' }
end

vim.o.statusline = '%!v:lua.render_statusline()'
