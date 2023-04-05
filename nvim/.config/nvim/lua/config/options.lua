-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt  -- for conciseness

local options = {
  backup = false,                         -- creates a backup file
  swapfile = false,                       -- creates a swapfile
  wildmenu = true,                        -- show a navigable menu for completion
  autoindent = true,
  listchars = {tab = '| ', trail = '.'},

  ttyfast = true,
  lazyredraw = true,
  visualbell = true,

  backspace = "indent,eol,start"
}

for k, v in pairs(options) do
  opt[k] = v
end


