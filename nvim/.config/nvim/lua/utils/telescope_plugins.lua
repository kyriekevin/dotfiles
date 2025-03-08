local M = {}

-- Scan plugin directory and collect plugin information
function M.scan_plugins()
	local plugins = {}
	local plugins_dir = vim.fn.stdpath("config") .. "/lua/plugins"

	local function scan_dir(dir)
		local handle = vim.loop.fs_scandir(dir)
		if not handle then
			return
		end

		while true do
			local name, type = vim.loop.fs_scandir_next(handle)
			if not name then
				break
			end

			local path = dir .. "/" .. name

			if type == "directory" then
				scan_dir(path)
			elseif type == "file" and name:match("%.lua$") then
				-- Read file content
				local content = table.concat(vim.fn.readfile(path), "\n")

				-- Find plugin tags
				for chunk in content:gmatch("%-%-[^\n]*@plugin[^\n]+.-{") do
					local plugin_name = chunk:match("@plugin%s+([%w%.%-_]+)")
					local category = chunk:match("@category%s+([%w%.%-_%.]+)") or "uncategorized"
					local description = chunk:match("@description%s+([^\n]+)") or ""

					if plugin_name then
						table.insert(plugins, {
							name = plugin_name,
							category = category,
							description = description,
							file_path = path,
							line_content = chunk,
						})
					end
				end
			end
		end
	end

	scan_dir(plugins_dir)
	return plugins
end

-- Group plugins by category
function M.group_by_category(plugins)
	local categories = {}

	for _, plugin in ipairs(plugins) do
		local category = plugin.category
		if not categories[category] then
			categories[category] = {}
		end
		table.insert(categories[category], plugin)
	end

	return categories
end

-- Safely set cursor position
local function safe_set_cursor(winid, pos)
	-- Check if window is valid
	if not winid or not vim.api.nvim_win_is_valid(winid) then
		return false
	end

	-- Get buffer
	local bufnr = vim.api.nvim_win_get_buf(winid)
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end

	-- Get buffer line count
	local line_count = vim.api.nvim_buf_line_count(bufnr)

	-- Ensure position is valid
	if pos[1] > line_count then
		pos[1] = line_count
	end
	if pos[1] < 1 then
		pos[1] = 1
	end

	-- Safely set cursor
	pcall(vim.api.nvim_win_set_cursor, winid, pos)
	return true
end

-- Plugin finder
function M.plugin_finder()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	local plugins = M.scan_plugins()

	pickers
		.new({}, {
			prompt_title = "Find Plugin",
			finder = finders.new_table({
				results = plugins,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.name .. " [" .. entry.category .. "]",
						ordinal = entry.name .. " " .. entry.category,
						filename = entry.file_path,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = previewers.new_buffer_previewer({
				title = "Plugin Configuration Preview",
				define_preview = function(self, entry, status)
					if not entry or not entry.value then
						return
					end

					-- Ensure state and buffer are valid
					if not self.state or not self.state.bufnr or not vim.api.nvim_buf_is_valid(self.state.bufnr) then
						return
					end

					-- Read file content
					local ok, content = pcall(vim.fn.readfile, entry.value.file_path)
					if not ok or not content then
						vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "Failed to read file content" })
						return
					end

					-- Set content
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, content)

					-- Set syntax highlighting
					pcall(vim.api.nvim_buf_set_option, self.state.bufnr, "filetype", "lua")

					-- Find plugin definition location and highlight
					local plugin_name = entry.value.name
					local found_line = 0

					for i, line in ipairs(content) do
						if line:match("@plugin%s+" .. plugin_name) then
							found_line = i
							break
						end
					end

					-- Safely set cursor position
					if found_line > 0 and self.state.winid then
						-- Use deferred execution to ensure window is fully initialized
						vim.defer_fn(function()
							safe_set_cursor(self.state.winid, { found_line, 0 })

							-- Highlight only the current line
							if vim.api.nvim_buf_is_valid(self.state.bufnr) then
								local ns_id = vim.api.nvim_create_namespace("plugin_highlight")
								vim.api.nvim_buf_clear_namespace(self.state.bufnr, ns_id, 0, -1)

								-- Highlight only the found line
								pcall(
									vim.api.nvim_buf_add_highlight,
									self.state.bufnr,
									ns_id,
									"TelescopePreviewLine",
									found_line - 1,
									0,
									-1
								)
							end
						end, 10)
					end
				end,
			}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)

					if selection and selection.value then
						vim.cmd("edit " .. selection.value.file_path)
						-- Search for plugin name
						vim.fn.search("@plugin%s+" .. selection.value.name)
					end
				end)
				return true
			end,
		})
		:find()
