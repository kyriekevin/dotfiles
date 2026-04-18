# Yazi

> English · [中文](yazi.zh.md)

Blazing-fast Rust TUI file manager. Three-column pane (parent / current / preview), vim-ish keys, native image/video/PDF preview, built-in integrations with `fzf` / `zoxide` / `fd` / `rg`. Bound to `y` (a shell function, not an alias — see below) so quitting yazi drops you into whichever directory you last browsed.

## How it works

| Thing | Where | Note |
|---|---|---|
| Config | `~/.config/yazi/yazi.toml` ← source `dot_config/yazi/yazi.toml` | Manager / preview / opener. Reloaded on every launch — no daemon. |
| Keymap | `~/.config/yazi/keymap.toml` ← source `dot_config/yazi/keymap.toml` | `prepend_keymap` stacks on top of yazi's defaults. |
| Theme | `~/.config/yazi/theme.toml` ← source `dot_config/yazi/theme.toml` | Activates the `catppuccin-mocha` flavor (UI palette + syntect tmTheme for syntax-highlighted previews). |
| Init | `~/.config/yazi/init.lua` ← source `dot_config/yazi/init.lua` | Plugin bootstrap (`full-border`, `git`). |
| Plugin dir | `~/.config/yazi/plugins/` | Populated by `ya pkg add` via `.chezmoiscripts/run_onchange_after_40-yazi-plugins.sh`. **Not in source** — regenerated on apply. |
| Flavor dir | `~/.config/yazi/flavors/` | Same mechanism as plugin dir; stores full theme packs (`catppuccin-mocha`). **Not in source.** |
| Shell wrapper | `~/.config/zsh/tools.zsh` → `y()` function | Runs `yazi --cwd-file=$tmp`; on quit, parent shell `cd`s to yazi's last CWD. |
| Cache | `~/.cache/yazi/` | Image/video thumbnails. Safe to delete — regenerated on next preview. |

## Concepts

Before tweaking anything, useful to know:

**Two binaries, one brew:** `brew install yazi` ships both `yazi` (the TUI) and `ya` (its control channel — used by `ya pkg` for plugins, `ya emit` for scripted events). You'll rarely call `ya` by hand; it mostly lives behind the plugin manager.

**Three columns, one ratio:** `[mgr] ratio = [1, 3, 4]` — parent / current / preview. Preview is widest because that's where image/video/code-with-syntax-highlight lives. Shrink/expand preview with `h` / `l` (bound when cursor is over preview).

**Opener rules, not hardcoded:** "What happens when I press `<Enter>` on a file?" isn't wired to a single command. It walks `[open] prepend_rules` top-to-bottom: first rule whose `mime` / `name` matches wins, and its `use = [...]` list picks an opener block from `[opener]`. This is why we can send `.sh` files to `nvim` without touching the macOS Launch Services handler for everything else.

**Plugins vs flavors:** A **plugin** extends behavior (new previewer, keybind, status column). A **flavor** is a theme pack with UI palette + tmTheme for syntax-highlighted previews. Both are installed through `ya pkg add`. We ship three plugins (`git`, `smart-enter`, `full-border`) and one flavor (`catppuccin-mocha`) — the flavor keeps yazi's preview syntax colors aligned with bat / starship / fastfetch, so the whole terminal stack reads as one palette.

**Terminal image protocol:** Yazi picks the image rendering protocol by sniffing `$TERM` / `$TERM_PROGRAM`. Ghostty implements the **Kitty graphics protocol** natively → pixel-perfect inline images with zero extra deps. Other terms (iTerm2 → iTerm2 protocol, tmux-without-passthrough → chafa fallback, Apple Terminal → none) degrade silently.

## Quick start (5-min tour)

