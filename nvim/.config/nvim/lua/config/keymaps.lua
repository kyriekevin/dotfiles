-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- better navigation
keymap.set({ "n", "v" }, "J", "5j")
keymap.set({ "n", "v" }, "K", "5k")
keymap.set({ "n", "v" }, "H", "0")
keymap.set({ "n", "v" }, "L", "$")
keymap.set({ "n", "v" }, "W", "5w")
keymap.set({ "n", "v" }, "B", "5b")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Key mappings --
keymap.set({ "n", "i", "v" }, "<Left>", "<Nop>")
keymap.set({ "n", "i", "v" }, "<Right>", "<Nop>")
keymap.set({ "n", "i", "v" }, "<Up>", "<Nop>")
keymap.set({ "n", "i", "v" }, "<Down>", "<Nop>")
keymap.set({ "n" }, ";", ":")

-- better indenting
keymap.set({ "v" }, "<", "<gv")
keymap.set({ "v" }, ">", ">gv")

keymap.set({ "i" }, "jk", "<Esc>")
keymap.set({ "i" }, "kj", "<Esc>")
keymap.set({ "i" }, "<c-a>", "<ESC>A")

-- New tab
keymap.set("n", "te", ":tabedit<CR>")
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)

-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

-- Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")

-- markdown
keymap.set({ "i" }, ",,", "<Esc>/<++><CR>:nohlsearch<CR>c4l")
keymap.set({ "i" }, ",f", "<Esc>/<++><CR>:nohlsearch<CR>")
keymap.set({ "i" }, ",n", "---<Enter><Enter>")
keymap.set({ "i" }, ",c", "```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA")
keymap.set({ "i" }, ",1", "#<Space><Enter><++><Esc>kA")
keymap.set({ "i" }, ",2", "##<Space><Enter><++><Esc>kA")
keymap.set({ "i" }, ",3", "###<Space><Enter><++><Esc>kA")
keymap.set({ "i" }, ",4", "####<Space><Enter><++><Esc>kA")
