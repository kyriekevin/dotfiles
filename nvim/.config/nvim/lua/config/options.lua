local opt = vim.opt
local buf = vim.b

-- auto format
vim.g.autoformat = true

-- if the completion engine supports the AI source,
-- use that instead of inline suggestions
vim.g.ai_cmp = true

-- root dir detection
-- Each entry can be:
-- * the name of a detector function like `lsp` or `cwd`
-- * a pattern or array of patterns like `.git` or `lua`.
-- * a function with signature `function(buf) -> string|string[]`
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- Set LSP servers to be ignored when used with `util.root.detectors.lsp`
-- for detecting the LSP root
vim.g.root_lsp_ignore = { "copilot" }

-- Hide deprecation warnings
vim.g.deprecation_warnings = false

-- Show the current document symbols location from Trouble in lualine
-- You can disable this for a buffer by setting `vim.b.trouble_lualine = false`
vim.g.trouble_lualine = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
-- For more options, you can see `:help option-list`

opt.backspace = { "indent", "eol", "start" }
opt.autoindent = true
opt.wildmenu = true
opt.autoread = true
opt.title = true
opt.swapfile = false
opt.backup = false
opt.exrc = true

-- Enable auto write
opt.autowrite = true

-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
-- Sync with system clipboard
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"

opt.completeopt = "menu,menuone,noselect"

-- Hide * markup for bold and italic, but not markers with substitutions
opt.conceallevel = 2

-- Confirm to save changes before exiting modified buffer
opt.confirm = true

-- Show which line your cursor is on
opt.cursorline = true

-- Use spaces instead of tabs
opt.expandtab = true

opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
}
opt.foldlevel = 99
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"

-- preview incremental substitute
opt.inccommand = "nosplit"

opt.jumpoptions = "view"

-- global statusline
opt.laststatus = 3

-- Wrap lines at convenient points
opt.linebreak = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
opt.list = true
opt.listchars = { tab = "| ", trail = "·", nbsp = "␣" }

-- Make line numbers default
opt.number = true

-- Add relative line numbers, to help with jumping.
opt.relativenumber = true

-- Popup blend
opt.pumblend = 10

-- Maximum number of entries in a popup
opt.pumheight = 10

-- Disable the default ruler
opt.ruler = false

-- Minimal number of screen lines to keep above and below the cursor
opt.scrolloff = 10

opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- Round indent
opt.shiftround = true

-- Size of an indent
opt.shiftwidth = 2

opt.shortmess:append({ W = true, I = true, c = true, C = true })

-- Don't show the mode, since it's already in the status line
opt.showmode = false

-- Columns of context
opt.sidescrolloff = 8

-- Keep signcolumn on by default
opt.signcolumn = "yes"

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.ignorecase = true
opt.smartcase = true

-- Insert indents automatically
opt.smartindent = true

opt.spelllang = { "en" }

-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

-- Number of spaces tabs count for
opt.tabstop = 2

-- True color support
opt.termguicolors = true

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = 300

-- Enable break indent
opt.breakindent = true

-- Save undo history
opt.undofile = true
opt.undodir = vim.fn.expand("$HOME/.local/share/nvim/undo")

opt.undolevels = 10000

-- Decrease update time
opt.updatetime = 200

-- Allow cursor to move where there is no text in visual block mode
opt.virtualedit = "block"

-- Command-line completion mode
opt.wildmode = "longest:full,full"

-- Minimum window width
opt.winminwidth = 5

-- Disable line wrap
opt.wrap = false

buf.fileencoding = "utf-8"

vim.g.marscode_disable_autocompletion = true
vim.g.marscode_no_map_tab = true
vim.g.marscode_disable_bindings = true

-- vim: ts=2 sts=2 sw=2 et
