return {
	"mistweaverco/kulala.nvim",
	ft = { "http", "rest" },
	opts = {
		global_keymaps = false,
		lsp = {
			formatter = {
				sort = {
					metadata = false,
					variables = false,
					commands = false,
					json = false
				}
			}
		}
	},
	config = function(_, opts)
		require("kulala").setup(opts)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "http",
			callback = function()
				local buf = vim.api.nvim_get_current_buf()
				local opts_buf = { buffer = buf, desc = "" }

				opts_buf.desc = "Kulala [R]equest: [S]end request"
				vim.keymap.set("n", "<leader>Rs", require("kulala").run, opts_buf)

				opts_buf.desc = "Kulala [R]equest: Send [A]ll"
				vim.keymap.set("n", "<leader>Ra", require("kulala").run_all, opts_buf)

				opts_buf.desc = "Kulala [R]equest: Scratchpad"
				vim.keymap.set("n", "<leader>Rb", require("kulala").scratchpad, opts_buf)
			end,
		})
	end,
}
