return {
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
