local map = vim.keymap.set

-- Key mappings --
map({ "n", "i", "v" }, "<Left>", "<Nop>")
map({ "n", "i", "v" }, "<Right>", "<Nop>")
map({ "n", "i", "v" }, "<Up>", "<Nop>")
map({ "n", "i", "v" }, "<Down>", "<Nop>")

-- save & quit
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map({ "i", "x", "n", "s" }, "<C-q>", "<cmd>q<cr><esc>", { desc = "Quit" })

-- fast move
map({ "n", "v" }, "<S-j>", "5j")
map({ "n", "v" }, "<S-k>", "5k")
map({ "n", "v" }, "<S-w>", "5w")
map({ "n", "v" }, "<S-b>", "5b")
map({ "n", "v" }, "<S-h>", "0")
map({ "n", "v" }, "<S-l>", "$")

-- better indenting
map({ "v" }, "<", "<gv")
map({ "v" }, ">", ">gv")

map({ "i" }, "jk", "<Esc>")
map({ "i" }, "kj", "<Esc>")

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

