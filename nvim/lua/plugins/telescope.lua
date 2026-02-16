return {
	'nvim-telescope/telescope.nvim',
	version = "*",
	dependencies = {
		'nvim-lua/plenary.nvim',
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
		-- { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' },
		'sharkdp/fd',
		{ "nvim-tree/nvim-web-devicons",              opts = {} },
		'BurntSushi/ripgrep',
	},
}
