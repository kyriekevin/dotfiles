local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      opts.remap = nil
    end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- quit
map("n", "<S-q>", ":q<CR>", { desc = "Quit" })

-- move
map("n", "<S-j>", "5j", { desc = "Move down quickly" })
map("n", "<S-k>", "5k", { desc = "Move up quickly" })
map("n", "<S-h>", "0", { desc = "Move to the start of line" })
map("n", "<S-l>", "$", { desc = "Move to the end of line" })

-- tab
map("n", "tn", ":tabnew<CR>", { desc = "New tab" })
map("n", "th", ":tabp<CR>", { desc = "Prev tab" })
map("n", "tl", ":tabn<CR>", { desc = "Next tab" })

-- buffer
map("n", "<leader>bh", ":bp<CR>", { desc = "Prev buffer" })
map("n", "<leader>bl", ":bn<CR>", { desc = "Next buffer" })

-- ESC
map("i", "jk", "<ESC>")
map("i", "kj", "<ESC>")
