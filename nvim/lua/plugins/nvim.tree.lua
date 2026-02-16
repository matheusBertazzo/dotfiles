return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			on_attach = function(bufnr)
				local api = require('nvim-tree.api')

				local function get_opts(desc)
					return {
						desc = 'Nvim-tree: ' .. desc,
						buffer = bufnr,
						noremap = true,
						silent = true,
						nowait = true
					}
				end

				local function add_keymap(keys, rhs, desc, mode)
					mode = mode or 'n'
					vim.keymap.set(mode, keys, rhs, get_opts(desc))
				end

				-- File operations
				add_keymap('<C-i>', api.node.show_info_popup, 'File [I]nfo')
				add_keymap('o', api.node.open.edit, 'Open file')
				add_keymap('<CR>', api.node.open.tab, 'Open file in a new tab')
				add_keymap('<C-v>', api.node.open.vertical, 'Open file: [V]ertical Split')
				add_keymap('<C-h>', api.node.open.horizontal, 'Open file: [H]orizontal Split')
				add_keymap('<BS>', api.node.navigate.parent_close, 'Close Directory')
				add_keymap('i', api.fs.create, '[I]nsert new file or directory')
				add_keymap('yy', api.fs.copy.node, '[Y]ank file or directory')
				add_keymap('yap', api.fs.copy.absolute_path, '[Y]ank [A]bsolute [P]ath')
				add_keymap('yrp', api.fs.copy.relative_path, '[Y]ank [R]elative [P]ath')
				add_keymap('.', api.node.run.cmd, 'Run Command')
				add_keymap('<F2>', api.fs.rename, 'Rename file or directory')
				add_keymap('dD', api.fs.remove, '[D]elete file or directory')
				add_keymap('dd', api.fs.cut, 'Cut file or directory')
				add_keymap('p', api.fs.paste, '[P]aste file or directory')

				-- Navigation operations
				add_keymap('J', api.node.navigate.sibling.last, 'Last Sibling')
				add_keymap('K', api.node.navigate.sibling.first, 'First Sibling')
				add_keymap('P', api.node.navigate.parent, 'Parent Directory')
				add_keymap('[c', api.node.navigate.git.prev, 'Previous Git [C]hange')
				add_keymap(']c', api.node.navigate.git.next, 'Next Git [C]hange')

				-- Buffer tree manipulation
				add_keymap(
					'<C-]>',
					api.tree.change_root_to_node,
					'Change tree root to the directory under the cursor'
				)
				add_keymap(
					'<C-[>',
					api.tree.change_root_to_parent,
					'Expand tree root to the parent directory'
				)
				add_keymap('q', api.tree.close, '[Q]uit')
				add_keymap('R', api.tree.reload, '[R]efresh tree')
				add_keymap('S', api.tree.search_node, '[S]earch')
				add_keymap('W', api.tree.collapse_all, 'Collapse All')
				add_keymap('E', api.tree.expand_all, '[E]xpand All')
				add_keymap('g?', api.tree.toggle_help, 'Help')

				-- Bulk operations
				add_keymap('bd', api.marks.bulk.delete, '[B]ulk [D]elete')
				add_keymap('bmv', api.marks.bulk.move, '[B]ulk [M]ove')
				add_keymap('m', api.marks.toggle, 'Toggle Book[M]ark')

				-- Filter operations
				add_keymap('f', api.live_filter.start, 'Live Filter: Start')
				add_keymap('F', api.live_filter.clear, 'Live Filter: Clear')
				add_keymap('H', api.tree.toggle_hidden_filter, 'Toggle Filter: Show [H]idden files')
				add_keymap('I', api.tree.toggle_gitignore_filter, 'Toggle Filter: Git [I]gnore')
				add_keymap('M', api.tree.toggle_no_bookmark_filter, 'Toggle Filter: Show [M]arked files')
				add_keymap('U', api.tree.toggle_custom_filter, 'Toggle Filter: Hidden')
				add_keymap('C', api.tree.toggle_git_clean_filter, 'Toggle Filter: Git [C]hanges')

				-- Couldn't care less about these
				add_keymap('<Nop>', api.node.open.replace_tree_buffer, 'Open: In Place')
				add_keymap('<Nop>', api.node.open.preview, 'Open Preview')
				add_keymap('<Nop>', api.node.open.toggle_group_empty, 'Toggle Group Empty')
				add_keymap('<Nop>', api.node.open.edit, 'Open')
				add_keymap('<Nop>', api.node.open.no_window_picker, 'Open: No Window Picker')
				add_keymap('<Nop>', api.node.run.system, 'Run System')
				add_keymap('<Nop>', api.fs.trash, 'Trash')
				add_keymap('<Nop>', api.fs.rename_sub, '[R]ename: Omit Filename')
				add_keymap('<Nop>', api.fs.rename_basename, 'Rename: Basename')
				add_keymap('<Nop>', api.fs.rename_full, 'Rename: Full Path')
				add_keymap('<Nop>', api.fs.copy.basename, 'Copy Basename')
				add_keymap('<Nop>', api.fs.copy.filename, 'Copy Name')
				add_keymap('<Nop>', api.node.navigate.sibling.next, 'Next Sibling')
				add_keymap('<Nop>', api.node.navigate.sibling.prev, 'Previous Sibling')
				add_keymap('<Nop>', api.node.navigate.diagnostics.next, 'Next Diagnostic')
				add_keymap('<Nop>', api.node.navigate.diagnostics.prev, 'Prev Diagnostic')
				add_keymap('<Nop>', api.marks.bulk.trash, 'Trash Bookmarked')
				add_keymap('<Nop>', api.tree.toggle_no_buffer_filter, 'Toggle Filter: No Buffer')

				-- Disable mouse keymaps
				-- add_keymap('<2-LeftMouse>', api.node.open.edit, 'Open')
				-- add_keymap('<2-RightMouse>', api.tree.change_root_to_node, 'CD')
			end,
			git = { ignore = false },
			filters = { dotfiles = false }
		})
	end,
}
