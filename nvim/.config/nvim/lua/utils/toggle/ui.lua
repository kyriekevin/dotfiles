---@class utils.toggle.ui
local M = {}

---@param toggle utils.toggle
function M.setup(toggle)
	function toggle.ui_line_numbers()
		local number = vim.wo.number
		local relative = vim.wo.relativenumber

		if toggle.states.line_numbers == nil then
			toggle.states.line_numbers = {
				number = number,
				relative = relative,
			}

			toggle.meta_info.line_numbers = {
				name = "Line Numbers",
				type = "feature",
			}

			toggle._update_which_key("line_numbers")
			return
		end

		if not number and not relative then
			vim.wo.number = true
			vim.wo.relativenumber = false
			vim.notify("Line numbers: absolute")
		elseif number and not relative then
			vim.wo.number = true
			vim.wo.relativenumber = true
			vim.notify("Line numbers: relative")
		else
			vim.wo.number = false
			vim.wo.relativenumber = false
			vim.notify("Line numbers: disabled")
		end

		toggle.states.line_numbers = {
			number = vim.wo.number,
			relative = vim.wo.relativenumber,
		}

		toggle._update_which_key("line_numbers")
	end

	function toggle.ui_cursorline()
		toggle.option("cursorline", nil, "wo", "Cursor Line")
	end

	function toggle.ui_wrap()
		toggle.option("wrap", nil, "wo", "Line Wrap")
	end

	function toggle.ui_spell()
		toggle.option("spell", nil, "wo", "Spell Checking")
	end

	function toggle.ui_signcolumn()
		local current = vim.wo.signcolumn
		local new_value = current == "yes" and "no" or "yes"

		vim.wo.signcolumn = new_value
		vim.notify("Sign column: " .. (new_value == "yes" and "enabled" or "disabled"))

		toggle.states.signcolumn = new_value == "yes"

		toggle.meta_info.signcolumn = {
			name = "Sign Column",
			type = "feature",
		}

		toggle._update_which_key("signcolumn")
	end

	function toggle.ui_precognition()
		local ok, precognition = pcall(require, "precognition")
		if not ok then
			vim.notify("precognition.nvim is not loaded", vim.log.levels.ERROR)
			return
		end

		if toggle.states.precognition == nil then
			toggle.states.precognition = false

			toggle.meta_info.precognition = {
				name = "Precognition",
				type = "feature",
			}

			if precognition.enabled then
				precognition.toggle()
			end

			toggle._update_which_key("precognition")
			return
		end

		local enabled = precognition.toggle()
		toggle.states.precognition = enabled
		vim.notify("Precognition: " .. (enabled and "enabled" or "disabled"))
		toggle._update_which_key("precognition")
	end

	toggle.toggles.line_numbers = toggle.ui_line_numbers()
	toggle.toggles.cursorline = toggle.ui_cursorline
	toggle.toggles.wrap = toggle.ui_wrap
	toggle.toggles.spell = toggle.ui_spell
	toggle.toggles.signcolumn = toggle.ui_signcolumn
	toggle.toggles.precognition = toggle.ui_precognition()

	return M
end

return M
