return {
	-- @plugin nvim-cmp
	-- @category completion.engine
	-- @description Powerful completion engine with extensive source support and snippet integration
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"saadparwaiz1/cmp_luasnip",
				dependencies = {
					"L3MON4D3/LuaSnip",
					dependencies = {
						-- `friendly-snippets` contains a variety of premade snippets.
						--    See the README about individual language/framework/plugin snippets:
						--    https://github.com/rafamadriz/friendly-snippets
						{
							"rafamadriz/friendly-snippets",
							config = function()
								require("luasnip.loaders.from_vscode").lazy_load()
								require("luasnip.loaders.from_snipmate").lazy_load()
							end,
						},
					},
				},
			},

			{
				cond = function()
					local cache_file = vim.fn.stdpath("cache") .. "/company_env_check.txt"
					local file = io.open(cache_file, "r")
					if file then
						local cached = file:read("*all")
						file:close()
						if cached == "company" then
							return true
						elseif cached == "personal" then
							return false
						end
					end

					local function save_cache(is_company)
						local f = io.open(cache_file, "w")
						if f then
							f:write(is_company and "company" or "personal")
							f:close()
						end
					end

					local check_cmd =
						"timeout 2 git ls-remote git@code.byted.org:chenjiaqi.cposture/codeverse.vim.git &>/dev/null && echo success || echo fail"
					local handle = io.popen(check_cmd)
					if not handle then
						save_cache(false)
						return false
					end

					local result = handle:read("*a")
					handle:close()

					local is_company = result:match("success") ~= nil
					save_cache(is_company)
					return is_company
				end,
				"git@code.byted.org:chenjiaqi.cposture/codeverse.vim.git",
				config = function()
					local success, marscode = pcall(require, "marscode")
					if success then
						marscode.setup()
					else
						vim.notify("Failed to load marscode plugin", vim.log.levels.WARN)
					end
				end,
			},

			-- Adds other completion capabilities.
			--  nvim-cmp does not ship with all sources by default. They are split
			--  into multiple repos for maintenance purposes.
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",

			"kiyoon/jupynium.nvim",
		},
		config = function()
			-- See `:help cmp`
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			cmp.setup({
				window = {
					completion = {
						border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
					},
					documentation = {
						border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
						winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
					},
				},
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },

				-- For an understanding of why these mappings were
				-- chosen, you will need to read `:help ins-completion`
				--
				-- No, but seriously. Please read `:help ins-completion`, it is really good!
				mapping = cmp.mapping.preset.insert({
					-- Select the [n]ext item
					["<C-n>"] = cmp.mapping.select_next_item(),
					-- Select the [p]revious item
					["<C-p>"] = cmp.mapping.select_prev_item(),

					-- Scroll the documentation window [b]ack / [f]orward
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- Accept ([y]es) the completion.
					--  This will auto-import if your LSP supports it.
					--  This will expand snippets if the LSP sent a snippet.
					["<C-y>"] = cmp.mapping.confirm({ select = true }),

					-- If you prefer more traditional completion keymaps,
					-- you can uncomment the following lines
					-- ["<CR>"] = cmp.mapping.confirm({ select = true }),

					-- Think of <c-l> as moving to the right of your snippet expansion.
					--  So if you have a snippet that's like:
					--  function $name($args)
					--    $body
					--  end
					--
					-- <c-l> will move you to the right of each of the expansion locations.
					-- <c-h> is similar, except moving you backwards.
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),

					-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
					--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
				}),
				sources = {
					{ name = "marscode" },
					{ name = "jupynium" },
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{
						name = "lazydev",
						-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
						group_index = 0,
					},
				},
				experimental = {
					ghost_text = true,
				},
			})

			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
					{ name = "cmdline" },
				}),
			})
		end,
	},
}

-- vim: ts=2 sts=2 sw=2 et
