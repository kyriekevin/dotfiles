-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

local map = vim.keymap.set

map({ "n", "i", "v", "x" }, "<Left>", "<Nop>")
map({ "n", "i", "v", "x" }, "<Right>", "<Nop>")
map({ "n", "i", "v", "x" }, "<Up>", "<Nop>")
map({ "n", "i", "v", "x" }, "<Down>", "<Nop>")

map("i", "jk", "<Esc>")
map("i", "kj", "<Esc>")

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- vim: ts=2 sts=2 sw=2 et
