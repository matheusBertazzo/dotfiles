local ts = require('nvim-treesitter')

-- Parsers to install up front. Others are installed lazily on first open (see below).
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

-- Open files unfolded; folds are computed by TreeSitter (see start() below).
vim.opt.foldlevelstart = 99

vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		local buf = args.buf
		local ft = vim.bo[buf].filetype
		-- filetype is not always the parser name (e.g. typescriptreact -> tsx, sh -> bash),
		-- so resolve the TreeSitter language before checking availability/installation.
		local lang = vim.treesitter.language.get_lang(ft)

		if not lang or not vim.tbl_contains(ts.get_available(), lang) then
			return
		end

		local function start()
			-- The async install may complete after the buffer is gone or reused.
			if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= ft then
				return
			end

			vim.treesitter.start(buf, lang)

			-- Structural folding via Neovim core. foldexpr/foldmethod are window-local;
			-- set them on the window(s) currently showing this buffer.
			for _, win in ipairs(vim.fn.win_findbuf(buf)) do
				vim.api.nvim_set_option_value('foldmethod', 'expr', { scope = 'local', win = win })
				vim.api.nvim_set_option_value('foldexpr', 'v:lua.vim.treesitter.foldexpr()', { scope = 'local', win = win })
			end
		end

		if vim.tbl_contains(ts.get_installed(), lang) then
			start()
		else
			-- Not installed yet: install asynchronously, then start highlighting.
			ts.install({ lang }):await(vim.schedule_wrap(function()
				if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= ft then
					return
				end

				-- A runtime install writes the parser's query files WITHOUT changing
				-- 'runtimepath', so Neovim's memoized highlight-query lookup (which cached a
				-- nil miss) is never invalidated -- the highlighter then attaches but produces
				-- no highlights until a full restart. Clear that cache so the fresh highlighter
				-- reads the now-present queries. (This is what Neovim's own
				-- nvim.treesitter.query_cache_reset autocmd does on OptionSet runtimepath.)
				pcall(function()
					vim.treesitter.query.get:clear()
				end)

				-- Reload the unmodified buffer so it re-runs this handler on the "already
				-- installed" path and repaints cleanly (equivalent to reopening the file).
				if vim.bo[buf].modified then
					start()
				else
					vim.api.nvim_buf_call(buf, function()
						vim.cmd('edit')
					end)
				end
			end))
		end
	end,
})

-- TreeSitter textobjects (select + move). Requires the parser's textobjects.scm query.
require('nvim-treesitter-textobjects').setup({
	select = {
		lookahead = true,
	},
})

local select = require('nvim-treesitter-textobjects.select')
local move = require('nvim-treesitter-textobjects.move')

local function select_map(key, query, desc)
	vim.keymap.set({ 'x', 'o' }, key, function()
		select.select_textobject(query, 'textobjects')
	end, { desc = desc })
end

-- SELECT: function / class / parameter, inner and outer
select_map('af', '@function.outer', '[A]round [f]unction')
select_map('if', '@function.inner', '[I]nner [f]unction')
select_map('ac', '@class.outer', '[A]round [c]lass')
select_map('ic', '@class.inner', '[I]nner [c]lass')
select_map('aa', '@parameter.outer', '[A]round [a]rgument')
select_map('ia', '@parameter.inner', '[I]nner [a]rgument')

local function move_map(key, fn, query, desc)
	vim.keymap.set({ 'n', 'x', 'o' }, key, function()
		move[fn](query, 'textobjects')
	end, { desc = desc })
end

-- MOVE: next/prev function and class. Class uses ]C/[C (capitalized) to preserve
-- Vim's built-in diff-mode ]c/[c motions.
move_map(']f', 'goto_next_start', '@function.outer', 'Next function start')
move_map('[f', 'goto_previous_start', '@function.outer', 'Previous function start')
move_map(']C', 'goto_next_start', '@class.outer', 'Next class start')
move_map('[C', 'goto_previous_start', '@class.outer', 'Previous class start')
