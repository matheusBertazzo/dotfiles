return {
	"ThePrimeagen/refactoring.nvim",
	keys = {
		{
			"<leader>rr",
			function()
				require('telescope').extensions.refactoring.refactors()
			end,
			mode = { "n", "x" },
			desc = "[R]efactor code",
		},
	},
	config = true,
	dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
}
