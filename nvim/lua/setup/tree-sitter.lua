local large_files = require('config.large-files')

require('nvim-treesitter.configs').setup({
	ensure_installed = {
		'bash',
		'c',
		'diff',
		'html',
		'lua',
		'luadoc',
		'markdown',
		'markdown_inline',
		'query',
		'sql',
		'vim',
		'vimdoc',
	},
	auto_install = true,
	highlight = {
		enable = true,
		disable = function(_, bufnr)
			return large_files.is_large(bufnr)
		end,
	},
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				['af'] = '@function.outer',
				['if'] = '@function.inner',
				['ac'] = '@class.outer',
				['ic'] = '@class.inner',
				['aa'] = '@parameter.outer',
				['ia'] = '@parameter.inner',
			},
		},
		move = {
			enable = true,
			set_jumps = true,
			goto_next_start = {
				[']f'] = '@function.outer',
				[']C'] = '@class.outer',
			},
			goto_previous_start = {
				['[f'] = '@function.outer',
				['[C'] = '@class.outer',
			},
		},
	},
})

vim.opt.foldlevelstart = 99

vim.api.nvim_create_autocmd('FileType', {
	callback = function(args)
		if large_files.is_large(args.buf) then
			return
		end

		local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
		if not lang or not pcall(vim.treesitter.get_parser, args.buf, lang) then
			return
		end

		for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
			vim.api.nvim_set_option_value('foldmethod', 'expr', { scope = 'local', win = win })
			vim.api.nvim_set_option_value('foldexpr', 'v:lua.vim.treesitter.foldexpr()', { scope = 'local', win = win })
		end
	end,
})
