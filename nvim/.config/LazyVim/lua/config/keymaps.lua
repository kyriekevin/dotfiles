-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap -- for conciseness
local opts = { noremap = true, silent = true }

-- lazy
keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- better navigation
keymap.set({ "n", "v", "o", "x" }, "H", "^", opts)
keymap.set({ "n", "v", "o", "x" }, "L", "g_", opts)
keymap.set({ "n", "v", "o" }, "W", "5w")
keymap.set({ "n", "v", "o" }, "B", "5b")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- clear search highlights
keymap.set("n", "<leader><CR>", ":nohl<CR>", { desc = "Clear search highlights" })

-- Key mappings --
keymap.set({ "n" }, ";", ":")

-- better indenting
keymap.set({ "v" }, "<", "<gv")
keymap.set({ "v" }, ">", ">gv")

-- use jk/kj to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("i", "kj", "<ESC>", { desc = "Exit insert mode with kj" })
keymap.set("i", "<c-a>", "<ESC>A")

-- window management
keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>wh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>we", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>wx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- buffer management
keymap.set("n", "<leader>bo", "<cmd>enew<CR>", { desc = "Open new buffer" })
keymap.set("n", "<leader>bx", "<cmd>bd<CR>", { desc = "Close current buffer" })
keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Go to next buffer" })
keymap.set("n", "<leader>bp", "<cmd>bpre<CR>", { desc = "Go to previous buffer" })

keymap.set("x", "p", [["_dP]])
keymap.set({ "v", "n" }, "<leader>y", '"+y')

-- markdown
keymap.set({ "i" }, ",,", "<Esc>/<++><CR>:nohlsearch<CR>c4l")
keymap.set({ "i" }, ",f", "<Esc>/<++><CR>:nohlsearch<CR>")
keymap.set({ "i" }, ",n", "---<Enter><Enter>")
keymap.set({ "i" }, ",c", "```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA")
keymap.set({ "i" }, ",1", "#<Space><Enter><++><Esc>kA")
keymap.set({ "i" }, ",2", "##<Space><Enter><++><Esc>kA")
keymap.set({ "i" }, ",3", "###<Space><Enter><++><Esc>kA")
keymap.set({ "i" }, ",4", "####<Space><Enter><++><Esc>kA")
