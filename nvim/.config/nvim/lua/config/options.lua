local opt = vim.opt

-- Buffer Settings --
vim.b.fileencoding = "utf-8"

-- Global Settings --
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Globol Settings --
opt.autowrite = true -- Enable auto write
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 3 -- Hide * markup for bold and italic
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.showmode = false
opt.wildmenu = true
opt.backspace = { "indent", "eol", "start" }
opt.list = true

-- spell
opt.spell = true
opt.spelllang = { "en" }

-- split
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current

-- tab
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.shiftround = true
opt.autoindent = true
opt.smartindent = true

-- number
opt.number = true
opt.relativenumber = true

-- search
opt.hlsearch = false
opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.autoread = true
opt.title = true
opt.swapfile = false
opt.backup = false
opt.updatetime = 50
opt.mouse = ""
opt.undofile = true
opt.undodir = vim.fn.expand('$HOME/.local/share/nvim/undo')
opt.exrc = true
opt.wrap = false
opt.wildmode = "longest:full,full" -- Command-line completion mode

