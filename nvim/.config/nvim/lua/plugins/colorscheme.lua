return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		opts = {
			transparent_background = true,
			integrations = {
				flash = true,
				gitsigns = true,
				treesitter = true,
				snacks = true,
				telescope = { enabled = true },
				illuminate = {
					enabled = true,
					lsp = false,
				},
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}

-- vim: ts=2 sts=2 sw=2 et
