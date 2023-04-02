local opt = vim.opt -- for conciseness

local options = {
	backup = false,								-- creates a backup file
	swapfile = false,							-- creates a swapfile
	clipboard = "unnamedplus",					-- allows neovim to access the system clipboard
	cmdheight = 1,								-- more space in the neovim command line for displaying messages
	completeopt = { "menuone", "noselect" },	-- mostly just for cmp
	number = true,								-- set numbered lines
	relativenumber = true,						-- set relative numbered lines
	fileencoding = "utf-8",						-- the encoding written to a file
	conceallevel = 0,							-- so that `` is visible in markdown files
	hlsearch = true,							-- highlight all matches on previous search pattern
	ignorecase = true,							-- ignore case in search patterns
	smartcase = true,							-- smart case
	mouse = "a",								-- allow the mouse to be used in neovim
	pumheight = 10,								-- pop up menu height
	showmode = false,							-- we don't need to see things like -- INSERT -- anymore
	showtabline = 4,							-- always show tabs
	smartindent = true,							-- make indenting smarter again
	scrolloff = 10,								-- minimal number of screen lines to keep above and below the cursor
	sidescrolloff = 10,							-- minimal number of screen columns either side of cursor if wrap is `false`
	cursorline = true,							-- highlight the current line
	undofile = true,							-- enable persistent undo
	termguicolors = true,						-- set term gui colors (most terminals support this)
	guifont = "monospace:h17",					-- the font used in graphical neovim applications
	wrap = false,								-- display lines as one long line
	linebreak = true,							-- companion to wrap, don't split words
	signcolumn = "yes",							-- always show the sign column, otherwise it would shift the text each time
	whichwrap = "bs<>[]hl",						-- which "horizontal" keys are allowed to travel to prev/next line
	numberwidth = 2,							-- set number column width to 2 {default 4}
	splitbelow = true,							-- force all horizontal splits to go below current window
	splitright = true,							-- force all vertical splits to go to the right of the current window
	updatetime = 300, 							-- faster completion (4000ms default)
	expandtab = false,							-- convert tabs to space
    shiftwidth = 4,                             -- the number of spaces inserted for each indentation
	tabstop = 4,								-- insert 4 spaces for a tab
	timeoutlen = 300,							-- time to wait for a mapped sequence to complete
	wildmenu = true,							-- show a navigable menu for tab completion

	autoindent = true,
	smartindent = true,
	list = true,
	listchars = {tab = '| ', trail = '.'},
	tw = 0,

	exrc = true,
	secure = true,

	inccommand = "split",
	completeopt = "longest,noinsert,menuone,noselect,preview",

	ttyfast = true,
	lazyredraw = true,
	visualbell = true,

	autochdir = true,
	laststatus = 2,

	wildmode = "longest,list,full",

	background = "dark",

	backspace = "indent,eol,start"
}

for k, v in pairs(options) do
	opt[k] = v
end

vim.o.incsearch = true

opt.iskeyword:append "-" -- hyphenated words recognized by searches