end

-- Browse plugins by category
function M.browse_by_category()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	local plugins = M.scan_plugins()
	local categories = M.group_by_category(plugins)

	-- Convert to list
	local category_list = {}
	for category, plugins in pairs(categories) do
		table.insert(category_list, {
			name = category,
			count = #plugins,
			plugins = plugins,
		})
	end

	-- Sort
	table.sort(category_list, function(a, b)
		return a.name < b.name
	end)

	-- Create category previewer
	local category_previewer = previewers.new_buffer_previewer({
		title = "Category Plugin List",
		define_preview = function(self, entry, status)
			if not entry or not entry.value or not self.state or not self.state.bufnr then
				return
			end

			local plugins = entry.value.plugins
			local lines = {
				"# Category: " .. entry.value.name,
				"Total: " .. #plugins .. " plugins",
				"",
				"## Plugin List:",
			}

			-- Sort plugins
			table.sort(plugins, function(a, b)
				return a.name < b.name
			end)

			-- Add plugin information
			for _, plugin in ipairs(plugins) do
				table.insert(lines, "")
				table.insert(lines, "### " .. plugin.name)
				table.insert(lines, "- Description: " .. plugin.description)
				table.insert(lines, "- File: " .. vim.fn.fnamemodify(plugin.file_path, ":~:."))
			end

			pcall(vim.api.nvim_buf_set_lines, self.state.bufnr, 0, -1, false, lines)
			pcall(vim.api.nvim_buf_set_option, self.state.bufnr, "filetype", "markdown")
		end,
	})

	pickers
		.new({}, {
			prompt_title = "Plugin Categories",
			finder = finders.new_table({
				results = category_list,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.name .. " (" .. entry.count .. " plugins)",
						ordinal = entry.name,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = category_previewer,
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)

					if selection and selection.value then
						-- Show plugins in this category with previewer
						pickers
							.new({}, {
								prompt_title = "Category: " .. selection.value.name,
								finder = finders.new_table({
									results = selection.value.plugins,
									entry_maker = function(entry)
										return {
											value = entry,
											display = entry.name .. " - " .. entry.description,
											ordinal = entry.name .. " " .. entry.description,
											filename = entry.file_path,
										}
									end,
								}),
								sorter = conf.generic_sorter({}),
								previewer = previewers.new_buffer_previewer({
									title = "Plugin Configuration Preview",
									define_preview = function(self, entry, status)
										if not entry or not entry.value or not self.state or not self.state.bufnr then
											return
										end

										-- Read file content
										local ok, content = pcall(vim.fn.readfile, entry.value.file_path)
										if not ok or not content then
											pcall(
												vim.api.nvim_buf_set_lines,
												self.state.bufnr,
												0,
												-1,
												false,
												{ "Failed to read file content" }
											)
											return
										end

										-- Set content
										pcall(vim.api.nvim_buf_set_lines, self.state.bufnr, 0, -1, false, content)

										-- Set syntax highlighting
										pcall(vim.api.nvim_buf_set_option, self.state.bufnr, "filetype", "lua")

										-- Find plugin definition location
										local plugin_name = entry.value.name
										local found_line = 0

										for i, line in ipairs(content) do
											if line:match("@plugin%s+" .. plugin_name) then
												found_line = i
												break
											end
										end

										-- Safely set cursor position
										if found_line > 0 and self.state.winid then
											vim.defer_fn(function()
												safe_set_cursor(self.state.winid, { found_line, 0 })
											end, 10)
										end
									end,
								}),
								attach_mappings = function(inner_prompt_bufnr, inner_map)
									actions.select_default:replace(function()
										local inner_selection = action_state.get_selected_entry()
										actions.close(inner_prompt_bufnr)

										if inner_selection and inner_selection.value then
											vim.cmd("edit " .. inner_selection.value.file_path)
											vim.fn.search("@plugin%s+" .. inner_selection.value.name)
										end
									end)
									return true
								end,
							})
							:find()
					end
				end)
				return true
			end,
		})
		:find()
end

-- Setup commands
function M.setup()
	-- Register commands
	vim.api.nvim_create_user_command("FindPlugin", function()
		M.plugin_finder()
	end, {})

	vim.api.nvim_create_user_command("PluginCategories", function()
		M.browse_by_category()
	end, {})

	-- Set keymaps
	vim.keymap.set("n", "<leader>fp", function()
		M.plugin_finder()
	end, { desc = "Find Plugin" })

	vim.keymap.set("n", "<leader>fc", function()
		M.browse_by_category()
	end, { desc = "Browse Plugin Categories" })

	return true
end

return M

-- vim: ts=2 sts=2 sw=2 et
