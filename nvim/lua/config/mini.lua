-- TODO: Define better keymaps for these plugins

-- Commenting is provided by Neovim's built-in gc/gcc operators (0.10+).

local keymap_helper = require('config.utils.keymap-helper')
require('mini.move').setup({
	mappings = keymap_helper.get_keymaps_for('mini.move')
})

require('mini.pairs').setup({})

require('mini.splitjoin').setup({})

require('mini.trailspace').setup({})

require('mini.indentscope').setup({
	mappings = {
		object_scope = '',
		object_scope_with_border = ''
	}
})

require('mini.jump').setup({})

require('mini.surround').setup({})
