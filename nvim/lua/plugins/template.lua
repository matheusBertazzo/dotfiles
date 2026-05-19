return {
	'glepnir/template.nvim',
	cmd = { 'Template' },
	config = function()
		local template = require('template')
		local templates_dir = vim.fn.expand('~/.config/nvim/templates')

		template.setup({
			temp_dir = templates_dir
		})

		template.register(templates_dir)

		require('telescope').load_extension('find_template')
	end
}
