-- indent
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true
vim.opt_local.smarttab = true
vim.opt_local.spell = true

local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_buf_set_keymap

keymap(0, "i", ",f", '<Esc>/<++><CR>:nohlsearch<CR>"_c4l', opts)
keymap(0, "i", ",c", "```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA", opts)
keymap(0, "i", ",1", "#<Space><Enter><++><Esc>kA", opts)
keymap(0, "i", ",2", "##<Space><Enter><++><Esc>kA", opts)
keymap(0, "i", ",3", "###<Space><Enter><++><Esc>kA", opts)
keymap(0, "i", ",4", "####<Space><Enter><++><Esc>kA", opts)
