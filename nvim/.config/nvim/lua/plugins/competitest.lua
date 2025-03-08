return {
	"xeluxee/competitest.nvim",
	dependencies = "MunifTanjim/nui.nvim",
	keys = {
		{ "<leader>ri", "<cmd>CompetiTest receive testcases<cr>", desc = "Receive Testcases" },
		{ "<leader>rr", "<cmd>CompetiTest run<cr>", desc = "CompetiTest Run" },
		{
			"<leader>rx",
			function()
				local base_name = vim.fn.expand("%:t:r")
				local current_dir = vim.fn.expand("%:p:h")
				vim.fn.system("rm -f " .. current_dir .. "/" .. base_name)
				vim.fn.system("rm -f " .. current_dir .. "/" .. base_name .. "*.txt")
				vim.notify("text delete")
			end,
			desc = "Delete Testcases",
		},
	},
	config = function()
		require("competitest").setup()
	end,
}
