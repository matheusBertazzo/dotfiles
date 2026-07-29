return {
	'saghen/blink.cmp',
	version = '1.*', -- use a tagged release so prebuilt fuzzy-matcher binaries are fetched
	dependencies = {
		'L3MON4D3/LuaSnip',
		'rafamadriz/friendly-snippets',
	},
	event = { 'InsertEnter', 'CmdlineEnter' },
	opts = {
		snippets = { preset = 'luasnip' },
		sources = {
			default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
			providers = {
				lazydev = {
					name = 'LazyDev',
					module = 'lazydev.integrations.blink',
					score_offset = 100, -- show lazydev suggestions above LSP
				},
			},
		},
		signature = { enabled = true },
		completion = {
			documentation = { auto_show = true },
		},
		keymap = {
			preset = 'none',
			['<Tab>'] = { 'select_next', 'fallback' },
			['<S-Tab>'] = { 'select_prev', 'fallback' },
			['<Down>'] = { 'select_next', 'fallback' },
			['<Up>'] = { 'select_prev', 'fallback' },
			['<CR>'] = { 'accept', 'fallback' },
			['<C-y>'] = { 'accept', 'fallback' },
			['<C-e>'] = { 'hide', 'fallback' },
			['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
			['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
			['<C-n>'] = { 'snippet_forward', 'fallback' },
			['<C-p>'] = { 'snippet_backward', 'fallback' },
			-- LuaSnip choice-node cycling (<C-l>/<C-h>) is set as standalone {i,s} keymaps
			-- in lua/config/lsp.lua, because blink only applies its built-in snippet
			-- commands (not custom functions) in select mode, where choice nodes live.
		},
	},
}
