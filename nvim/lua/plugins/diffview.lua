return {
	'sindrets/diffview.nvim',
	cmd = {
		'DiffviewOpen',
		'DiffviewClose',
		'DiffviewToggleFiles',
		'DiffviewFocusFiles',
		'DiffviewFileHistory',
	},
	keys = {
		{ '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Git [D]iff Open' },
		{ '<leader>gD', '<cmd>DiffviewClose<cr>', desc = 'Git [D]iff Close' },
		{ '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'Git [H]istory (Current File)' },
		{ '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = 'Git Project [H]istory' },
	},
	opts = {
		enhanced_diff_hl = true,
	},
}
