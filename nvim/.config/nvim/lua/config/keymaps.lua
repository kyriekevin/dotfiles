local keymap = vim.keymap -- for conciseness
local opts = { noremap = true, silent = true }

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- Move to window using the <ctrl> hjkl keys
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- better navigation
keymap.set({ "n", "v" }, "J", "5j")
keymap.set({ "n", "v" }, "K", "5k")
keymap.set({ "n", "v", "o", "x" }, "H", "^", opts)
keymap.set({ "n", "v", "o", "x" }, "L", "g_", opts)
keymap.set({ "n", "v", "o" }, "W", "5w")
keymap.set({ "n", "v", "o" }, "B", "5b")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- clear search highlights
keymap.set("n", "<leader><CR>", ":nohl<CR>", { desc = "Clear search highlights" })

-- Key mappings --
keymap.set({ "n", "i", "v" }, "<Left>", "<Nop>")
keymap.set({ "n", "i", "v" }, "<Right>", "<Nop>")
keymap.set({ "n", "i", "v" }, "<Up>", "<Nop>")
keymap.set({ "n", "i", "v" }, "<Down>", "<Nop>")
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

-- tab management
keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- buffer management
keymap.set("n", "<leader>bo", "<cmd>enew<CR>", { desc = "Open new buffer" })
keymap.set("n", "<leader>bx", "<cmd>bd<CR>", { desc = "Close current buffer" })
keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Go to next buffer" })
keymap.set("n", "<leader>bp", "<cmd>bpre<CR>", { desc = "Go to previous buffer" })
keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })

keymap.set("x", "p", [["_dP]])
keymap.set({ "v", "n" }, "<leader>y", '"+y')

-- lazy
keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- diagnostic
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end
keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- markdown
keymap.set({ "i" }, ",,", "<Esc>/<++><CR>:nohlsearch<CR>c4l")
keymap.set({ "i" }, ",f", "<Esc>/<++><CR>:nohlsearch<CR>")
keymap.set({ "i" }, ",n", "---<Enter><Enter>")
keymap.set({ "i" }, ",c", "```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA")
keymap.set({ "i" }, ",1", "#<Space><Enter><++><Esc>kA")
keymap.set({ "i" }, ",2", "##<Space><Enter><++><Esc>kA")
keymap.set({ "i" }, ",3", "###<Space><Enter><++><Esc>kA")
keymap.set({ "i" }, ",4", "####<Space><Enter><++><Esc>kA")
