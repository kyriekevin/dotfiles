# Neovim

> English · [中文](nvim.zh.md)

Kickstart-style **single-file** nvim config. The whole config lives in one `init.lua` — read top to bottom, no plugin tree, no distro. Covers **Phase 7a (core scaffold)** + **Phase 7b (navigation)**: options, keymaps, autocmds, and 12 plugins covering colorscheme, pickers, file tree, jump, git, textobjects, comment, statusbar, and tabs. Phases 7c–7d add LSP / polish in separate branches.

## How it works

| Thing | Where | Note |
|---|---|---|
| Config | `~/.config/nvim/init.lua` ← source `dot_config/nvim/init.lua` | Single file. `vim.g.mapleader = " "` is the first thing to run. |
| Plugin lock | `~/.config/nvim/lazy-lock.json` ← source `dot_config/nvim/lazy-lock.json` | commit hash per plugin — **tracked**, keeps both Macs on the same versions. |
| Plugin cache | `~/.local/share/nvim/lazy/<name>` | Populated by `lazy.nvim` on first launch. Not in source. |
| Undo dir | `~/.local/state/nvim/undo/` | `opt.undofile = true`. Not in source. |
| Installer | `brew install neovim` (from Brewfile) | No separate install step — `chezmoi apply` → `init.lua` → next `nvim` launch bootstraps lazy. |

## Concepts

**Kickstart-style.** Everything readable in one file. Based on [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). When `init.lua` grows past ~400 lines or LSP config needs its own space, we split into `lua/` sub-modules — not before.

**lazy.nvim.** The plugin manager. Two jobs:
1. **Bootstrap**: the block near the bottom of `init.lua` clones lazy.nvim into `~/.local/share/nvim/lazy/lazy.nvim` on first launch. Zero submodules, zero brew.
2. **Spec → install**: `require("lazy").setup({…})` takes a list of plugin specs (`"author/repo"` + `opts` / `event` / `keys`). lazy installs, lazy-loads them on demand, and writes `lazy-lock.json`.

**`lazy-lock.json` is tracked.** It pins each plugin's commit SHA. When the other Mac runs `chezmoi apply` + `nvim`, lazy reads the lock and checks out the exact same commits → identical plugin state across machines. Update by running `:Lazy sync` inside nvim, then `chezmoi add ~/.config/nvim/lazy-lock.json`.

**Karabiner caveat.** This Mac has Karabiner mapping **Caps→Ctrl** and **Ctrl+hjkl→arrow keys** at the OS layer. Consequence: `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` **never reach nvim** — they come through as `<Left>` / `<Down>` / `<Up>` / `<Right>`. Don't bind those. Safe Ctrl combos: `<C-w>…` (window ops), `<C-d>` / `<C-u>` (half-page), `<C-o>` / `<C-i>` (jump list).

**Color palette.** Catppuccin Mocha — same flavor as starship, ghostty, fastfetch, yazi. The whole terminal reads as one palette.

**Transparency** uses two separate catppuccin switches + an `opt`:

- `transparent_background = true` → unbackgrounds `Normal / NormalNC / SignColumn / EndOfBuffer` (the editor area).
- `float = { transparent = true }` → unbackgrounds `NormalFloat` and everything linked to it (which-key, telescope, blink.cmp, LSP hover, etc.).
- `opt.winblend = 0` (+ `opt.pumblend = 0`) → catppuccin only drops float bg when winblend is 0 (`editor.lua:40`: `bg = (float.transparent and winblend == 0) ? none : mantle`).

Drop all three if you move to a non-transparent terminal.

## Keymap reference

`<leader>` is `<Space>`. Hold `<leader>` to pop up which-key.

### General

| Keys | Mode | Action |
|---|---|---|
| `<Esc>` | normal | Clear search highlight |
| `<leader>w` | normal | Write buffer |
| `<leader>cd` | normal | Open diagnostic float under cursor (moved from `<leader>e` in 7b to free it for neo-tree) |
| `<leader>?` | normal | Show buffer-local keymaps (which-key) |
| `[d` / `]d` | normal | Previous / next diagnostic |

### Motion — `H` / `L` override vim defaults

Applied in `{ n, x, o }` (normal + visual + operator-pending) so `dL` / `yH` / `vL` all work.

