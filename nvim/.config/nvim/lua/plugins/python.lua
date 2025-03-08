return {
	-- @plugin venv-selector
	-- @category lang.python
	-- @description Python virtual environment manager with automatic activation and integration
	{
		"linux-cultist/venv-selector.nvim",
		branch = "regexp",
		dependencies = {
			"neovim/nvim-lspconfig",
			"mfussenegger/nvim-dap",
			"mfussenegger/nvim-dap-python",
			"nvim-telescope/telescope.nvim",
		},
		lazy = false,
		config = function()
			local function on_venv_activate()
				local command_run = false

				local function run_shell_command()
					local source = require("venv-selector").source()
					local python = require("venv-selector").python()

					if source == "poetry" and command_run == false then
						local command = "poetry env use " .. python
						vim.api.nvim_feedkeys(command .. "\n", "n", false)
						command_run = true
					end
				end

				vim.api.nvim_create_augroup("TerminalCommands", { clear = true })

				vim.api.nvim_create_autocmd("TermEnter", {
					group = "TerminalCommands",
					pattern = "*",
					callback = run_shell_command,
				})
			end

			require("venv-selector").setup({
				settings = {
					options = {
						on_venv_activate_callback = on_venv_activate,
					},
				},
			})
		end,
		keys = {
			{ "<leader>vs", "<cmd>VenvSelect<cr>" },
		},
	},

	-- @plugin jupynium
	-- @category lang.python
	-- @description Jupyter notebook integration with two-way sync and code execution
	{
		"kiyoon/jupynium.nvim",
		build = "pip3 install --user .",
		dependencies = { "rcarriga/nvim-notify", "stevearc/dressing.nvim" },
		opts = {
			use_default_keybindings = false,
		},
		keys = {
			{ "<leader>ja", "<cmd>JupyniumStartAndAttachToServer<cr>", desc = "Jupynium Start and attach to server" },
			{ "<leader>js", "<cmd>JupyniumStartSync<cr>", desc = "Jupynium Start sync" },
			{ "<leader>jx", "<cmd>JupyniumExecuteSelectedCells<cr>", desc = "Jupynium Execute selected cells" },
		},
	},
}

-- vim: ts=2 sts=2 sw=2 et
