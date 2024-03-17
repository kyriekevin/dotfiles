local keymap = vim.keymap -- for conciseness
local opts = { noremap = true, silent = true }

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- set leader key to space
keymap.set("n", "<Space>", "", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- better navigation
keymap.set({ "n", "v" }, "J", "5j")
keymap.set({ "n", "v" }, "K", "5k")
keymap.set({ "n", "v", "o", "x" }, "H", "^", opts)
keymap.set({ "n", "v", "o", "x" }, "L", "g_", opts)
keymap.set({ "n", "v" }, "W", "5w")
keymap.set({ "n", "v" }, "B", "5b")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Key mappings --
keymap.set({ "n", "i", "v" }, "<Left>", "<Nop>")
keymap.set({ "n", "i", "v" }, "<Right>", "<Nop>")
keymap.set({ "n", "i", "v" }, "<Up>", "<Nop>")
keymap.set({ "n", "i", "v" }, "<Down>", "<Nop>")
keymap.set("n" , ";", ":")

-- better indenting
keymap.set("v" , "<", "<gv")
keymap.set("v" , ">", ">gv")

-- use jk/kj to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("i", "kj", "<ESC>", { desc = "Exit insert mode with kj" })
keymap.set("i" , "<c-a>", "<ESC>A")

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

keymap.set("x", "p", [["_dP]])

-- markdown
keymap.set("i" , ",,", "<Esc>/<++><CR>:nohlsearch<CR>c4l")
keymap.set("i" , ",f", "<Esc>/<++><CR>:nohlsearch<CR>")
keymap.set("i" , ",n", "---<Enter><Enter>")
keymap.set("i" , ",c", "```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA")
keymap.set("i" , ",1", "#<Space><Enter><++><Esc>kA")
keymap.set("i" , ",2", "##<Space><Enter><++><Esc>kA")
keymap.set("i" , ",3", "###<Space><Enter><++><Esc>kA")
keymap.set("i" , ",4", "####<Space><Enter><++><Esc>kA")