| Keys | Action | Replaces vim default |
|---|---|---|
| `H` | Go to first non-blank char of line (`^`) | Top of viewport — use `zt` / `<C-u>` instead |
| `L` | Go to end of line (`$`) | Bottom of viewport — use `zb` / `<C-d>` instead |

Normal-mode `K` is intentionally left unbound in 7a; Phase 7c wires it to `vim.lsp.buf.hover()`.

### Visual

| Keys | Action |
|---|---|
| `<` / `>` | Indent left / right, keep selection |

### Window / split (vim built-ins, still work because `<C-w>` isn't Karabiner-mapped)

| Keys | Action |
|---|---|
| `<C-w>s` / `<C-w>v` | Horizontal / vertical split |
| `<C-w>h/j/k/l` | Move to window left/down/up/right |
| `<C-w>c` / `<C-w>o` | Close / keep only this window |
| `<C-w>=` | Equalize window sizes |

### mini.surround (Phase 7a plugin — LazyVim `gs` prefix)

| Keys | Action |
|---|---|
| `gsa{motion}{char}` | Surround add: `gsaiw)` → wrap inner-word with `()` |
| `gsd{char}` | Surround delete: `gsd"` → remove surrounding `""` |
| `gsr{old}{new}` | Surround replace: `gsr([` → replace `()` with `[]` |
| `gsf{char}` / `gsF{char}` | Find next / previous surround |
| `gsh{char}` | Highlight surround |
| `gsn` | Update `n_lines` (how far mini.surround looks for a match) |

### snacks.picker — `<leader>f*` unified (Phase 7b)

Files and search live under a single `<leader>f*` prefix (kickstart-ish unified prefix, LazyVim-ish key names). No `<leader>s*` split — one letter to remember, `f`.

| Keys | Action |
|---|---|
| `<leader>ff` | Find files (cwd) |
| `<leader><space>` | Buffers picker |
| `<leader>fr` | Recent files |
| `<leader>fg` | Grep project (live) |
| `<leader>fw` | Grep word under cursor (normal + visual selection) |
| `<leader>fh` | Help tags |
| `<leader>fk` | Keymaps |
| `<leader>fd` | Diagnostics (workspace) |
| `<leader>fn` | New empty buffer (`:enew`) |

In-buffer grep uses vim native `/` + `n`/`N` — no picker wrapper.

### neo-tree (Phase 7b)

| Keys | Action |
|---|---|
| `<leader>e` | Toggle neo-tree sidebar |

Inside the tree: `?` for help. `<space>` is unbound on purpose — neo-tree's default "toggle node" on `<space>` would shadow our leader.

### flash.nvim (Phase 7b — no leader)

| Keys | Mode | Action | Replaces vim default |
|---|---|---|---|
| `s` | n/x/o | Flash jump (type 2 chars → hint) | `s` substitute-char — use `cl` instead |
| `r` | o | Remote flash (`yr` yank at remote jump target, then return) | Normal-mode `r{char}` unaffected (flash only binds `o`) |

`S` (treesitter select) and `R` (treesitter search) ship with flash but are disabled here — they need nvim-treesitter, which comes in 7c.

### gitsigns (Phase 7b — `<leader>gh*` hunk cluster)

All bindings are buffer-local (installed by `on_attach` only when a file is git-tracked).

