return {
	-- @plugin markdown-preview
	-- @category lang.markdown
	-- @description Preview Markdown in your modern browser with synchronised scrolling and flexible configuration.
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "MarkdownPreview" },
			{ "<leader>mt", "<cmd>MarkdownToggle<cr>", desc = "MarkdownToggle" },
			{ "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", desc = "MarkdownPreviewStop" },
		},
	},
}
-- vim: ts=2 sts=2 sw=2 et
