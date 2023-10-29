local map = vim.keymap.set

-- Key mappings --
map({ "n", "i", "v" }, "<Left>", "<Nop>")
map({ "n", "i", "v" }, "<Right>", "<Nop>")
map({ "n", "i", "v" }, "<Up>", "<Nop>")
map({ "n", "i", "v" }, "<Down>", "<Nop>")
map({ "n" }, ";", ":")

-- save & quit
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map({ "i", "x", "n", "s" }, "<C-q>", "<cmd>q<cr><esc>", { desc = "Quit" })

-- fast move
map({ "n", "v" }, "<S-w>", "5w")
map({ "n", "v" }, "<S-b>", "5b")
map({ "n", "v" }, "<S-h>", "0")
map({ "n", "v" }, "<S-l>", "$")

-- better indenting
map({ "v" }, "<", "<gv")
map({ "v" }, ">", ">gv")

map({ "i" }, "jk", "<Esc>")
map({ "i" }, "kj", "<Esc>")
map({ "i" }, "c-a", "<ESC>A")

-- lazy
map({ "n" }, "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Window & splits
map({ "n" }, "sk", ":set nosplitbelow<CR>:split<CR>:set splitbelow<CR>")
map({ "n" }, "sj", ":set splitbelow<CR>:split<CR>")
map({ "n" }, "sl", ":set splitright<CR>:vsplit<CR>")
map({ "n" }, "sh", ":set nosplitright<CR>:vsplit<CR>:set splitright<CR>")
map({ "n" }, "<leader>h", "<C-w>h")
map({ "n" }, "<leader>j", "<C-w>j")
map({ "n" }, "<leader>k", "<C-w>k")
map({ "n" }, "<leader>l", "<C-w>l")

-- tab
map({ "n" }, "tu", ":tabe<CR>")
map({ "n" }, "tU", ":tab split<CR>")
map({ "n" }, "th", ":-tabnext<CR>")
map({ "n" }, "tl", ":+tabnext<CR>")
