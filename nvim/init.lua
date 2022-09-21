-- init.lua
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    is_bootstrap = true
    vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
    vim.cmd([[packadd packer.nvim]])
end

require("packer").startup(function(use)
    use("wbthomason/packer.nvim")

    -- Optimizations
    use("lewis6991/impatient.nvim")
    use("dstein64/vim-startuptime")

    -- Colorscheme
    use "EdenEast/nightfox.nvim"

    -- Treesitter
    use({
        "nvim-treesitter/nvim-treesitter",
        run = function()
            require("nvim-treesitter.install").update({ with_sync = true })
        end,
    })
    -- Extended textobjects
    use("nvim-treesitter/nvim-treesitter-textobjects")

    -- Language Server Protocol
    use({ "neovim/nvim-lspconfig" })
    use({ "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim", })
    -- Non-LSP
    use({ "jose-elias-alvarez/null-ls.nvim" })

    -- Completion
    use({ "hrsh7th/nvim-cmp",
        requires = { "hrsh7th/cmp-nvim-lsp" } })
    use("hrsh7th/cmp-path")
    use("hrsh7th/cmp-buffer")
    -- Snippets
    use({ "L3MON4D3/LuaSnip",
        requires = { "saadparwaiz1/cmp_luasnip" } })
    use("rafamadriz/friendly-snippets")
    -- Additonal UI
    use({ "j-hui/fidget.nvim",
        config = function() require("fidget").setup({}) end })
    use({ "ray-x/lsp_signature.nvim" })

    -- Git support
    use({ "lewis6991/gitsigns.nvim",
        requires = { "nvim-lua/plenary.nvim" } })
    use { "sindrets/diffview.nvim",
        requires = "nvim-lua/plenary.nvim",
        config = function() require("diffview").setup({}) end }

    -- File management
    use({ "liuchengxu/vista.vim" })
    use({ "kyazdani42/nvim-tree.lua",
        requires = { "kyazdani42/nvim-web-devicons" } })

    -- Bracket shortcuts
    -- csf change surrounding function. cst change surrounding tags
    use({ "kylechui/nvim-surround",
        config = function() require("nvim-surround").setup({}) end })
    -- Comment shortcuts
    use({ "numToStr/Comment.nvim",
        config = function() require("Comment").setup({}) end })
    -- Align texts
    use({ "junegunn/vim-easy-align" })
    -- Autoclosing brackets
    use {
        "windwp/nvim-autopairs",
        config = function() require("nvim-autopairs").setup {} end
    }

    -- Editing tools
    -- reverse join
    use {
        'AckslD/nvim-trevJ.lua',
        config = 'require("trevj").setup()',
        module = 'trevj',
        setup = function()
            vim.keymap.set('n', '<leader>j', function()
                require('trevj').format_at_cursor()
            end)
        end,
    }
    -- search and replace
    use 'tpope/vim-abolish'

    -- Fuzzy finder
    use({ "nvim-telescope/telescope.nvim",
        requires = { "nvim-lua/plenary.nvim" } })
    use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })

    if is_bootstrap then
        require("packer").sync()
    end
end)

if is_bootstrap then
    print("==================================")
    print("    Plugins are being installed")
    print("    Wait until Packer completes,")
    print("       then restart nvim")
    print("==================================")
    return
end

-- Load impatient
require("impatient")

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup("Packer", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
    command = "source <afile> | PackerCompile",
    group = packer_group,
    pattern = vim.fn.expand("$MYVIMRC"),
})

vim.g.mapleader = " "
vim.o.mouse = "a"
vim.o.clipboard = "unnamed"
vim.o.breakindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.completeopt = "menuone,noselect"
vim.o.hlsearch = true
vim.wo.number = true
vim.o.termguicolors = true
vim.cmd([[colorscheme nightfox]])
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.api.nvim_create_user_command("Leaf", ":cd %:h", { bang = true })
vim.api.nvim_create_user_command("Root", ":cd %:h | cd `git rev-parse --show-toplevel`", { bang = true })
-- Make For Go
vim.keymap.set({ "n" }, "<Leader>mt", ":TmuxMakeGo<CR>", { silent = true })
vim.keymap.set({ "n" }, "<Leader>mk", ":Make<CR>", { silent = true })
vim.api.nvim_create_user_command(
    "TmuxMakeGo",
    ':!tmux run-shell -t 1 "go clean -testcache && go test %:p:h -v"',
    { bang = true }
)
vim.api.nvim_create_user_command("Make", "!go clean -testcache && go test %:p:h -v", { bang = true })

require("lsp_signature").setup({
    handler_opts = { border = "single" },
    hint_enable = false,
})

