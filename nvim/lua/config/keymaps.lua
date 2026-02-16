-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Tabs navigation
vim.keymap.set('n', 'H', vim.cmd.tabprev, { desc = 'Go to the previous tab' })
vim.keymap.set('n', 'L', vim.cmd.tabnext, { desc = 'Go to the nex tab' })

local function go_to_tab(tab_number)
	vim.cmd.tabfirst()

	for i = 1, tab_number - 1 do
		vim.cmd.tabnext()
	end
end

local tab_keymaps = require('config.utils.keymap-helper').get_keymaps_for('tabs')

for i = 1, #tab_keymaps do
	vim.keymap.set(
		'n',
		tab_keymaps[i],
		function() go_to_tab(i) end,
		{ desc = 'Go to tab #' .. i }
	)
end
