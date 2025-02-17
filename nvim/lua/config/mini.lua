-- TODO: Define better keymaps for these plugins

require('mini.comment').setup({

	mappings = {
		comment = '<leader>cc',
		comment_line = '<leader>cl',
		comment_visual = '<leader>cc',
		text_object = '<leader>cc'
	}
})

require('mini.move').setup({})

require('mini.pairs').setup({})

require('mini.splitjoin').setup({})

require('mini.trailspace').setup({})

-- TODO: Solve minor conflicts with the "i" keymap.
require('mini.indentscope').setup({})

require('mini.jump').setup({})

-- FIXME: Solve conflict with the "s" keymap.
-- require('mini.surround').setup({})

