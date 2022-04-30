local cmp = require'cmp'

cmp.setup {
	sources = {
		{ name = 'buffer' },
		{ name = 'nvim_lsp' },
		{ name = 'path' }
	},
	mapping = cmp.mapping.preset.insert({
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		['<tab>'] = cmp.mapping.select_next_item(),
		['<S-tab>'] = cmp.mapping.select_prev_item(),
	}),
}
