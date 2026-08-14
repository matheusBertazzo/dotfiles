return { -- Highlight, edit, and navigate code
	'nvim-treesitter/nvim-treesitter',
	branch = 'master',
	lazy = false,
	build = ':TSUpdate',
	dependencies = {
		{
			'nvim-treesitter/nvim-treesitter-textobjects',
			branch = 'master',
		},
	},
}
