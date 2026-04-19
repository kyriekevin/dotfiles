-- kickstart-style single-file nvim config.
-- See docs/nvim.md for orientation, keymap reference, and health checks.
--
-- Phase 7a (core):  options + keymaps + autocmds + lazy bootstrap
--                   + catppuccin / which-key / mini.pairs / mini.surround
-- Phase 7b (nav):   telescope / oil / flash / gitsigns / lazygit  [TODO]
-- Phase 7c (lsp):   mason / lspconfig / blink.cmp / conform        [TODO]
-- Phase 7d (polish):treesitter / lualine / comment / indent-blankline / todo [TODO]

-- ─── Leader (must come before any plugin loads) ─────────────────────────────
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ─── Options ────────────────────────────────────────────────────────────────
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true

opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.smartindent = true

opt.wrap = false
opt.linebreak = true
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.signcolumn = "yes"

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

opt.splitright = true
opt.splitbelow = true

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"

opt.updatetime = 250
opt.timeoutlen = 400

opt.termguicolors = true
opt.background = "dark"

opt.clipboard = "unnamedplus"
opt.mouse = "a"

-- Required companion to catppuccin's float.transparent — NormalFloat only
-- goes bg=NONE when winblend is 0. See catppuccin editor.lua:40.
opt.winblend = 0
opt.pumblend = 0

opt.completeopt = { "menu", "menuone", "noselect" }

opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Karabiner on this machine maps Caps→Ctrl and Ctrl+hjkl→arrow keys at the OS
-- layer. That means <C-h/j/k/l> never reach nvim — avoid binding them. Use
-- <leader>…, <C-w>… (window ops), and arrow keys instead.
vim.g.loaded_netrw = 1      -- oil.nvim will replace netrw in Phase 7b
vim.g.loaded_netrwPlugin = 1

-- ─── Keymaps ────────────────────────────────────────────────────────────────
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- File ops (leader-prefixed; which-key will document these)
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write buffer" })

-- H / L jump to first non-blank / end of line in every mode that motions
-- can operate in (n = normal, x = visual, o = operator-pending). So `dL`
-- deletes to EOL, `yH` yanks to BOL, `vL` selects to EOL, etc.
map({ "n", "x", "o" }, "H", "^", { desc = "Go to first non-blank char" })
map({ "n", "x", "o" }, "L", "$", { desc = "Go to end of line" })

-- Visual-mode indent keeps selection
map("v", "<", "<gv", { desc = "Indent left + reselect" })
map("v", ">", ">gv", { desc = "Indent right + reselect" })

-- Diagnostics (LSP comes in 7c; these still work with vim.diagnostic today).
-- Normal-mode K is intentionally left unbound here — Phase 7c wires it to
-- vim.lsp.buf.hover() on LSP-attach.
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic float" })

-- ─── Autocmds ───────────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight yanked text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})

-- ─── Bootstrap lazy.nvim ────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- ─── Plugins ────────────────────────────────────────────────────────────────
require("lazy").setup({
    -- Colorscheme. Loaded eagerly + priority=1000 so other plugins pick up
    -- catppuccin highlight groups on first render.
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        lazy = false,
        opts = {
            flavour = "mocha",
            -- Inherit ghostty's background (terminal is transparent, so is nvim).
            -- transparent_background handles Normal/NormalNC/SignColumn/EndOfBuffer;
            -- float.transparent handles NormalFloat + every plugin float (which-key,
            -- telescope, blink.cmp, lsp hover). Both needed together with winblend=0
            -- (see editor.lua:40: bg=(float.transparent and winblend==0) ? none : mantle).
            transparent_background = true,
            float = { transparent = true, solid = false },
            integrations = {
                mini = { enabled = true },
                which_key = true,
                -- 7b+ will enable telescope / gitsigns / blink_cmp here.
            },
        },
        config = function(_, o)
            require("catppuccin").setup(o)
            vim.cmd.colorscheme("catppuccin")
        end,
    },

    -- Hold any prefix (e.g. <leader>) → popup lists available bindings.
    -- classic preset = full-width bar at bottom, borderless. (helix = tiny
    -- bottom-right box; modern = 90% centered float.)
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = { preset = "classic" },
        keys = {
            {
                "<leader>?",
                function() require("which-key").show({ global = false }) end,
                desc = "Buffer-local keymaps",
            },
        },
    },

    -- Auto-close + smart-delete for () [] {} '' "" ``.
    { "echasnovski/mini.pairs",    version = false, event = "InsertEnter", opts = {} },

    -- LazyVim-style `gs` prefix (add=gsa delete=gsd replace=gsr find=gsf
    -- find_left=gsF highlight=gsh update_n_lines=gsn). Avoids `s` (reserved
    -- for flash in 7b), `ys/ds/cs` (collide with yank/change motions), and
    -- `gd/gr/gI` (LSP go-to family in 7c).
    {
        "echasnovski/mini.surround",
        version = false,
        event = "VeryLazy",
        opts = {
            mappings = {
                add            = "gsa",
                delete         = "gsd",
                find           = "gsf",
                find_left      = "gsF",
                highlight      = "gsh",
                replace        = "gsr",
                update_n_lines = "gsn",
            },
        },
    },
}, {
    ui = { border = "rounded" },
    change_detection = { notify = false },
})