1. Launch: type `y` in any shell.
2. Navigate: `j`/`k` move, `h` out, `l` in (into dir, or open file — `smart-enter` plugin).
3. See a directory tree scroll past: press `.` to toggle hidden files.
4. Mark multiple files: `space` toggles selection; `v` visual-select a range.
5. Copy + paste: navigate to source, `y`, navigate to target, `p`.
6. Rename one: `r`, edit, Enter.
7. **Bulk rename**: multi-select with `space` → `r` → yazi opens `$EDITOR` with all selected names → edit lines → save → yazi applies diff.
8. Search: `/` filename-grep current dir, `s` fd-find anywhere, `S` rg full-text search.
9. Jump: `z` zoxide (frecency), `Z` fzf (fuzzy over all dirs).
10. Find + enter a file via fzf: `Z`, type fragment, Enter, `l` to open.
11. Quit: `q` → shell `cd`s to yazi's last directory. `Q` quits without `cd`.

If step 1 fails with `command not found`, run `chezmoi apply` — Brewfile + plugin install happen there.

## Keymap reference

Our `keymap.toml` only overrides `l` / `<Enter>` for `smart-enter`. Everything else is yazi default. Press `~` in yazi for the live help overlay.

### Navigation

| Keys | Action |
|---|---|
| `h` / `j` / `k` / `l` | left / down / up / right (l = smart-enter) |
| `gg` / `G` | top / bottom |
| `Ctrl+u` / `Ctrl+d` | half-page up / down |
| `H` / `L` | history back / forward |
| `Tab` | switch to next tab |
| `t` | new tab at cursor location |
| `1`..`9` | jump to tab N |
| `[` / `]` | previous / next tab |

### Selection

| Keys | Action |
|---|---|
| `space` | toggle selection at cursor |
| `v` | enter visual-select mode |
| `Ctrl+a` | select all in current dir |
| `Ctrl+r` | reverse selection |
| `Esc` | clear selection |

### File operations

| Keys | Action |
|---|---|
| `y` | yank (copy) selection |
| `x` | cut selection |
| `p` | paste into current dir |
| `P` | paste with overwrite |
| `d` | move to Trash |
| `D` | permanent delete (no trash) |
| `a` | create file; trailing `/` creates a dir |
| `r` | rename (multi-select → bulk rename via `$EDITOR`) |
| `c` | copy full path to clipboard (submenu) |

### Search / jump

| Keys | Action |
|---|---|
| `/` | filter current dir (filename substring) |
| `?` | reverse filter |
| `n` / `N` | next / previous match |
| `s` | search files by name (via `fd`) |
| `S` | search file contents (via `rg`) |
| `z` | zoxide jump (needs zoxide) |
| `Z` | fzf jump (needs fzf) |
| `f` / `F` | find next / prev in current dir |

### Preview / layout

| Keys | Action |
|---|---|
| `K` / `J` | scroll preview up / down |
| `T` | toggle preview pane |
| `,` | sort submenu (a/c/m/s/e, `r` reverse) |
| `M` | linemode submenu (size / ctime / mtime / perms / owner / none) |
| `.` | toggle hidden files |

### Tasks / shell

| Keys | Action |
|---|---|
| `w` | task manager (background copies, extracts) |
| `:` | command palette (run yazi commands) |
| `!` | run shell command, block yazi |
| `Shift+!` | open shell in current directory |
| `Esc` | close menu / exit mode |
| `q` | quit; shell `cd`s to last yazi directory |
| `Q` | quit without `cd` |

### Spot (file metadata panel)

| Keys | Action |
|---|---|
| (move to file) + `Tab` | cycle metadata panels (file / EXIF / linked targets) |

## Shell wrapper `y()`

Canonical yazi-as-cd pattern. Without this wrapper, `yazi` just runs, shows stuff, quits, and you're still in whatever directory you started. With it:

```zsh
y() {
    local tmp cwd
    tmp="$(mktemp -t 'yazi-cwd.XXXXXX')"
    yazi "$@" --cwd-file="$tmp"           # yazi writes its last CWD here on quit
    if cwd="$(command cat -- "$tmp")" && [[ -n $cwd && $cwd != "$PWD" ]]; then
        builtin cd -- "$cwd"              # parent shell follows
    fi
    rm -f -- "$tmp"
}
```

