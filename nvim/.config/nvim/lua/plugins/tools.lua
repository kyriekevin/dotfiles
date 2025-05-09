return {
	-- @plugin im-select
	-- @category tools.utility
	-- @description Automatic input method switching for different modes in Neovim
	{
		"keaising/im-select.nvim",
		event = "VeryLazy",
		cond = function()
			local os_name = vim.loop.os_uname().sysname
			return os_name == "Darwin"
		end,
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

	-- @plugin tmux
	-- @category tools.terminal
	-- @description Seamless navigation between Neovim splits and tmux panes
	{
		"aserowy/tmux.nvim",
		event = "VeryLazy",
		config = function()
			require("tmux").setup({})
		end,
	},

	-- @plugin persistence
	-- @category tools.session
	-- @description Simple session management with automatic saving and loading
	{
		"folke/persistence.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>qs", [[<cmd>lua require("persistence").load()<cr>]] },
			{ "<leader>ql", [[<cmd>lua require("persistence").load({ last = true})<cr>]] },
			{ "<leader>qd", [[<cmd>lua require("persistence").stop()<cr>]] },
		},
		config = true,
	},

	-- @plugin snacks
	-- @category tools.utility
	-- @description Collection of small, useful utilities and UI enhancements for Neovim
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			bigfile = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			dashboard = {
				preset = {
					---@type snacks.dashboard.Item[]
					keys = {
						{
							icon = " ",
							key = "f",
							desc = "Find File",
							action = ":lua Snacks.dashboard.pick('files')",
						},
						{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
						{
							icon = " ",
							key = "g",
							desc = "Find Text",
							action = ":lua Snacks.dashboard.pick('live_grep')",
						},
						{
							icon = " ",
							key = "r",
							desc = "Recent Files",
							action = ":lua Snacks.dashboard.pick('oldfiles')",
						},
						{
							icon = " ",
							key = "c",
							desc = "Config",
							action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
						},
						{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
						{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},
				},
			},
		},
		keys = {
			{
				"<leader>cR",
				function()
					Snacks.rename.rename_file()
				end,
				desc = "Rename File",
			},
			{
				"<leader>gb",
				function()
					Snacks.git.blame_line()
				end,
				desc = "Git Blame Line",
			},
		},
	},

	-- @plugin competitest
	-- @category tools.competitive-programming
	-- @description Competitive programming plugin for testcase management and execution
	{
		"xeluxee/competitest.nvim",
		event = "VeryLazy",
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
		opts = {},
	},

	-- @plugin yazi
	-- @category tools.explorer
	-- @description Integration with Yazi file manager for browsing and managing files
	---@type LazySpec
	{
		"mikavilpas/yazi.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>ya",
				"<cmd>Yazi<cr>",
				desc = "Open yazi at the current file",
			},
			{
				-- Open in the current working directory
				"<leader>yc",
				"<cmd>Yazi cwd<cr>",
				desc = "Open the file manager in nvim's working directory",
			},
			{
				-- NOTE: this requires a version of yazi that includes
				-- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
				"<leader>yt",
				"<cmd>Yazi toggle<cr>",
				desc = "Resume the last yazi session",
			},
		},
		---@type YaziConfig
		opts = {
			-- if you want to open yazi instead of netrw, see below for more info
			open_for_directories = false,
			keymaps = {
				show_help = "<f1>",
			},
		},
	},
}

-- vim: ts=2 sts=2 sw=2 et
