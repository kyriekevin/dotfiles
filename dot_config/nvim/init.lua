-- kickstart-style single-file nvim config.
-- See docs/nvim.md for orientation, keymap reference, and health checks.
--
-- Phase 7a (core):  options + keymaps + autocmds + lazy bootstrap
--                   + catppuccin / which-key / mini.pairs / mini.surround
-- Phase 7b (nav):   snacks (picker+lazygit+…) / neo-tree / flash / gitsigns
--                   / mini.ai / mini.comment / lualine / bufferline
-- Phase 7c (lsp):   mason / lspconfig / blink.cmp / conform + treesitter
--                   + todo-comments + trouble                              [TODO]
-- Phase 7d (polish):indent-blankline / undotree / others                   [TODO]

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
-- No smartindent: it predates filetype plugins and does weird things (notably
-- Python `#` comments getting re-indented to col 0 because C preprocessor
-- semantics). nvim ships per-filetype indent under runtime/indent/ — better.

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
-- undodir defaults to stdpath("state").."/undo//" — the trailing `//` tells
-- nvim to encode the full path into the undo filename, preventing collisions
-- between same-basename files in different dirs. Don't override, default wins.

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
vim.g.loaded_netrw = 1      -- neo-tree replaces netrw (Phase 7b)
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
-- vim.lsp.buf.hover() on LSP-attach. <leader>e moved to neo-tree in 7b;
-- the diagnostic float reads off the <leader>c* (code) cluster that 7c
-- will extend with <leader>ca code-action and <leader>cr rename.
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Diagnostic float" })

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
                gitsigns = true,
                neotree = true,
                flash = true,
                snacks = { enabled = true, indent_scope_color = "lavender" },
                -- 7c will add: native_lsp, blink_cmp, mason, trouble.
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
    -- version = "*" tracks the latest semver tag (mini.nvim ships v0.15/0.16/…).
    -- lazy-lock.json is still the authoritative pin — `version` only affects
    -- which commit `:Lazy update` selects.
    { "echasnovski/mini.pairs",    version = "*",   event = "InsertEnter", opts = {} },

    -- LazyVim-style `gs` prefix (add=gsa delete=gsd replace=gsr find=gsf
    -- find_left=gsF highlight=gsh update_n_lines=gsn). Avoids `s` (reserved
    -- for flash in 7b), `ys/ds/cs` (collide with yank/change motions), and
    -- `gd/gr/gI` (LSP go-to family in 7c).
    {
        "echasnovski/mini.surround",
        version = "*",
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

    -- ─── Phase 7b (nav) ─────────────────────────────────────────────────────

    -- Shared icon font used by neo-tree / lualine / bufferline / snacks.
    -- Needs a Nerd Font at the terminal layer (Ghostty uses Maple Mono NF).
    { "nvim-tree/nvim-web-devicons", lazy = true },

    -- Snacks: LazyVim 2025 umbrella. We use picker (file/grep/buffer finder),
    -- lazygit (floating lazygit), notifier (vim.notify UI), bigfile (disables
    -- features on >1.5MB files), quickfile (fast direct-open startup),
    -- indent (indent guides — replaces indent-blankline), input (vim.ui.input
    -- replacement), statuscolumn (gutter layout). lazy=false + priority so
    -- the `Snacks` global and bigfile autocmd are ready for first BufRead.
    {
        "folke/snacks.nvim",
        priority = 900,
        lazy = false,
        ---@type snacks.Config
        opts = {
            picker       = { enabled = true },
            lazygit      = { enabled = true },
            notifier     = { enabled = true, timeout = 3000 },
            bigfile      = { enabled = true },
            quickfile    = { enabled = true },
            indent       = { enabled = true },
            input        = { enabled = true },
            statuscolumn = { enabled = true },
            -- bufdelete closes buffers without collapsing the window — better
            -- than :bdelete when you have splits open. `<leader>bd` below uses it.
            bufdelete    = { enabled = true },
        },
        keys = {
            -- Picker: <leader>f* (files+search unified, no <leader>s* split)
            { "<leader>ff",      function() Snacks.picker.files() end,              desc = "Find files" },
            { "<leader><space>", function() Snacks.picker.buffers() end,            desc = "Buffers" },
            { "<leader>fr",      function() Snacks.picker.recent() end,             desc = "Recent files" },
            { "<leader>fg",      function() Snacks.picker.grep() end,               desc = "Grep project" },
            { "<leader>fw",      function() Snacks.picker.grep_word() end,          desc = "Grep word", mode = { "n", "x" } },
            { "<leader>fh",      function() Snacks.picker.help() end,               desc = "Help tags" },
            { "<leader>fk",      function() Snacks.picker.keymaps() end,            desc = "Keymaps" },
            { "<leader>fd",      function() Snacks.picker.diagnostics() end,        desc = "Diagnostics" },
            { "<leader>fn",      "<cmd>enew<cr>",                                   desc = "New file" },
            -- Lazygit (only <leader>gg — user scoped out gf/gl)
            { "<leader>gg",      function() Snacks.lazygit() end,                   desc = "Lazygit" },
        },
    },

    -- neo-tree: sidebar file tree. bind_to_cwd=false keeps the tree anchored
    -- while you :cd around in nvim. filesystem.follow_current_file auto-
    -- reveals the current buffer on toggle. window.mappings <space>=none
    -- unbinds neo-tree's own <space> (which would eat our leader when the
    -- tree is focused).
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        cmd = "Neotree",
        keys = {
            { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer (neo-tree)" },
        },
        opts = {
            filesystem = {
                bind_to_cwd = false,
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true,
            },
            window = {
                mappings = {
                    ["<space>"] = "none",
                },
            },
        },
    },

    -- flash: two-char jump. 7b binds only `s` (jump, n/x/o) and `r` (remote, o).
    -- `S` (treesitter select) and `R` (treesitter search) require nvim-treesitter
    -- and are deferred to 7c. `s` overrides vim's substitute-char — use `cl`.
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {},
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,   desc = "Flash jump" },
            { "r", mode = "o",               function() require("flash").remote() end, desc = "Remote flash" },
        },
    },

    -- gitsigns: gutter +/−/~ + hunk operations. Keymaps live in on_attach so
    -- they're buffer-local (only active in tracked files). nav_hunk is the
    -- newer API; next_hunk/prev_hunk are deprecated aliases.
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            on_attach = function(bufnr)
                local gs = require("gitsigns")
                local function m(lhs, rhs, desc)
                    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
                end
                m("]h",          function() gs.nav_hunk("next") end,              "Next hunk")
                m("[h",          function() gs.nav_hunk("prev") end,              "Previous hunk")
                m("<leader>ghs", gs.stage_hunk,                                   "Stage hunk")
                m("<leader>ghr", gs.reset_hunk,                                   "Reset hunk")
                m("<leader>ghu", gs.undo_stage_hunk,                              "Undo stage hunk")
                m("<leader>ghp", gs.preview_hunk,                                 "Preview hunk")
                m("<leader>ghb", function() gs.blame_line({ full = true }) end,   "Blame line (full)")
                m("<leader>ghd", gs.diffthis,                                     "Diff this file")
            end,
        },
    },

    -- mini.ai: extended textobjects. Defaults cover ab/ib (bracket), aq/iq
    -- (quote), aa/ia (argument), at/it (html-like tag). af/ic (function/class)
    -- need nvim-treesitter — deferred to 7c.
    { "echasnovski/mini.ai",      version = "*", event = "VeryLazy", opts = {} },

    -- mini.comment: gcc line toggle, gc{motion} range toggle, visual gc block
    -- toggle. Auto-detects commentstring: Python `#`, C++ `//`, Lua `--`, …
    { "echasnovski/mini.comment", version = "*", event = "VeryLazy", opts = {} },

    -- lualine: statusbar (mode / branch / diff / diagnostics / file / ft / loc).
    -- globalstatus=true = single bar spanning all splits (nvim 0.7+ feature).
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme                = "catppuccin",
                globalstatus         = true,
                component_separators = "|",
                section_separators   = "",
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
    },

    -- bufferline: top tab-bar for buffers. Catppuccin exposes bufferline
    -- highlights at `catppuccin.special.bufferline.get_theme()` (NOT under
    -- groups.integrations — that tree has a different purpose). opts is a
    -- function so the require resolves AFTER catppuccin's lazy=false load,
    -- preventing "module not found" races at spec-read time.
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            { "]b",          "<cmd>BufferLineCycleNext<cr>",     desc = "Next buffer" },
            { "[b",          "<cmd>BufferLineCyclePrev<cr>",     desc = "Previous buffer" },
            { "<leader>bd",  function() Snacks.bufdelete() end,  desc = "Delete buffer" },
        },
        opts = function()
            return {
                options = {
                    diagnostics            = "nvim_lsp",
                    always_show_bufferline = true,
                    offsets = {
                        {
                            filetype   = "neo-tree",
                            text       = "Neo-tree",
                            highlight  = "Directory",
                            text_align = "left",
                        },
                    },
                },
                highlights = require("catppuccin.special.bufferline").get_theme(),
            }
        end,
    },
}, {
    ui = { border = "rounded" },
    change_detection = { notify = false },
})
