return {
	-- @plugin toggle
	-- @category custom.toggle
	-- @description Switching function for nvim related settings
	{
		"custom.toggle",
		name = "toggle",
		dir = vim.fn.stdpath("config") .. "/lua/utils",
		dev = true,
		config = function()
			local toggle = require("utils.toggle").setup()

			toggle.map("<leader>uw", toggle.ui_wrap, { desc = "Toggle line wrap", id = "wrap" })
			toggle.map("<leader>un", toggle.ui_line_numbers, { desc = "Toggle line numbers", id = "ui_line_numbers" })
			toggle.map("<leader>ul", toggle.ui_cursorline, { desc = "Toggle cursor line", id = "cursorline" })
			toggle.map("<leader>us", toggle.ui_spell, { desc = "Toggle spell checking", id = "spell" })
			toggle.map("<leader>uc", toggle.ui_signcolumn, { desc = "Toggle sign column", id = "signcolumn" })
			toggle.map("<leader>up", toggle.ui_precognition, { desc = "Toggle precognition", id = "precognition" })

			for name, func in pairs(toggle.toggles) do
				local cmd_name = "Toggle" .. name:gsub("_", ""):gsub("^%l", string.upper)
				vim.api.nvim_create_user_command(cmd_name, func, { desc = "Toggle " .. name })
			end
		end,
	},
}
