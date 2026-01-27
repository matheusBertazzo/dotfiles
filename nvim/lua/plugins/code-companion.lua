return {
	"olimorris/codecompanion.nvim",
	version = "^18.0.0",
	opts = {
		interactions = {
			chat = {
				adapter = "openai",
				model = "gpt-4o-mini"
			},
			inline = {
				adapter = "openai",
				model = "gpt-4o-mini"
			},
			cmd = {
				adapter = "openai",
				model = "gpt-4o-mini"
			},
			background = {
				adapter = "openai",
				model = "gpt-4o-mini"
			},
		},
		opts = {
			log_level = "DEBUG",
		}
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
}