| Keys | Action |
|---|---|
| `]h` / `[h` | Next / previous hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghu` | Undo stage hunk |
| `<leader>ghp` | Preview hunk (inline float) |
| `<leader>ghb` | Blame current line (full commit + body) |
| `<leader>ghd` | Diff this file against HEAD |

### snacks.lazygit (Phase 7b)

| Keys | Action |
|---|---|
| `<leader>gg` | Open lazygit in a floating window (cwd) |

Everything else (file history, log, branches) lives inside the lazygit TUI — we intentionally skipped the extra `<leader>gf/gl` entries to keep the surface small.

### bufferline (Phase 7b)

| Keys | Action |
|---|---|
| `]b` / `[b` | Next / previous buffer |
| `<leader>bd` | Delete current buffer (`:bdelete`) |

### mini.comment (Phase 7b — no leader)

| Keys | Mode | Action |
|---|---|---|
| `gcc` | normal | Toggle line comment |
| `gc{motion}` | normal | Toggle comment over motion (`gcap` paragraph, `gc5j` next 5 lines) |
| `gc` | visual | Toggle comment over selection |

Auto-detects `commentstring` per filetype: Python `#`, C/C++ `//`, Lua `--`, …

### mini.ai (Phase 7b — textobjects)

Used as targets for vim operators (`d`, `c`, `y`, `v`). The form is `{operator}{a|i}{target}`:

| Target | Meaning | Example |
|---|---|---|
| `ab` / `ib` | Bracket block (auto-detects `()` / `[]` / `{}`) | `dab` delete whole block, `cib` change inside |
| `a(` `i(` `a[` `i[` `a{` `i{` | Specific bracket kind | `ci{` change inside `{}` |
| `a"` `i"` `a'` `i'` `` a` `` `` i` `` | Quote | `di"` delete inside `""` |
| `aa` / `ia` | Function argument | `daa` delete the whole arg (incl. comma) |
| `at` / `it` | HTML-like tag | `cit` change inside `<tag>…</tag>` |

`af`/`if` (function) and `ac`/`ic` (class) need treesitter and are deferred to 7c.

## Plugins

Each line in `init.lua` → one plugin. 7c/7d append to the same `require("lazy").setup({…})` call.

### Phase 7a (core)

| Plugin | Role | Load | Notes |
|---|---|---|---|
| `catppuccin/nvim` | Colorscheme (Mocha flavor) | eager, `priority = 1000` | Loads before everything else so other plugins pick up catppuccin hl groups. `vim.g.colors_name` reads as `catppuccin-mocha`. Integrations extended in 7b: `gitsigns`, `neotree`, `flash`, `snacks`. |
| `folke/which-key.nvim` | Keymap discovery popup | `event = "VeryLazy"` | Preset `classic` → full-width borderless bar at the bottom. Auto-surfaces `desc` fields from every `vim.keymap.set(..., { desc = "..." })`. |
| `echasnovski/mini.pairs` | Auto-close `() [] {} '' "" \`\`` | `event = "InsertEnter"` | Smart-delete companion bracket if you backspace on one. |
| `echasnovski/mini.surround` | `gsa/gsd/gsr/gsf/gsF/gsh/gsn` surround ops | `event = "VeryLazy"` | LazyVim-style `gs` prefix. Avoids `s` (reserved for flash in 7b), `ys/ds/cs` vim-surround style (collides with yank/change motions), and `gd/gr/gI` LSP family (7c). |

### Phase 7b (nav)

| Plugin | Role | Load | Notes |
|---|---|---|---|
| `nvim-tree/nvim-web-devicons` | Nerd-Font icon provider | lazy (required on demand) | Shared dep of neo-tree / lualine / bufferline / snacks. Requires a Nerd Font at the terminal layer — Ghostty uses Maple Mono NF. |
| `folke/snacks.nvim` | Umbrella: picker + lazygit + notifier + bigfile + quickfile + indent + input + statuscolumn | eager, `priority = 900` | Keymaps call `Snacks.picker.files()` etc. via the `Snacks` global installed at startup. `priority = 900` = loads right after catppuccin (1000) so highlight integration resolves cleanly. |
| `nvim-neo-tree/neo-tree.nvim` | Sidebar file tree (`v3.x` branch) | `cmd = "Neotree"` + `<leader>e` | Depends on `plenary.nvim`, `nui.nvim`, and devicons. `bind_to_cwd = false` → tree doesn't jump when you `:cd`. `follow_current_file = { enabled = true }` auto-reveals the current buffer on toggle. `window.mappings["<space>"] = "none"` frees leader when the tree is focused (neo-tree's default `<space>` = "toggle node" would otherwise shadow leader). |
| `folke/flash.nvim` | Two-char jump | `event = "VeryLazy"` + `s`/`r` | `s` / `r` bound in 7b; `S` / `R` (treesitter-based) deferred to 7c. |
| `lewis6991/gitsigns.nvim` | Gutter +/−/~ signs + hunk ops + blame | `event = { "BufReadPre", "BufNewFile" }` | Keybinds live in `on_attach` → buffer-local, zero keys in non-git buffers. Uses `nav_hunk("next"/"prev")`; `next_hunk`/`prev_hunk` are deprecated aliases. |
| `echasnovski/mini.ai` | Extended `a`/`i` textobjects | `event = "VeryLazy"` | Defaults: bracket / quote / arg / tag. `af`/`ic` need nvim-treesitter → 7c. |
| `echasnovski/mini.comment` | `gcc` / `gc{motion}` / visual `gc` comment toggle | `event = "VeryLazy"` | Auto-detects `commentstring` per filetype. |
| `nvim-lualine/lualine.nvim` | Statusline | `event = "VeryLazy"` | `globalstatus = true` → one bar across all splits. Theme = `catppuccin`. |
| `akinsho/bufferline.nvim` | Top tab-bar for buffers | `event = "VeryLazy"` | `opts = function()` so `catppuccin.special.bufferline` can be `require`'d AFTER catppuccin loads. `offsets` keeps neo-tree's sidebar from overlapping the tab-bar. |

