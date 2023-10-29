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
opt.undodir = vim.fn.expand("$HOME/.local/share/nvim/undo")
opt.exrc = true
opt.wrap = false
opt.wildmode = "longest:full,full" -- Command-line completion mode

vim.o.ttyfast = true
vim.o.autochdir = true
vim.o.listchars = "tab:|\\ ,trail:▫"

vim.cmd([[
silent !mkdir -p $HOME/.config/nvim/tmp/backup
silent !mkdir -p $HOME/.config/nvim/tmp/undo
"silent !mkdir -p $HOME/.config/nvim/tmp/sessions
set backupdir=$HOME/.config/nvim/tmp/backup,.
set directory=$HOME/.config/nvim/tmp/backup,.
if has('persistent_undo')
	set undofile
	set undodir=$HOME/.config/nvim/tmp/undo,.
endif
]])

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { pattern = "*.md", command = "setlocal spell" })
vim.api.nvim_create_autocmd("BufEnter", { pattern = "*", command = "silent! lcd %:p:h" })

vim.cmd([[au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]])

vim.cmd([[autocmd TermOpen term://* startinsert]])
vim.cmd([[
augroup NVIMRC
    autocmd!
    autocmd BufWritePost .vim.lua exec ":so %"
augroup END
tnoremap <C-N> <C-\><C-N>
tnoremap <C-O> <C-\><C-N><C-O>
]])

vim.cmd([[hi NonText ctermfg=gray guifg=grey10]])
