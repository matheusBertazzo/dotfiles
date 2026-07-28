-- TODO: Define better keymaps for these plugins

-- Commenting is provided by Neovim's built-in gc/gcc operators (0.10+).

local keymap_helper = require('config.utils.keymap-helper')
require('mini.move').setup({
	mappings = keymap_helper.get_keymaps_for('mini.move')
})

require('mini.pairs').setup({})

require('mini.splitjoin').setup({})

require('mini.trailspace').setup({})

-- TODO: Solve minor conflicts with the "i" keymap.
require('mini.indentscope').setup({})

require('mini.jump').setup({})

-- FIXME: Solve conflict with the "s" keymap.
-- require('mini.surround').setup({})
