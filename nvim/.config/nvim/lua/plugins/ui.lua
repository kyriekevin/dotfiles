return {
	{
		"akinsho/bufferline.nvim",
		config = true
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("ibl").setup({
				indent = {
					char = "|",
					tab_char = "|"
				},
				scope = { enabled = false }
			})
		end
	},
	{
		"goolord/alpha-nvim",
		config = function()
			require'alpha'.setup(require'alpha.themes.dashboard'.config)
		end
	}
}