## Change a setting

1. Edit `dot_config/nvim/init.lua`.
2. `chezmoi diff ~/.config/nvim/init.lua` — preview.
3. `chezmoi apply ~/.config/nvim/init.lua` — write.
4. Reload: inside nvim, `:source %`. Structural changes (plugin specs, autocmds) → restart nvim.
5. Run `bash tests/nvim.sh` to catch regressions.

## Add a plugin

1. Append a spec inside `require("lazy").setup({…})`:

    ```lua
    { "author/repo", event = "VeryLazy", opts = { … } },
    ```

2. Save `init.lua`, relaunch `nvim`. Lazy auto-installs on startup.
3. `:Lazy sync` inside nvim to also refresh `lazy-lock.json`.
4. `chezmoi add ~/.config/nvim/init.lua ~/.config/nvim/lazy-lock.json` — vendor both.

Spec keys worth knowing: `event` (lazy-load on `InsertEnter` / `BufReadPre` / `VeryLazy`), `keys` (lazy-load when keymap fires), `cmd` (lazy-load on `:Cmd`), `opts` (sugar — lazy calls `require(plugin).setup(opts)` for you).

## Health check

### Automated

```bash
bash tests/nvim.sh
```

34 checks: file presence, nvim/git on PATH, headless `+qa` startup, `Lazy! sync` exit code, all 16 plugin dirs populated (lazy.nvim + 4 Phase 7a + 8 Phase 7b + 3 deps `nvim-web-devicons`/`nui.nvim`/`plenary.nvim`), `lazy-lock.json` present, runtime probe (leader, colorscheme, number/relnum/expandtab/tabstop/shiftwidth/undofile/netrw-disabled, `Snacks` global loaded, `<leader>cd` diagnostic float bound).

### Manual

Open `nvim some-file.lua` in a real terminal:

**Phase 7a (core):**
- [ ] Splash shows, no red error message
- [ ] Background is catppuccin mocha purple/plum, not default dark
- [ ] `:echo mapleader` returns `' '` (a space)
- [ ] Line numbers visible, relativenumber on (numbers count from cursor)
- [ ] Type `<Space>` and hold → **which-key popup** appears (bottom full-width bar)
- [ ] `<Space>w` writes the buffer (`:w` runs, no prompt)
- [ ] In insert mode, type `(` → auto-closes to `()` with cursor between (**mini.pairs**)
- [ ] Delete the `(` with backspace → the `)` is auto-deleted too
- [ ] Type a word, normal mode, `gsaiw"` → word gets wrapped in `""` (**mini.surround add**)
- [ ] On that wrapped word, `gsd"` → quotes removed (**mini.surround delete**)
- [ ] Press `H` on a line with leading whitespace → cursor jumps to first non-blank char
- [ ] Press `L` → cursor jumps to end of line
- [ ] Yank text (`yy`) → flash highlight lingers briefly (autocmd working)

