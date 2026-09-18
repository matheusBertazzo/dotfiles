return { -- Highlight, edit, and navigate code
	'nvim-treesitter/nvim-treesitter',
	branch = 'master',
	-- Pinned: `main` is a rewrite that drops `nvim-treesitter.configs`, which
	-- `lua/setup/tree-sitter.lua` relies on. `pin` stops `:Lazy update` from
	-- drifting us onto `main` and breaking startup.
	pin = true,
	lazy = false,
	build = ':TSUpdate',
	dependencies = {
		{
			'nvim-treesitter/nvim-treesitter-textobjects',
			branch = 'master',
			pin = true,
		},
	},
}