-- Gitsigns
require("gitsigns").setup({
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
            if vim.wo.diff then
                return "]c"
            end
            vim.schedule(function()
                gs.next_hunk()
            end)
            return "<Ignore>"
        end, { expr = true })

        map("n", "[c", function()
            if vim.wo.diff then
                return "[c"
            end
            vim.schedule(function()
                gs.prev_hunk()
            end)
            return "<Ignore>"
        end, { expr = true })

        -- Actions
        map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>")
        map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>")
        map("n", "<leader>hS", gs.stage_buffer)
        map("n", "<leader>hu", gs.undo_stage_hunk)
        map("n", "<leader>hR", gs.reset_buffer)
        map("n", "<leader>hp", gs.preview_hunk)
        map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
        end)
        map("n", "<leader>tb", gs.toggle_current_line_blame)
        map("n", "<leader>hd", gs.diffthis)
        map("n", "<leader>hD", function()
            gs.diffthis("~")
        end)
        map("n", "<leader>td", gs.toggle_deleted)

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
    end,
})

-- Vista
vim.g["vista_default_executive"] = "nvim_lsp"
vim.keymap.set({ "n" }, "<Leader>v", ":Vista!!<CR>", { silent = true })

-- nvim-tree
require("nvim-tree").setup({
    update_focused_file = {
        enable = true,
    },
})
vim.keymap.set({ "n" }, "<C-n>", ":NvimTreeFindFileToggle<CR>", { silent = true })

-- Telescope
require("telescope").setup({
    defaults = {
        path_display = { "smart" },
        layout_strategy = "vertical",
    },
    pickers = {
        find_files = {
            theme = "dropdown",
            previewer = false,
            hidden = true,
        },
        buffers = {
            theme = "dropdown",
            previewer = false,
            show_all_buffers = true,
            ignore_current_buffer = true,
            sort_mru = true,
            mappings = { i = { ["<c-d>"] = "delete_buffer" } },
        },
        lsp_document_symbols = {
            theme = "dropdown",
            previewer = false,
        },
    },
})

-- Enable telescope fzf native
pcall(require("telescope").load_extension, "fzf")

--Add leader shortcuts
vim.keymap.set("n", "<C-f>", require("telescope.builtin").buffers)
vim.keymap.set("n", "<C-p>", require("telescope.builtin").find_files)
vim.keymap.set("n", "<C-g>", require("telescope.builtin").git_status)
vim.keymap.set("n", "<leader>re", require("telescope.builtin").resume)
vim.keymap.set("n", "<leader>rg", require("telescope.builtin").live_grep)
vim.keymap.set("n", "<leader>rs", require("telescope.builtin").grep_string)
vim.keymap.set("n", "<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols)
vim.keymap.set("n", "<leader>s", require("telescope.builtin").lsp_document_symbols)

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "lua",
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
        "go",
    },
    highlight = {
        enable = true,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<CR>",
            scope_incremental = "<CR>",
            node_incremental = "<TAB>",
            node_decremental = "<S-TAB>",
        },
    },
    indent = {
        enable = true,
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
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
        swap = {
            enable = true,
            swap_next = {
                ['<leader>an'] = '@parameter.inner',
            },
            swap_previous = {
                ['<leader>ap'] = '@parameter.inner',
            },
        },
    },
})

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>d", vim.diagnostic.setqflist)

-- LSP settings
local on_attach = function(_, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
    vim.keymap.set("n", "<leader>ac", vim.lsp.buf.code_action, bufopts)
    vim.api.nvim_buf_create_user_command(bufnr, "Format", vim.lsp.buf.format or vim.lsp.buf.formatting,
        { desc = "Format current buffer with LSP" })
end

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

-- LSP utils
function OrgImports(wait_ms)
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
    for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
            else
                vim.lsp.buf.execute_command(r.command)
            end
        end
    end
end

require("mason").setup()
local lspconfig = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
    ensure_installed = {
        "sumneko_lua",
        "gopls",
        "pyright",
        "tsserver",
        "html",
        "cssmodules_ls",
        "cssls",
        "jsonls",
    },
})

mason_lspconfig.setup_handlers({
    function(server_name)
        require("lspconfig")[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
        })
    end,
    ["sumneko_lua"] = function()
        lspconfig.sumneko_lua.setup {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = { Lua = {
                runtime = { version = "LuaJIT", },
                diagnostics = { globals = { "vim" }, },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                },
                telemetry = {
                    enable = false,
                },
            },
            },
        }
    end,
    ["gopls"] = function()
        lspconfig.gopls.setup {
            on_attach = function(_, bufnr)

                on_attach(_, bufnr)
                vim.api.nvim_create_autocmd("BufWritePre", {
                    pattern = {
                        "*.go"
                    },
                    command = [[lua OrgImports(1000)]]
                })
            end
            ,
            capabilities = capabilities,
        }
    end
})

-- Formatter setup
require("null-ls").setup({
    sources = {
        require("null-ls").builtins.formatting.black,
    },
})

-- luasnip setup
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

-- nvim-cmp setup
local cmp = require("cmp")
if cmp ~= nil then cmp.setup({
        preselect = cmp.PreselectMode.None,
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-d>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
            }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" }),
        }),
        sources = {
            { name = "nvim_lsp" },
            { name = "path" },
            { name = "buffer" },
            { name = "luasnip" },
        },
    })
end
