return {
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
		"keaising/im-select.nvim",
		config = function()
			require("im_select").setup({
				default_im_select = "com.apple.keylayout.ABC",
				default_command = "macism",
				set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
				set_previous_events = {},
				keep_quiet_on_no_binary = false,
				async_switch_im = true,
			})
		end,
	},
}
