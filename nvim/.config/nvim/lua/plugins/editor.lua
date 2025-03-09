return {
	-- @plugin conform
	-- @category editor.formatting
	-- @description Lightweight yet powerful formatter plugin for Neovim
	{
		"stevearc/conform.nvim",
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ timeout_ms = 3000 })
				end,
				mode = { "n", "v" },
				desc = "Format Injected Langs",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return { timeout_ms = 500, lsp_format = "fallback" }
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				sh = { "shfmt" },
				python = { "isort", "black" },
				markdown = { "prettier", "markdownlint-cli2", "markdown-toc" },
				-- Conform can also run multiple formatters sequentially
				--
				-- You can use 'stop_after_first' to run the first available formatter from the list
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},

	-- @plugin nvim-lastplace
	-- @category editor.navigation
	-- @description Intelligently reopen files at your last edit position
	{
		"ethanholz/nvim-lastplace",
		config = true,
	},

	-- @plugin todo-comments
	-- @category editor.comments
	-- @description Highlight and search for todo comments like TODO, HACK, BUG in your code
	{
		"folke/todo-comments.nvim",
		cmd = { "TodoTrouble", "TodoTelescope" },
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next Todo Comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous Todo Comment",
			},
			{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
			{
				"<leader>xT",
				"<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
				desc = "Todo/Fix/Fixme (Trouble)",
			},
			{ "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
			{ "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
		},
	},

	-- @plugin neo-tree
	-- @category files.explorer
	-- @description A file explorer tree with support for git status and buffers
	{
		"nvim-neo-tree/neo-tree.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
		keys = {
			{
				"<leader>e",
				function()
					require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
				end,
				desc = "Explorer NeoTree (cwd)",
				remap = true,
			},
			{
				"<leader>ge",
				function()
					require("neo-tree.command").execute({ source = "git_status", toggle = true })
				end,
				desc = "Git Explorer",
			},
			{
				"<leader>be",
				function()
					require("neo-tree.command").execute({ source = "buffers", toggle = true })
				end,
				desc = "Buffer Explorer",
			},
		},
		opts = {},
	},

	-- @plugin telescope
	-- @category editor.search
	-- @description Highly extensible fuzzy finder over lists with powerful search capabilities
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		-- NOTE: Plugins can specify dependencies.
		--
		-- The dependencies are proper plugin specifications as well - anything
		-- you do for a plugin at the top level, you can do for a dependency.
		--
		-- Use the `dependencies` key to specify the dependencies of a particular plugin
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ -- If encountering errors, see telescope-fzf-native README for installation instructions
				"nvim-telescope/telescope-fzf-native.nvim",

				-- `build` is used to run some command when the plugin is installed/updated.
				-- This is only run then, not every time Neovim starts up.
				build = "make",

				-- `cond` is a condition used to determine whether this plugin should be
				-- installed and loaded.
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },

			-- Useful for getting pretty icons, but requires a Nerd Font.
			{ "nvim-tree/nvim-web-devicons" },
		},
		config = function()
			-- Telescope is a fuzzy finder that comes with a lot of different things that
			-- it can fuzzy find! It's more than just a "file finder", it can search
			-- many different aspects of Neovim, your workspace, LSP, and more!
			--
			-- The easiest way to use Telescope, is to start by doing something like:
			--  :Telescope help_tags
			--
			-- After running this command, a window will open up and you're able to
			-- type in the prompt window. You'll see a list of `help_tags` options and
			-- a corresponding preview of the help.
			--
			-- Two important keymaps to use while in Telescope are:
			--  - Insert mode: <c-/>
			--  - Normal mode: ?
			--
			-- This opens a window that shows you all of the keymaps for the current
			-- Telescope picker. This is really useful to discover what Telescope can
			-- do as well as how to actually do it!

			-- [[ Configure Telescope ]]
			-- See `:help telescope` and `:help telescope.setup()`
			require("telescope").setup({
				-- You can put your default mappings / updates / etc. in here
				--  All the info you're looking for is in `:help telescope.setup()`
				--
				-- defaults = {
				--   mappings = {
				--     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
				--   },
				-- },
				-- pickers = {}
				highlight = {
					enable = true,
				},
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})
			require("telescope").load_extension("fzf")
			require("telescope").load_extension("ui-select")
			require("utils.telescope_plugins").setup()

			-- See `:help telescope.builtin`
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
			vim.keymap.set("n", "<leader><space>", builtin.buffers, { desc = "Telescope buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
			vim.keymap.set("n", "<leader>?", builtin.oldfiles, { desc = "[?] Find recently opened files" })

			-- Slightly advanced example of overriding default behavior and theme
			vim.keymap.set("n", "<leader>/", function()
				-- You can pass additional configuration to Telescope to change the theme, layout, etc.
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 0,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })
		end,
	},

	-- @plugin which-key
	-- @category editor.navigation
	-- @description Displays available keybindings in popup with organized key groups
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts_extend = { "spec" },
    -- stylua: ignore
		opts = {
			spec = {
				{
					mode = { "n", "v" },
					{ "<leader><tab>", group = "tabs" },
					{ "<leader>c",     group = "code" },
					{ "<leader>f",     group = "find" },
					{ "<leader>g",     group = "git" },
					{ "<leader>j",     group = "jupyter",              icon = { icon = "󰌠", color = "yellow" } },
					{ "<leader>q",     group = "quit/session" },
					{ "<leader>r",     group = "competitest" },
					{ "<leader>s",     group = "search" },
					{ "<leader>u",     group = "ui",                   icon = { icon = "󰙵 ", color = "cyan" } },
					{ "<leader>v",     group = "venv",                 icon = { icon = "󰙵 ", color = "orange" } },
					{ "<leader>x",     group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
					{ "<leader>y",     group = "yazi",                 icon = { icon = "󰇥", color = "yellow" } },
					{ "[",             group = "prev" },
					{ "]",             group = "next" },
					{ "g",             group = "goto" },
					{ "gs",            group = "surround" },
					{ "<leader>b",     group = "buffer",
						expand = function()
							return require("which-key.extras").expand.buf()
						end,
					},
					{ "<leader>w",     group = "windows",
						proxy = "<c-w>",
						expand = function()
							return require("which-key.extras").expand.win()
						end,
					},
				},
			},
		},
	},

	-- @plugin flash
	-- @category editor.motion
	-- @description Fast navigation with labels for searching and jumping
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		vscode = true,
		---@type Flash.Config
		opts = {},
    -- stylua: ignore
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "o", "x" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
	},

	-- @plugin mini.comment
	-- @category editor.comments
	-- @description Fast and familiar commenting functionality
	{
		"echasnovski/mini.comment",
		event = "VeryLazy",
		opts = {},
	},

	-- @plugin mini.bracketed
	-- @category editor.navigation
	-- @description Navigate through text with square brackets ([]) motions
	{
		"echasnovski/mini.bracketed",
		event = "VeryLazy",
		opts = {},
	},

	-- @plugin mini.pairs
	-- @category editor.pairs
	-- @description Automatically insert paired characters like brackets and quotes
	{
		"echasnovski/mini.pairs",
		event = "VeryLazy",
		opts = {
			modes = { insert = true, command = true, terminal = false },
			-- skip autopair when next character is one of these
			skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
			-- skip autopair when the cursor is inside these treesitter nodes
			skip_ts = { "string" },
			-- skip autopair when next character is closing pair
			-- and there are more closing pairs than opening pairs
			skip_unbalanced = true,
			-- better deal with markdown code blocks
			markdown = true,
		},
	},

	-- @plugin mini.surround
	-- @category editor.text-objects
	-- @description Add, delete, and change surrounding pairs like brackets and quotes
	{
		"echasnovski/mini.surround",
		event = "VeryLazy",
		opts = {
			mappings = {
				add = "gsa", -- Add surrounding in Normal and Visual modes
				delete = "gsd", -- Delete surrounding
				find = "gsf", -- Find surrounding (to the right)
				find_left = "gsF", -- Find surrounding (to the left)
				highlight = "gsh", -- Highlight surrounding
				replace = "gsr", -- Replace surrounding
				update_n_lines = "gsn", -- Update `n_lines`
			},
		},
	},

	-- @plugin mini.ai
	-- @category editor.text-objects
	-- @description Enhanced around/inside textobjects with next/last variants
	{
		-- Better Around/Inside textobjects
		--
		-- Examples:
		--  - va)  - [V]isually select [A]round [)]paren
		--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
		--  - ci'  - [C]hange [I]nside [']quote
		"echasnovski/mini.ai",
		event = "VeryLazy",
		opts = {
			n_lines = 500,
		},
	},

	-- @plugin treesitter
	-- @category editor.highlighting
	-- @description Advanced syntax highlighting, parsing, and code navigation
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs", -- Sets main module to use for opts
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
		opts = {
			ensure_installed = {
				"bash",
				"cpp",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"vim",
				"vimdoc",
				"json",
				"json5",
				"python",
				"tmux",
			},
			-- Autoinstall languages that are not installed
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
			textobjects = {
				select = {
					enable = true,
					-- Automatically jump forward to textobj, similar to targets.vim
					lookahead = true,

					keymaps = {
						-- You can use the capture groups defined in textobjects.scm
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						-- You can optionally set descriptions to the mappings (used in the desc parameter of
						-- nvim_buf_set_keymap) which plugins like which-key display
						["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
						-- You can also use captures from other query groups like `locals.scm`
						["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
					},
					-- You can choose the select mode (default is charwise 'v')
					--
					-- Can also be a function which gets passed a table with the keys
					-- * query_string: eg '@function.inner'
					-- * method: eg 'v' or 'o'
					-- and should return the mode ('v', 'V', or '<c-v>') or a table
					-- mapping query_strings to modes.
					selection_modes = {
						["@parameter.outer"] = "v", -- charwise
						["@function.outer"] = "V", -- linewise
						["@class.outer"] = "<c-v>", -- blockwise
					},
					-- If you set this to `true` (default is `false`) then any textobject is
					-- extended to include preceding or succeeding whitespace. Succeeding
					-- whitespace has priority in order to act similarly to eg the built-in
					-- `ap`.
					--
					-- Can also be a function which gets passed a table with the keys
					-- * query_string: eg '@function.inner'
					-- * selection_mode: eg 'v'
					-- and should return true or false
					include_surrounding_whitespace = false,
				},
			},
		},
		-- There are additional nvim-treesitter modules that you can use to interact
		-- with nvim-treesitter. You should go explore a few and see what interests you:
		--
		--    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
		--    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
		--    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
	},

	-- @plugin hardtime
	-- @category editor.training
	-- @description Helps break bad habits by restricting inefficient movement commands
	{
		"m4xshen/hardtime.nvim",
		event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = {},
	},
}

-- vim: ts=2 sts=2 sw=2 et
