local opt = vim.opt -- for conciseness

-- line numbers
opt.number = true -- Print line number
opt.relativenumber = true -- Relative line numbers

-- tabs & indentation
opt.tabstop = 2 -- Number of spaces tabs count for
opt.shiftwidth = 2 -- Size of an indent
opt.expandtab = true -- Use spaces instead of tabs
opt.smartcase = true -- Insert indents automatically

-- line wrapping
opt.wrap = false -- Disable line wrap

-- search settings
opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Don't ignore case with capitals

-- cursor line
opt.cursorline = true -- Enable highlighting of the current line

-- appearance
opt.termguicolors = true -- True color support
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time

-- clipboard
opt.clipboard = "unnamedplus" -- Sync with system clipboard

-- split windows
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current

opt.autowrite = true -- Enable auto write

opt.iskeyword:append("-")

