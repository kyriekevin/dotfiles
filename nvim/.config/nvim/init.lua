vim.g.mapleader = " "

vim.cmd("nmap <leader>rc :e ~/.config/nvim/init.lua<cr>")

vim.keymap.set({ "n", "v" }, "W", "5w")
vim.keymap.set({ "n", "v" }, "B", "5b")

vim.keymap.set("v", "p", "P")
vim.keymap.set("n", "U", "<C-r>")
vim.keymap.set("n", "<Esc>", ":nohlsearch<cr>")

vim.cmd("nmap j gj")
vim.cmd("nmap k gk")

vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
	spec = {
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
		{ import = "lazyvim.plugins.extras.vscode" },
	},
	{
		"vscode-neovim/vscode-multi-cursor.nvim",
		event = "VeryLazy",
		cond = not not vim.g.vscode,
		opts = {},
	},
})
