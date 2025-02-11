return {
	"akinsho/bufferline.nvim",
	event = "VimEnter",
	keys = {
		{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
	},
	opts = function(_, opts)
		if (vim.g.colors_name or ""):find("catppuccin") then
			opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
		end
	end,
}

-- vim: ts=2 sts=2 sw=2 et
