-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

-- Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
-- 	normal_mode = "n",
-- 	insert_mode = "i",
-- 	visual_mode = "v",
-- 	visual_block_mode = "x",
-- 	term_mode = "t",
-- 	command_mode = "c",

-- basic settings
keymap("n", ";", ":", opts)
keymap("n", "Q", ":q<CR>", opts)

-- J/K keys for 5 times j/k (faster navigation)
keymap("n", "J", "5j", opts)
keymap("n", "K", "5k", opts)

-- Faster in-line navigation
keymap("n", "W", "5w", opts)
keymap("n", "B", "5B", opts)

-- Move to the beginning of the Line
keymap("n", "H", "^", opts)
keymap("n", "L", "g_", opts)

keymap("n", "<leader><CR>", ":nohl<CR>", opts)

-- Insert
-- Press jk fast to exit insert mode
keymap("i", "jk", "<ESC>", opts)
keymap("i", "kj", "<ESC>", opts)

-- Jump tot the end of the first line
keymap("i", "<C-h>", "<ESC>I", opts)
keymap("i", "<C-l>", "<ESC>A", opts)

-- Press space j to jump to the next '<++>' and edit it
keymap("n", "<leader>j", "<ESC>/<++><CR>:nohlsearch<CR>c4l", opts)

-- Markdown settings
keymap("i", ",f", "<ESC>/<++><CR>:nohlsearch<CR>c4l", opts)
keymap("i", ",n", "---<Enter><Enter>", opts)
keymap("i", ",b", "**** <++><ESC>F*hi", opts)
keymap("i", ",p", "![](<++>) <++><ESC>F[a", opts)
keymap("i", ",a", "[](<++>) <++><ESC>F[a", opts)
keymap("i", ",1", "#<Space><Enter><++><ESC>kA", opts)
keymap("i", ",2", "##<Space><Enter><++><ESC>kA", opts)
keymap("i", ",3", "###<Space><Enter><++><ESC>kA", opts)
keymap("i", ",4", "####<Space><Enter><++><ESC>kA", opts)
