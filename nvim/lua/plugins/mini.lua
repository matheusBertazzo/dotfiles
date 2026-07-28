return {
	{ 'echasnovski/mini.move',        version = '*' },
	{ 'echasnovski/mini.pairs',       version = '*' },
	{ 'echasnovski/mini.splitjoin',   version = '*' },
	{ 'echasnovski/mini.surround',    version = '*' },
	{ 'echasnovski/mini.trailspace',  version = '*' },
	{ 'echasnovski/mini.indentscope', version = '*' },
	{ 'echasnovski/mini.jump',        version = '*' },
	{
		'echasnovski/mini.icons',
		version = '*',
		lazy = true,
		-- Any require('nvim-web-devicons') transparently loads mini.icons and installs
		-- its devicons-compatible mock, so consumers (nvim-tree, which-key) keep working
		-- without a separate nvim-web-devicons dependency, regardless of load order.
		init = function()
			package.preload['nvim-web-devicons'] = function()
				require('mini.icons').mock_nvim_web_devicons()
				return package.loaded['nvim-web-devicons']
			end
		end,
		config = function()
			require('mini.icons').setup()
		end,
	},
}

