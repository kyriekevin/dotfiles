return {
	"utilyre/barbecue.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"SmiteshP/nvim-navic",
	},
	config = function()
		require("barbecue").setup({
			theme = "catppucin",
		})
	end,
}

-- vim: ts=2 sts=2 sw=2 et
