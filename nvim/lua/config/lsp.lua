require("mason").setup()

-- LSP servers and clients are able to communicate to each other what features they support.
--  By default, Neovim doesn't support everything that is in the LSP specification.
--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.

require('cmp').setup {
	sources = {
		{ name = 'nvim_lsp' }
	}
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

local servers = {
	lua_ls = {},
	angularls = {},
	bashls = {},
	cssls = {},
	dockerls = {},
	html = {},
	eslint = {},
	ts_ls = {},
	jdtls = {},
	yamlls = {}
	-- jsonls = {},
	-- pylsp = {},
	-- sqls = {},
}

require("mason-lspconfig").setup {
	ensure_installed = vim.tbl_keys(servers or {}),
	handlers = {
		function(server_name)
			local server = servers[server_name] or {}

			-- This handles overriding only values explicitly passed
			-- by the server configuration above. Useful when disabling
			-- certain features of an LSP (for example, turning off formatting for ts_ls)
			server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
			require('lspconfig')[server_name].setup(server)
		end
	},
}

-- LSP Auto commands

vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP actions',
	group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or 'n'
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
		end

		-- Telescope lsp built-ins documentation: https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#neovim-lsp-pickers
		-- Jump to the definition
		map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

		-- Lists all the implementations for the symbol under the cursor
		map('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementations')

		-- Fuzzy find all the symbols in your current document.
		map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

		-- Fuzzy find all the symbols in your current workspace.
		map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

		-- Lists all the references
		map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

		-- Displays hover information about the symbol under the cursor
		map('K', vim.lsp.buf.hover, 'Displays hover information for the symbol under the cursor')

		-- Renames all references to the symbol under the cursor
		map('<F2>', vim.lsp.buf.rename, 'Rename symbol')

		-- Selects a code action available at the current cursor position
		map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

		-- Move to the previous diagnostic
		map('[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', '[G]oto []')

		-- Move to the next diagnostic
		map(']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', '[G]oto []')

		-- Displays a function's signature information
		map('gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', '[G]oto function [S]ignature')

		-- Jump to declaration. Note this is not definition, it'll take you to the header of the file for most languages.
		map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
	end
})

-- Snippets engine
require('luasnip.loaders.from_vscode').lazy_load({
	paths = '~/.config/nvim/snippets/vscode'
})
require('luasnip.loaders.from_vscode').lazy_load()

-- Autocomplete configuration
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

local cmp = require('cmp')
local luasnip = require('luasnip')
local select_opts = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end
	},
	sources = {
		{ name = 'path' },
		{ name = 'nvim_lsp',      keyword_length = 1 },
		{ name = 'buffer',        keyword_length = 3 },
		{ name = 'luasnip',       keyword_length = 2 },
		{ name = 'luasnip_choice' },
	},
	window = {
		documentation = cmp.config.window.bordered()
	},
	formatting = {
		fields = { 'menu', 'abbr', 'kind' },
		format = function(entry, item)
			local menu_icon = {
				nvim_lsp = 'λ',
				luasnip = '⋗',
				luasnip_choice = '⋗',
				buffer = 'Ω',
				path = '🖫',
			}

			item.menu = menu_icon[entry.source.name]
			return item
		end,
	},
	mapping = {
		['<Up>'] = cmp.mapping.select_prev_item(select_opts),
		['<Down>'] = cmp.mapping.select_next_item(select_opts),

		['<S-Tab>'] = cmp.mapping.select_prev_item(select_opts),
		['<Tab>'] = cmp.mapping.select_next_item(select_opts),

		['<C-u>'] = cmp.mapping.scroll_docs(-4),
		['<C-d>'] = cmp.mapping.scroll_docs(4),

		['<C-e>'] = cmp.mapping.abort(),
		['<C-y>'] = cmp.mapping.confirm({ select = true }),
		['<CR>'] = cmp.mapping.confirm({ select = false }),

		['<C-n>'] = cmp.mapping(function(fallback)
			if luasnip.jumpable(1) then
				luasnip.jump(1)
			else
				fallback()
			end
		end, { 'i', 's' }),

		['<C-p>'] = cmp.mapping(function(fallback)
			if luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { 'i', 's' }),

		['<C-l>'] = cmp.mapping(function(fallback)
			if luasnip.choice_active() then
				luasnip.change_choice(1)
			end
		end, { 'i', 's' }),

		['<C-h>'] = cmp.mapping(function(fallback)
			if luasnip.choice_active() then
				luasnip.change_choice(-1)
			end
		end, { 'i', 's' }),
	},
})
