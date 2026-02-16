return {
	'nvim-telescope/telescope.nvim',
	version = "*",
	dependencies = {
		'nvim-lua/plenary.nvim',
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
		'sharkdp/fd',
		{ "nvim-tree/nvim-web-devicons",              opts = {} },
		'BurntSushi/ripgrep',
	},
}
