return {
	-- persistence
	{
		"folke/persistence.nvim",
		keys = {
			{ "<leader>qs", [[<cmd>lua require("persistence").load()<cr>]] },
			{ "<leader>ql", [[<cmd>lua require("persistence").load({ last = true})<cr>]] },
			{ "<leader>qd", [[<cmd>lua require("persistence").stop()<cr>]] },
		},
		config = true,
	},
	{
		"rhysd/accelerated-jk",
		keys = {
			{ "j", "<Plug>(accelerated_jk_gj)" },
			{ "k", "<Plug>(accelerated_jk_gk)" },
		},
	},
	{
		"ethanholz/nvim-lastplace",
		config = true,
	},

	-- startuptime
	{
		"dstein64/vim-startuptime",
		cmd = "StartupTime",
		config = function()
			vim.g.startuptime_tries = 10
		end,
	},

	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		config = true,
	},
	{
		"echasnovski/mini.comment",
		event = "VeryLazy",
		config = true,
	},
}
