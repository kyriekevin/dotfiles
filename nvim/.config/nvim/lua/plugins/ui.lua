return {
	-- @plugin catppuccin
	-- @category ui.colorscheme
	-- @description A soothing pastel theme for Neovim
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		opts = {
			flavour = "mocha",
			transparent_background = true,
			integrations = {
				blink_cmp = true,
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

	-- @plugin bufferline
	-- @category ui.tabline
	-- @description A snazzy buffer line for Neovim with minimal tab integration
	{
		"akinsho/bufferline.nvim",
		keys = {
			{ "<leader>bh", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "<leader>bl", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
			{ "<leader>bd", "<cmd>:bd<cr>", desc = "Close Current Buffer" },
			{ "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick Buffer" },
			{ "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "Pick Close" },
			{ "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close Others" },
		},
		opts = function(_, opts)
			opts.options = opts.options or {}
			opts.options.numbers = "ordinal"
			opts.options.diagnostics = "nvim_lsp"
			opts.options.diagnostics_indicator = function(count, level, _, _)
				local symbols = {
					error = " ",
					warning = " ",
					info = " ",
					hint = " ",
				}
				return " " .. (symbols[level] or "") .. count
			end

			if (vim.g.colors_name or ""):find("catppuccin") then
				opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
			end
		end,
		lazy = false,
	},

	-- @plugin lualine
	-- @category ui.statusline
	-- @description A blazing fast and easy to configure Neovim statusline
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = true,
					section_separators = { left = "", right = "" },
					component_separators = "",
					theme = "auto",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = { "encoding", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	-- @plugin barbecue
	-- @category ui.winbar
	-- @description A VS Code-like winbar that shows your current code context
	{
		"utilyre/barbecue.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"SmiteshP/nvim-navic",
		},
		config = function()
			require("barbecue").setup({
				theme = "catppucin",
			})
		end,
	},

	-- @plugin noice
	-- @category ui.notifications
	-- @description Highly customizable UI enhancement for messages, cmdline, and popupmenu
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
						},
					},
					view = "mini",
				},
			},
			presets = {
				command_palette = true,
				long_message_to_split = true,
			},
		},
  -- stylua: ignore
  keys = {
    { "<leader>sn", "", desc = "+noice"},
    { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
    { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
    { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
    { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
    { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
    { "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)" },
    { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = {"i", "n", "s"} },
    { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = {"i", "n", "s"}},
  },
		config = function(_, opts)
			-- HACK: noice shows messages from before it was enabled,
			-- but this is not ideal when Lazy is installing plugins,
			-- so clear the messages in this case.
			if vim.o.filetype == "lazy" then
				vim.cmd([[messages clear]])
			end
			require("noice").setup(opts)
		end,
	},

	-- @plugin mini.indentscope
	-- @category ui
	-- @description Visualize and work with indentation scope
	{
		"echasnovski/mini.indentscope",
		event = "VeryLazy",
		opts = {
			draw = { delay = 50 },
		},
	},

	-- @plugin mini.icons
	-- @category ui.icons
	-- @description Consistent icon set with customization options
	{
		"echasnovski/mini.icons",
		lazy = true,
		opts = {
			file = {
				[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
				["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
			},
			filetype = {
				dotenv = { glyph = "", hl = "MiniIconsYellow" },
			},
		},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},
}

-- vim: ts=2 sts=2 sw=2 et