Why `command cat` and `builtin cd`: our `aliases.zsh` rebinds `cat` → `bat` (colorized) and zsh can shadow `cd` with functions. Bypassing both keeps the wrapper robust if someone monkey-patches either later.

## Plugins + flavor

Listed in `.chezmoiscripts/run_onchange_after_40-yazi-plugins.sh`. Adding or removing a line there content-hashes the script → chezmoi re-runs on next `apply` → `ya pkg add` is invoked. `ya pkg add` is idempotent: already-registered packages exit silently, so re-runs cost ~0.

| Package | Kind | What it does | Wired by |
|---|---|---|---|
| `yazi-rs/plugins:git` | plugin | Decorates files with git status glyphs (`M` modified, `A` added, `?` untracked, `!` ignored) in the left gutter. | `yazi.toml [plugin.prepend_fetchers]` registers the fetcher; `init.lua` calls `require("git"):setup({ order = 1500 })`. |
| `yazi-rs/plugins:smart-enter` | plugin | Unifies `l` + `<Enter>`: directory → cd in; file → opener fires. No more "did I need `l` or `<Enter>` here?". | `keymap.toml [mgr] prepend_keymap` binds both keys to `plugin smart-enter`. |
| `yazi-rs/plugins:full-border` | plugin | Rounded borders around all three columns. Pure visual polish. | `init.lua` calls `require("full-border"):setup()`. Remove that one line to disable. |
| `yazi-rs/flavors:catppuccin-mocha` | flavor | Full UI palette + tmTheme for syntect previews — aligns with bat (`$BAT_THEME`), starship, and fastfetch so the whole terminal reads as one scheme. | `theme.toml [flavor] dark = "catppuccin-mocha"`. |

### git fetcher syntax gotcha

The git plugin's fetcher key is `url`, **not** `name`. Yazi silently accepts `name` but the fetcher never fires, so git glyphs quietly disappear. If you see no `M`/`A`/`?` in the gutter, check `yazi.toml`:

```toml
# Correct — yazi ≥26
[[plugin.prepend_fetchers]]
id    = "git"       # Optional on yazi > 26.1.22 per plugin README
url   = "*"         # ← `url`, not `name`
run   = "git"
group = "git"
```

The `tests/yazi.sh` regression guard `fetcher uses url= (not name=)` exists because this already bit us once during bring-up.

## Preview backends

Yazi sniffs `$PATH` for these at render time. All installed via Brewfile — dropping one silently degrades that file type to text (or nothing, for binary).

| File type | Backend | Brewfile entry |
|---|---|---|
| Image (PNG/JPG/GIF/WebP) | Kitty graphics protocol (built-in) | — |
| Image (HEIC/RAW/exotic) | `magick` converts → Kitty | `imagemagick` |
| Video (MP4/MOV/MKV) | `ffmpegthumbnailer` first-frame → Kitty | `ffmpegthumbnailer` |
| PDF | `pdftoppm` first page → Kitty | `poppler` |
| Archive (zip/7z/tar/rar) | `7z l` table-of-contents listing | `sevenzip` |
| Code / text | Yazi's bundled syntect — themed by the active flavor's tmTheme → matches bat | — |
| JSON | `jq` pretty-print (yazi built-in) | — |
| Symlink | Target path + resolved target preview | — |

## Change a setting

1. Edit `dot_config/yazi/yazi.toml` (or `keymap.toml` / `init.lua`).
2. No reload — yazi re-reads all three on every launch. Quit + `y` again.
3. For structural changes (new section, changed fetcher id), run `tests/yazi.sh` to catch silent breakage.

## Add a plugin

