return {
	"folke/which-key.nvim",
	event = "VimEnter",
	dependencies = {
		'echasnovski/mini.icons',
	},
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- configuration at: https://github.com/folke/which-key.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
