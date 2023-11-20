-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Key mappings --
map({ "n", "i", "v" }, "<Left>", "<Nop>")
map({ "n", "i", "v" }, "<Right>", "<Nop>")
map({ "n", "i", "v" }, "<Up>", "<Nop>")
map({ "n", "i", "v" }, "<Down>", "<Nop>")
map({ "n" }, ";", ":")

-- better indenting
map({ "v" }, "<", "<gv")
map({ "v" }, ">", ">gv")

map({ "i" }, "jk", "<Esc>")
map({ "i" }, "kj", "<Esc>")
map({ "i" }, "c-a", "<ESC>A")

-- markdown
map({ "i" }, ",,", "<Esc>/<++><CR>:nohlsearch<CR>c4l")
map({ "i" }, ",f", "<Esc>/<++><CR>:nohlsearch<CR>")
map({ "i" }, ",n", "---<Enter><Enter>")
map({ "i" }, ",c", "```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA")
map({ "i" }, ",1", "#<Space><Enter><++><Esc>kA")
map({ "i" }, ",2", "##<Space><Enter><++><Esc>kA")
map({ "i" }, ",3", "###<Space><Enter><++><Esc>kA")
map({ "i" }, ",4", "####<Space><Enter><++><Esc>kA")