**Phase 7b (nav):**
- [ ] `<Space>ff` opens **snacks.picker** for files; typing narrows the list
- [ ] `<Space><space>` opens **buffers picker**; `<Enter>` switches
- [ ] `<Space>fg` opens **live grep**; type a pattern → matches across project appear
- [ ] `<Space>fw` on a word → grep with that word pre-filled
- [ ] `<Space>fh` / `<Space>fk` / `<Space>fd` → help / keymaps / diagnostics pickers
- [ ] `<Space>e` toggles **neo-tree** sidebar; it auto-reveals the current buffer
- [ ] Press `s` in normal mode → **flash** hint chars appear on visible matches; type 2 chars → cursor jumps
- [ ] Edit a git-tracked file; change a line → **gitsigns** `~` mark appears in the gutter
- [ ] `]h` / `[h` navigates between hunks; `<Space>ghp` previews; `<Space>ghb` shows full blame
- [ ] `<Space>gg` opens **lazygit** in a floating window
- [ ] `]b` / `[b` cycles **bufferline** tabs (need ≥2 buffers open)
- [ ] `<Space>bd` closes the current buffer
- [ ] `gcc` toggles line comment; in a Python buffer the prefix is `# `, in a Lua buffer `-- `
- [ ] `vaf` in a function — wait, that needs treesitter (7c); instead try `va{` to select the whole `{}` block
- [ ] **lualine** bar at bottom shows mode / branch / diagnostics count / filename
- [ ] **bufferline** tabs at top show each open buffer with icon
- [ ] `<Space>cd` opens diagnostic float (if there's a diagnostic on the current line)

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `nvim: command not found` | neovim not installed | `brew bundle` — Brewfile declares `neovim`. |
| Plugins missing / UI looks default | lazy bootstrap didn't run (first launch interrupted) | `nvim --headless '+Lazy! sync' +qa` — or just relaunch nvim. |
| `E5113: Error while calling lua chunk` on startup | syntax error in `init.lua` | `bash tests/nvim.sh` — the "Headless startup" section prints the error. |
| Colorscheme is default dark (not catppuccin) | catppuccin plugin failed to load | `:Lazy` → find `catppuccin` → `L` for log. Usually a git clone failure — `:Lazy restore` re-clones. |
| which-key popup doesn't appear | `timeoutlen` too short or which-key didn't load | `:echo &timeoutlen` should be ≥ 300. `:Lazy show which-key.nvim`. |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` mysteriously act as arrow keys | Karabiner is doing that — **by design** | See Concepts → Karabiner caveat. Rebind to `<leader>…` or use `<C-w>…` for windows. |
| `gsaiw)` doesn't wrap | mini.surround's `gs` prefix got shadowed | `:verbose map gsa` — if another plugin grabbed `gs*`, rebind in mini.surround's `opts.mappings` or unbind the conflict. |
| `H` / `L` don't jump as expected | another plugin (likely future 7b) re-bound them | `:verbose map H` / `:verbose map L` — find culprit, unmap or change its mapping. |
| `lazy-lock.json` diff noise after `:Lazy sync` | normal — upstream moved | Commit the update: `chezmoi add ~/.config/nvim/lazy-lock.json`. |
| `<leader>e` opens the file tree instead of diagnostic float | Intentional — 7b moved diagnostic float to `<leader>cd` to free `e` for neo-tree | Use `<leader>cd` for the diagnostic float. |
| Pressing `s` deletes a char and enters insert mode instead of Flash jumping | flash.nvim didn't load (VeryLazy autocmd didn't fire, or plugin errored) | `:Lazy load flash.nvim` then try again. Check `:Lazy` panel for errors. |
| `<leader>ff` errors: `attempt to index nil with 'picker'` | snacks.nvim not loaded or `Snacks` global missing | `:Lazy load snacks.nvim`. Check priority / lazy=false in the spec — both must be set for the Snacks global to exist at keypress time. |
| Neo-tree sidebar shows broken icon squares | Terminal font lacks Nerd Font glyphs | Confirm Ghostty is using a Nerd Font (`Maple Mono NF` per the ghostty config). Non-Nerd fonts → blank squares. |
| Pressing `<space>` inside neo-tree does nothing / steals leader | neo-tree's default "toggle node" on `<space>` vs our leader | We override `window.mappings["<space>"] = "none"` in the spec. If this rots, re-check the neo-tree block in `init.lua`. |
| Lualine bar doesn't appear | Plugin lazy-loaded too late (no file opened yet to trigger VeryLazy) | `:Lazy load lualine.nvim`. Or just open any file — `event = "VeryLazy"` fires shortly after startup. |
| Bufferline tabs missing colors / look default | catppuccin loaded after bufferline (racy) | We use `opts = function() ... require("catppuccin.special.bufferline").get_theme() ... end` so the require resolves at plugin-load time, after catppuccin. If you see this, check that the `opts` is a function, not a table. |
| Gitsigns signs don't appear in the gutter | File isn't git-tracked, or inside `.git/info/exclude` | `:Gitsigns attach` force-attaches. For un-tracked files there are no hunks to show — expected. |

## Gotchas

- **Single file, strict ordering.** `vim.g.mapleader` must be set **before** the lazy block — plugins register keymaps at load time, so they capture whatever `mapleader` is at that moment. Don't reorder.
- **`<C-h>` family is dead on this Mac.** Karabiner eats them. Every keymap file in this repo assumes that; new bindings should avoid those combos.
- **Chezmoi manages two files only** in 7a: `init.lua` and `lazy-lock.json`. `~/.local/share/nvim/lazy/` is **destination-only runtime** — don't `chezmoi add` it (would vendor megabytes of plugin source).
- **Undo is persistent.** `opt.undofile = true` writes to `~/.local/state/nvim/undo/`. Changes you undo after closing/reopening nvim still work — but also means deleted-then-quit files' undo history persists on disk.
- **`mini.pairs` runs on `InsertEnter`.** First time you enter insert mode after launch has a ~ms stall as it loads. Intentional — keeps cold start fast.
- **`H` / `L` override vim's viewport jumps.** Vim default: `H` = home-of-viewport, `L` = last-of-viewport. We trade them for line-start / line-end (muscle memory that carries from VS Code / many IDEs). If you need viewport-top, use `zt` / `<C-u>`; viewport-bottom → `zb` / `<C-d>`.
- **mini.surround uses `gs` not `s`.** `s` in normal mode is kept free for Phase 7b's flash plugin. `gs` in vim default is "gotoSleep" (sleeps for count seconds) — we override it without remorse.
- **`<leader>` cluster taxonomy.** 7b locked these prefixes: `<leader>f*` picker (files + search, no `<leader>s*` split), `<leader>g*` git (lazygit `gg`, gitsigns `gh*`), `<leader>b*` buffer, `<leader>c*` code (currently just `cd` diagnostic; 7c fills `ca`/`cr`), `<leader>e` explorer. Keep new keymaps in these clusters.
- **flash's `s` overrides vim substitute-char.** Use `cl` for single-char substitute instead. `r{char}` (normal-mode replace) is unaffected — flash only binds `r` in operator-pending mode.
- **snacks has a `Snacks` global.** Set at startup by snacks.nvim (lazy=false + priority=900). All picker keys call `Snacks.picker.files()` etc. — if the global is missing, every picker keybind fails. `bash tests/nvim.sh` checks `_G.Snacks ~= nil`.
- **neo-tree eats `<space>` inside its own window.** Default mapping is "toggle node"; we override to `"none"` so leader still works. If you later add neo-tree features, preserve this override.
- **bufferline uses `opts = function()`.** The `highlights = require("catppuccin.special.bufferline").get_theme()` call must resolve AFTER catppuccin loads. Table form (`opts = {...}`) would evaluate at spec-read time and race.
- **treesitter is intentionally absent in 7b.** It comes in 7c. Consequences: flash `S`/`R` (treesitter jump/search) aren't bound; mini.ai's function/class textobjects (`af`/`ac`) fall back to defaults. Syntax highlighting is vim-legacy regex until 7c.

## Rebuild from scratch

```bash
# Nuke plugin cache + undo history + lazy state. Keeps init.lua and lazy-lock.
rm -rf ~/.local/share/nvim ~/.local/state/nvim

# Re-apply config + bootstrap:
chezmoi apply ~/.config/nvim/
nvim --headless '+Lazy! sync' '+qa'
```

If `init.lua` itself rots locally:

```bash
chezmoi apply ~/.config/nvim/init.lua
```

## Roadmap

What's coming in later phases — tracked in `/Users/bytedance/.claude/plans/0-1-dotfiles-stow-dotfiles-bk-jolly-boole.md`:

- **7b nav** ✓ shipped: snacks (picker+lazygit+notifier+bigfile+…) / neo-tree / flash / gitsigns / mini.ai / mini.comment / lualine / bufferline
- **7c lsp**: mason + mason-tool-installer / nvim-lspconfig (basedpyright + clangd + lua_ls) / blink.cmp / conform.nvim + **nvim-treesitter** (unlocks flash `S`/`R` + mini.ai `af`/`ic`) + todo-comments + trouble
- **7d polish**: indent-blankline / undotree / rest TBD

Each is a separate `feat/nvim-*` branch + PR; each adds to this same `init.lua` (and may split into `lua/` sub-modules once the file gets long).
