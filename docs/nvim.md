# Neovim

> English · [中文](nvim.zh.md)

Kickstart-style **single-file** nvim config. The whole config lives in one `init.lua` — read top to bottom, no plugin tree, no distro. This is Phase 7a (core scaffold: options + keymaps + autocmds + 4 base plugins). Phases 7b–7d add navigation / LSP / polish in separate branches.

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

## Keymap reference (Phase 7a)

`<leader>` is `<Space>`. Hold `<leader>` to pop up which-key.

### General

| Keys | Mode | Action |
|---|---|---|
| `<Esc>` | normal | Clear search highlight |
| `<leader>w` | normal | Write buffer |
| `<leader>e` | normal | Open diagnostic float under cursor |
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

## Plugins (Phase 7a)

Four plugins. Each line in `init.lua` → one plugin. Future phases append to the same `require("lazy").setup({…})` call.

| Plugin | Role | Load | Notes |
|---|---|---|---|
| `catppuccin/nvim` | Colorscheme (Mocha flavor) | eager, `priority = 1000` | Loads before everything else so other plugins pick up catppuccin hl groups. `vim.g.colors_name` reads as `catppuccin-mocha`. |
| `folke/which-key.nvim` | Keymap discovery popup | `event = "VeryLazy"` | Preset `classic` → full-width borderless bar at the bottom (`width = math.huge`, `col = 0`, `row = -1`). Auto-surfaces `desc` fields from every `vim.keymap.set(..., { desc = "..." })`. Other presets: `helix` = bottom-right 30–60 col box, `modern` = 90% centered rounded float. |
| `echasnovski/mini.pairs` | Auto-close `() [] {} '' "" \`\`` | `event = "InsertEnter"` | Smart-delete companion bracket if you backspace on one. |
| `echasnovski/mini.surround` | `gsa/gsd/gsr/gsf/gsF/gsh/gsn` surround ops | `event = "VeryLazy"` | LazyVim-style `gs` prefix. Avoids `s` (reserved for flash in 7b), `ys/ds/cs` vim-surround style (collides with yank/change motions), and `gd/gr/gI` LSP family (7c). |

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

21 checks: file presence, nvim/git on PATH, headless `+qa` startup, `Lazy! sync` exit code, all 5 plugin dirs populated (lazy.nvim + 4 Phase 7a), `lazy-lock.json` present, runtime probe (leader, colorscheme, number/relnum/expandtab/tabstop/shiftwidth/undofile/netrw-disabled).

### Manual

Open `nvim some-file.lua` in a real terminal:

- [ ] Splash shows, no red error message
- [ ] Background is catppuccin mocha purple/plum, not default dark
- [ ] `:echo mapleader` returns `' '` (a space)
- [ ] Line numbers visible, relativenumber on (numbers count from cursor)
- [ ] Type `<Space>` and hold → **which-key popup** appears listing `w / q / Q / e / ?`
- [ ] `<Space>w` writes the buffer (`:w` runs, no prompt)
- [ ] In insert mode, type `(` → auto-closes to `()` with cursor between (**mini.pairs**)
- [ ] Delete the `(` with backspace → the `)` is auto-deleted too
- [ ] Type a word, normal mode, `gsaiw"` → word gets wrapped in `""` (**mini.surround add**)
- [ ] On that wrapped word, `gsd"` → quotes removed (**mini.surround delete**)
- [ ] `gsr"'` on another wrapped word → `""` becomes `''` (**mini.surround replace**)
- [ ] Press `H` on a line with leading whitespace → cursor jumps to first non-blank char (not col 0)
- [ ] Press `L` → cursor jumps to end of line
- [ ] `dL` deletes from cursor to EOL; `yH` yanks from cursor to first non-blank
- [ ] Yank text (`yy`) → flash highlight lingers briefly (autocmd working)
- [ ] `:Lazy` opens the plugin manager panel

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

## Gotchas

- **Single file, strict ordering.** `vim.g.mapleader` must be set **before** the lazy block — plugins register keymaps at load time, so they capture whatever `mapleader` is at that moment. Don't reorder.
- **`<C-h>` family is dead on this Mac.** Karabiner eats them. Every keymap file in this repo assumes that; new bindings should avoid those combos.
- **Chezmoi manages two files only** in 7a: `init.lua` and `lazy-lock.json`. `~/.local/share/nvim/lazy/` is **destination-only runtime** — don't `chezmoi add` it (would vendor megabytes of plugin source).
- **Undo is persistent.** `opt.undofile = true` writes to `~/.local/state/nvim/undo/`. Changes you undo after closing/reopening nvim still work — but also means deleted-then-quit files' undo history persists on disk.
- **`mini.pairs` runs on `InsertEnter`.** First time you enter insert mode after launch has a ~ms stall as it loads. Intentional — keeps cold start fast.
- **`H` / `L` override vim's viewport jumps.** Vim default: `H` = home-of-viewport, `L` = last-of-viewport. We trade them for line-start / line-end (muscle memory that carries from VS Code / many IDEs). If you need viewport-top, use `zt` / `<C-u>`; viewport-bottom → `zb` / `<C-d>`.
- **mini.surround uses `gs` not `s`.** `s` in normal mode is kept free for Phase 7b's flash plugin. `gs` in vim default is "gotoSleep" (sleeps for count seconds) — we override it without remorse.

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

- **7b nav**: telescope.nvim / oil.nvim / flash.nvim / gitsigns / lazygit.nvim
- **7c lsp**: mason + mason-tool-installer / nvim-lspconfig (basedpyright + clangd + lua_ls) / blink.cmp / conform.nvim
- **7d polish**: nvim-treesitter / lualine / Comment / indent-blankline / todo-comments / undotree

Each is a separate `feat/nvim-*` branch + PR; each adds to this same `init.lua` (and may split into `lua/` sub-modules once the file gets long).
