return {
	"aserowy/tmux.nvim",
	event = "VeryLazy",
	config = function()
		require("tmux").setup({})
	end,
}

-- vim: ts=2 sts=2 sw=2 et
