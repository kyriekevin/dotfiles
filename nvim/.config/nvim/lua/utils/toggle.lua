---@class utils.toggle
local M = {}

M.meta = {
	desc = "Toggle keymaps for managing Neovim settings",
}

---@class utils.toggle.Config
---@field notify? boolean
---@field create_commands? boolean
---@field which_key? boolean
---@field icon? table<string, string>
---@field color? table<string, string>
local defaults = {
	notify = true,
	create_commands = true,
	which_key = true,
	icon = {
		enabled = " ",
		disabled = " ",
	},
	color = {
		enabled = "green",
		disabled = "yellow",
	},
	wk_desc = {
		enabled = "Disable ",
		disabled = "Enable ",
	},
}

---@type table<string, function>
M.toggles = {}
M.states = {}
M.meta_info = {}

local function get_option(option, scope)
	scope = scope or "o"
	if scope == "o" then
		return vim.o[option]
	elseif scope == "wo" then
		return vim.wo[option]
	elseif scope == "bo" then
		return vim.bo[option]
	end
	return nil
end

local function set_option(option, value, scope)
	scope = scope or "o"
	if scope == "o" then
		vim.o[option] = value
	elseif scope == "wo" then
		vim.wo[option] = value
	elseif scope == "bo" then
		vim.bo[option] = value
	end
end

---@param option string
---@param value? boolean
---@param scope? string
---@param name? string
function M.option(option, value, scope, name)
	scope = scope or "o"
	name = name or option

	local current = get_option(option, scope)

	if value == nil then
		value = not current
	end

	set_option(option, value, scope)

	M.states[option] = value

	M.meta_info[option] = {
		name = name,
		type = "option",
	}

	if defaults.notify then
		vim.notify(
			name .. ": " .. (value and "enabled" or "disabled"),
			value and vim.log.levels.INFO or vim.log.levels.WARN
		)
	end

	M._update_which_key(option)

	return value
end

---@param option string
---@param values table
---@param scope? string
---@param name? string
---@return any
function M.cycle_option(option, values, scope, name)
	scope = scope or "o"
	name = name or option

	local current = get_option(option, scope)

	local next_index = 1
	for i, v in ipairs(values) do
		if v == current then
			next_index = (i % #values) + 1
			break
		end
	end

	local next_value = values[next_index]

	set_option(option, next_value, scope)

	M.states[option] = next_value

	M.meta_info[option] = {
		name = name,
		type = "cycle",
		values = values,
	}

	if defaults.notify then
		vim.notify(name .. ": " .. tostring(next_value))
	end

	M._update_which_key(option)

	return next_value
end

---@param name string
---@param on_fn function
---@param off_fn function
---@param display_name? string
---@return boolean
function M.feature(name, on_fn, off_fn, display_name)
	display_name = display_name or name

	M.states[name] = not (M.states[name] or false)

	if M.states[name] then
		if on_fn then
			on_fn()
		end
	else
		if off_fn then
			off_fn()
		end
	end

	M.meta_info[name] = {
		name = display_name,
		type = "feature",
	}

	if defaults.notify then
		vim.notify(
			display_name .. ": " .. (M.states[name] and "enabled" or "disabled"),
			M.states[name] and vim.log.levels.INFO or vim.log.levels.WARN
		)
	end

	M._update_which_key(name)

	return M.states[name]
end

---@param lhs string
---@param toggle_fn function
---@param opts? table
function M.map(lhs, toggle_fn, opts)
	opts = opts or {}
	local keymap_opts = vim.deepcopy(opts)

	local toggle_id = keymap_opts.id
	keymap_opts.id = nil

	keymap_opts.desc = keymap_opts.desc or "Toggle setting"

	if toggle_id then
		M._key_mappings = M._key_mappings or {}
		M._key_mappings[toggle_id] = {
			key = lhs,
			mode = keymap_opts.mode or "n",
		}
	end

	vim.keymap.set(keymap_opts.mode or "n", lhs, function()
		toggle_fn()
		if toggle_id then
			M._update_which_key(toggle_id)
		end
	end, keymap_opts)
end

---@param id string
function M._update_which_key(id)
	if not defaults.which_key then
		return
	end
	if not M._key_mappings or not M._key_mappings[id] then
		return
	end

	local ok, wk = pcall(require, "which-key")
	if not ok then
		return
	end

	local mapping = M._key_mappings[id]
	local state = M.states[id]
	local meta = M.meta_info[id]

	if not meta then
		return
	end

	wk.add({
		{
			mapping.key,
			mode = mapping.mode,
			-- real = true,
			icon = function()
				local key = state and "enabled" or "disabled"
				return {
					icon = defaults.icon[key],
					color = defaults.color[key],
				}
			end,
			desc = function()
				local key = state and "enabled" or "disabled"
				return defaults.wk_desc[key] .. meta.name
			end,
		},
	})
end

---@param opts? utils.toggle.Config
function M.setup(opts)
	if opts then
		for k, v in pairs(opts) do
			defaults[k] = v
		end
	end

	local ok, ui = pcall(require, "utils.toggle.ui")
	if ok and type(ui.setup) == "function" then
		ui.setup(M)
	else
		vim.notify("Failed to load UI toggle module", vim.log.levels.WARN)
	end

	return M
end

return M
