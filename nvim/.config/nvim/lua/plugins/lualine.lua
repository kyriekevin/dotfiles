return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"AndreM222/copilot-lualine",
	},
	config = function()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				section_separators = { left = "", right = "" },
				component_separators = "",
				theme = "catppuccin",
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					"branch",
					"diff",
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = { error = " ", warn = " ", info = " ", hint = " " },
					},
				},
				lualine_c = { "filename" },
				lualine_x = { "copilot", "encoding", "filetype" }, -- I added copilot here
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})
	end,
}

-- vim: ts=2 sts=2 sw=2 et
