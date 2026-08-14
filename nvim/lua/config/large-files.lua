local M = {}

local max_bytes = 1024 * 1024
local max_lines = 5000

function M.is_large(bufnr)
	bufnr = bufnr or 0

	local line_count = vim.api.nvim_buf_line_count(bufnr)
	if line_count > max_lines then
		return true
	end

	return vim.api.nvim_buf_get_offset(bufnr, line_count) > max_bytes
end

local function update(bufnr)
	local large = M.is_large(bufnr)
	vim.b[bufnr].large_file = large
	vim.b[bufnr].minitrailspace_disable = large
	vim.b[bufnr].miniindentscope_disable = large

	if large then
		vim.treesitter.stop(bufnr)
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			vim.lsp.buf_detach_client(bufnr, client.id)
		end
	end
end

vim.api.nvim_create_autocmd({ 'BufReadPost', 'FileType' }, {
	group = vim.api.nvim_create_augroup('large-files', { clear = true }),
	callback = function(args)
		update(args.buf)
	end,
})

vim.api.nvim_create_autocmd('LspAttach', {
	group = 'large-files',
	callback = function(args)
		if vim.b[args.buf].large_file then
			vim.schedule(function()
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client and vim.api.nvim_buf_is_valid(args.buf) then
					vim.lsp.buf_detach_client(args.buf, client.id)
					if not next(client.attached_buffers) then
						client:stop()
					end
				end
			end)
		end
	end,
})

return M
