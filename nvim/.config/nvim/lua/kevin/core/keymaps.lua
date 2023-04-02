local opts = { noremap = true, silent = true }

local term_opts = {silent = true}

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

-- Normal
-- Better window navigation
keymap("n", "sv", "<C-w>v", opts)
keymap("n", "sh", "<C-w>s", opts)
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)
keymap("n", "s<leader>", "<C-w>=", opts) -- make split windows equal width
keymap("n", "s<CR>", ":close<CR>", opts) -- close current split window

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- basic settings
keymap("n", ";", ":", opts)
keymap("n", "S", ":w<CR>", opts)
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

keymap("n", "<leader>+", "<C-a>", opts)
keymap("n", "<leader>-", "<C-x>", opts)

keymap("n", "to", ":tabnew<CR>", opts)
keymap("n", "t<CR>", ":tabclose<CR>", opts)
keymap("n", "tn", ":tabn<CR>", opts)
keymap("n", "tp", ":tabp<CR>", opts)

-- create new Terminal
keymap("n", "<leader>v", ":vsp | terminal<CR>", opts)
keymap("n", "<leader>h", ":sp | terminal<CR>", opts)

-- Insert
-- Press jk fast to exit insert mode
keymap("i", "jk", "<ESC>", opts)
keymap("i", "kj", "<ESC>", opts)

-- Jump tot the end of the first line
keymap("i", "<C-h>", "<ESC>I", opts)
keymap("i", "<C-l>", "<ESC>A", opts)

-- Visual
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Terminal

-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

-- plugin keymaps

-- vim-maximizer
keymap("n", "sm", ":MaximizerToggle<CR>", opts)

-- nvim-tree
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- telescope
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts) -- find files within current working directory, respects .gitignore
keymap("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", opts) -- find string in current working directory as you type
keymap("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", opts) -- find string under cursor in current working directory
keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts) -- list open buffers in current neovim instance
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", opts) -- list available help tags