1. Append a line to `.chezmoiscripts/run_onchange_after_40-yazi-plugins.sh`:

    ```bash
    plugins=(
        "yazi-rs/plugins:git"
        "yazi-rs/plugins:smart-enter"
        "yazi-rs/plugins:full-border"
        "your-user/your-plugin:name"    # ← new line
    )
    ```

2. If the plugin is a **previewer / fetcher / preloader**, also wire it in `yazi.toml`:

    ```toml
    [plugin]
    prepend_previewers = [
      { mime = "image/*", run = "your-plugin" },
    ]
    ```

3. If it exposes a **key-bindable command**, add to `keymap.toml`:

    ```toml
    [[mgr.prepend_keymap]]
    on  = "X"
    run = "plugin your-plugin"
    ```

4. If it needs **boot-time setup**, add `require("your-plugin"):setup()` in `init.lua`.
5. `chezmoi apply` — the `run_onchange` hook fires, `ya pkg add` installs it.

## Health check

### Automated

```bash
bash tests/yazi.sh
```

~24 checks: binaries on PATH (`yazi`, `ya`), config + keymap + init.lua present, TOML parses (when python3 ≥ 3.11), expected sections / keys present, preview backends available (`ffmpegthumbnailer`, `magick`, `pdftoppm`, `7z`), plugins unpacked under `~/.config/yazi/plugins/` (skipped with a hint if apply hasn't run), Ghostty detection note.

### Manual (real TTY required)

1. In a fresh Ghostty tab: `y`.
2. Three-column layout visible with **rounded borders** (`full-border` plugin).
3. Arrow through a git repo — modified files carry a colored `M` / `A` / `?` glyph in the left gutter (`git` plugin).
4. `l` on a directory → enters it; `l` on a text file → opens in nvim (`smart-enter` plugin). Quit nvim → back in yazi.
5. Arrow to a PNG / JPG → preview shows the **actual image**, not ASCII art or `□` (Kitty graphics working).
6. Arrow to an MP4 → preview shows first-frame thumbnail (ffmpegthumbnailer → Kitty).
7. Arrow to a PDF → preview shows the rendered first page (poppler → Kitty).
8. Press `s`, type a fragment → fd matches stream live.
9. Press `Z`, type a fragment → fzf full-dir fuzzy picker. Enter → yazi jumps there.
10. Quit with `q` — terminal shell `cd`s to wherever yazi last was (`y()` wrapper working).

## Troubleshooting

**`y: command not found`** — you haven't sourced `tools.zsh` yet in the current shell. Open a new terminal tab, or `source ~/.zshrc`. Check `type y` returns a function definition.

**Image preview renders as blank / `□` / question marks** — Ghostty's Kitty protocol not reaching yazi. Check `echo $TERM_PROGRAM` prints `ghostty`. If running inside tmux/screen without passthrough, images won't render (known limitation — yazi falls back to no-op). Outside of Ghostty, you'd need chafa or a sixel terminal; we don't install those.

**PDF preview shows text dump** — `pdftoppm` missing. `command -v pdftoppm` must work. Re-run `brew bundle` or `brew install poppler`.

**Video preview shows nothing** — `ffmpegthumbnailer` missing. `brew install ffmpegthumbnailer`. Note: DRM'd video will fail anyway (no thumb extractable).

**Git status glyphs missing** — two root causes:
  1. Plugin not installed. Check `ls ~/.config/yazi/plugins/git.yazi` exists. If missing, `chezmoi apply`.
  2. Fetcher key name wrong. `yazi.toml [[plugin.prepend_fetchers]]` uses `url = "*"` **not** `name = "*"` — yazi ≥26 silently drops `name`-keyed fetchers. `tests/yazi.sh` catches this; run it if glyphs vanish after an edit.

**Preview syntax colors look off (not like bat)** — flavor not activated. Check `theme.toml` has `[flavor] dark = "catppuccin-mocha"` and `ls ~/.config/yazi/flavors/catppuccin-mocha.yazi` exists. Without the flavor, yazi's bundled syntect uses a generic dark theme that clashes with bat's Mocha palette.

**`smart-enter` not bound** — plugin not installed. Check `~/.config/yazi/plugins/smart-enter.yazi` exists. If missing, `chezmoi apply` to trigger `ya pkg add`.

**Borders missing (no rounding)** — `full-border` plugin not installed, or `init.lua` missing the `setup()` call. Confirm `~/.config/yazi/plugins/full-border.yazi` exists + `init.lua` has `require("full-border"):setup()`.

**`ya pkg add` fails on first apply** — `ya` is part of the `yazi` brew. If brew install hasn't completed yet, the plugin hook exits with a hint and skips. Fix: `brew bundle` → re-apply. Note: on yazi ≤0.4 the subcommand was `ya pack -a`; the install script targets ≥26.x.

**Opening `.sh` or `.py` launches `Terminal.app` instead of nvim** — `[open] prepend_rules` got skipped. Confirm `application/x-shellscript` rule is above the catch-all `{ name = "*" }` rule. Our yazi.toml has this correct; watch for it during edits.

**Bulk rename opens a weird editor** — yazi honors `$EDITOR`. Check `echo $EDITOR` returns `nvim`. If empty, the bulk-rename UI won't launch.

**`y` wrapper quits yazi but doesn't `cd`** — the wrapper only `cd`s when `$cwd` differs from `$PWD`. If you quit yazi at the same directory you started, no cd happens. Intentional.

## Gotchas

**Plugin install happens inside chezmoi, not `brew`.** Running `brew bundle` alone won't populate `~/.config/yazi/plugins/`. A full `chezmoi apply` is required — the `run_onchange_after_40-yazi-plugins.sh` hook is what invokes `ya pkg`.

**`run_onchange` hashes the script body, not the plugin list.** If you edit the plugin array, the script body changes and re-runs. But if you manually `ya pkg delete <plugin>` to uninstall without touching the script, chezmoi won't notice and won't re-install on next apply. Re-edit the script (even touching a comment) to force re-run.

**`$EDITOR` must be set for bulk rename.** Yazi's bulk-rename flow shells out to `$EDITOR`. Our `env.zsh` sets `EDITOR=nvim` — if that gets lost (remote session without env propagation), bulk rename silently falls back to a bad default.

**Image preview blows up memory on giant files.** `[tasks] image_alloc = 512 MiB` is the hard cap. 100MP images exceed this; yazi gives up rather than OOM. Tuning the cap trades safety for coverage.

**Ghostty image protocol skips frames on fast scrolling.** `[preview] image_delay = 30` ms debounces decoder calls. Lower it for snappier scrolling; raise it if you see tearing on a slow machine.

**TOML parse errors are mostly silent.** Yazi boots with bad config and just ignores broken sections. Tests/yazi.sh does a python-based TOML parse check (needs python3 ≥ 3.11 for `tomllib`). On older python it only structural-greps — keep that in mind.

**`plugins/` is not in chezmoi source.** Plugins live at destination only. If you clone this repo onto a fresh Mac and run `chezmoi apply`, the `run_onchange` script populates it. Don't try to `chezmoi add ~/.config/yazi/plugins` — it'd vendor megabytes of plugin source into the repo.

## Rebuild from scratch

```bash
# Delete plugin cache + thumbnail cache — yazi rebuilds both on next launch.
rm -rf ~/.config/yazi/plugins ~/.config/yazi/package.toml ~/.cache/yazi ~/.local/state/yazi

# Re-run the install hook explicitly (or just `chezmoi apply`):
chezmoi apply
```

If `y` runs but gives no preview, check: (1) `yazi` on PATH (`brew install yazi`), (2) `$TERM_PROGRAM=ghostty`, (3) preview backends (`ffmpegthumbnailer`, `magick`, `pdftoppm`, `7z`) on PATH, (4) plugins under `~/.config/yazi/plugins/`.
