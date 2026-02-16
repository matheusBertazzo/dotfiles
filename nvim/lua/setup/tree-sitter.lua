local ts = require('nvim-treesitter')

ts.install({
	'bash',
	'c',
	'diff',
	'html',
	'lua',
	'luadoc',
	'markdown',
	'markdown_inline',
	'query',
	'vim',
	'vimdoc'
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		local lang = vim.bo.filetype
		local is_available = vim.tbl_contains(ts.get_available(), lang)

		if is_available then
			local is_installed = vim.tbl_contains(ts.get_installed(), lang)

			if is_installed then
				vim.treesitter.start()
				return
			end

			ts.install({ lang })
		end
	end,
})
