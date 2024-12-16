return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		opts = {
			flavour = "mocha",
			transparent_background = true,
			integrations = {
				cmp = {
					enabled = true,
					border = {
						completion = true,
						documentation = true,
					},
				},
				flash = true,
				gitsigns = true,
				snacks = true,
				treesitter = true,
				treesitter_context = true,
				telescope = { enabled = true },
				illuminate = {
					enabled = true,
					lsp = false,
				},
				indent_blankline = true,
				markdown = true,
				mason = true,
				which_key = true,
				neotree = true,
				notify = true,
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}

-- vim: ts=2 sts=2 sw=2 et
