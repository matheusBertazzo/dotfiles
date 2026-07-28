return { -- Highlight, edit, and navigate code
	'nvim-treesitter/nvim-treesitter',
	branch = 'main', -- the setup uses the main-branch rewrite API (ts.install / vim.treesitter.start)
	lazy = false,
	build = ':TSUpdate',
	dependencies = {
		{
			'nvim-treesitter/nvim-treesitter-textobjects',
			branch = 'main', -- keep in lockstep with nvim-treesitter's main branch
		},
	},
}
