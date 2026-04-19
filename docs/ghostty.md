# Ghostty

> English · [中文](ghostty.zh.md)

GPU-accelerated macOS terminal by Mitchell Hashimoto. Picked over iTerm2/Alacritty/WezTerm because its native **splits + tabs + quick-terminal + Kitty image protocol** cover the workflows that used to need tmux. With Claude Code increasingly assumed to run in a single-process terminal, removing tmux removes a whole layer of "who owns my clipboard / image protocol / keybind".

## How it works

| Thing | Where | Note |
|---|---|---|
| Config | `~/.config/ghostty/config` ← source `dot_config/ghostty/config` | Single file, `key = value`. Reloaded by `ctrl+s > r` or on next launch. |
| Binary + app | `/Applications/Ghostty.app`, CLI at `/opt/homebrew/bin/ghostty` | Installed via `cask "ghostty"` in Brewfile. |
| Font | `Maple Mono NF CN` | Installed via `cask "font-maple-mono-nf-cn"`. Same font is pinned by starship (Phase 4a). |
| Theme | `Catppuccin Mocha` (built-in) | No flavor install needed — shipped inside Ghostty's `+list-themes`. |
| Scrollback | In-memory ring buffer | `scrollback-limit = 10000` lines per surface. No on-disk persistence. |

## Why these choices

**Why no tmux?** Ghostty's native tabs + splits replace tmux's windows + panes, `window-save-state = always` replaces `tmux-resurrect`, and the Kitty graphics protocol replaces `tmux` image-passthrough headaches. One less layer between the shell and the GPU = faster redraws + working image preview in yazi.

**Why `ctrl+s` as chord prefix?** Three constraints collided:
1. **Karabiner** on this machine maps `Ctrl+h/j/k/l → arrow keys` globally. Any bare `ctrl+hjkl` binding in Ghostty is dead on arrival.
2. User prefers `Ctrl` over `Cmd` on HHKB (Ctrl sits where Caps Lock does — home-row pinky).
3. User's long-standing tmux prefix was `ctrl+s`.
Chord prefix resolves all three: the second key after `ctrl+s` is a bare letter, which Karabiner ignores. Ghostty intercepts `ctrl+s` before the PTY, so the historical terminal XOFF (freeze output) never fires.

**Why `Maple Mono NF CN` (not Italic)?** Starship (Phase 4a) needs NF glyphs (powerline triangles, MDI mac icon, feedback glyphs); zsh source inside this repo is ASCII so CN CJK coverage never hurts. Italic-as-body makes plain text slightly noisier — we want upright body + italic-on-demand for code spans that explicitly request italic.

## Quick start (2-min tour)

1. **Launch**: open Ghostty from Spotlight, or hit `⌘ + \`` anywhere to drop down the quick-terminal.
2. **Prefix**: `Ctrl+s`. Hold ctrl, tap s, release both, then tap the next key. ~1s timeout.
3. **Split right**: `Ctrl+s  |` (shift+backslash). **Split down**: `Ctrl+s  -`.
4. **Navigate splits**: `Ctrl+s  h/j/k/l` — matches vim; Karabiner-safe because post-chord.
5. **New tab**: `Ctrl+s  c`. **Close surface** (split or tab): `Ctrl+s  x`.
6. **Zoom current split full-screen**: `Ctrl+s  z`. Repeat to un-zoom.
7. **Reload this file**: edit, then `Ctrl+s  r`. No restart.

If any key does nothing, see [Troubleshooting](#troubleshooting) — usually Karabiner eats it.

## Keymap reference

Prefix is `Ctrl+s`. All chord bindings are "prefix, then the listed key". Bare bindings (no prefix) call out `[global]` or `[bare]`.

### Tabs (≈ tmux windows)

| Keys | Action |
|---|---|
| `c` | new tab |
| `n` / `p` | next / previous tab |
| `1`..`9` | go to tab N |
| `x` | close current surface (also works on splits) |

### Splits (≈ tmux panes)

| Keys | Action |
|---|---|
| `\|` (shift+`\`) | split right |
| `-` | split down |
| `h` / `j` / `k` / `l` | move focus left / down / up / right |
| `z` | toggle zoom (current split full-screen) |
| `=` | equalize all splits |
| `x` | close current split |

### Misc

| Keys | Action |
|---|---|
| `r` | reload `~/.config/ghostty/config` |
| `[` | scroll to top of scrollback |

### Global / Ghostty defaults (no prefix)

| Keys | Action |
|---|---|
| `⌘ + \`` | toggle quick-terminal drop-down (global — works from other apps) |
| `⌘ + c` / `⌘ + v` | copy / paste (default) |
| `⌘ + +` / `⌘ + -` / `⌘ + 0` | font size up / down / reset (default) |
| mouse drag | select + auto-copy to clipboard (`copy-on-select = clipboard`) |

## Feature deep-dives

### Quick-terminal (`⌘ + \``)

Global drop-down from the top of the screen with mouse-follow (whichever monitor has the cursor). Hits anywhere, auto-hides on focus loss. Meant for throwaway commands: `curl ifconfig.me`, quick `grep`, `calc` via `python -c`. Settings:

- `quick-terminal-position = top` — slides from top edge
- `quick-terminal-screen = mouse` — uses the display the cursor is on
- `quick-terminal-autohide = true` — disappears when you click elsewhere
- `quick-terminal-animation-duration = 0.15` — snappy, not sluggish

### `window-save-state = always`

On quit, Ghostty serializes current tab/split layout + cwd + shell history position. On relaunch, everything restores. Great when the Mac sleeps/reboots — long `cargo build`s or `claude-code` sessions resume in place.

### Shell integration (`shell-integration = detect`)

Ghostty auto-injects a preamble when it detects zsh/bash/fish. Unlocks:
- **Cwd reporting**: new splits / tabs inherit the current directory.
- **Prompt-hook marks**: jump to start of prompts with `jump_to_prompt` (not currently bound; add `keybind = ctrl+s>u=jump_to_prompt_previous` if wanted).
- **Exit status awareness**: enables future features like "color cursor by last exit code".

### Clipboard paste protection

`clipboard-paste-protection = true` means pasting text that looks dangerous (contains newlines or control chars) pops a confirmation. Stops the classic `curl example.com/install.sh | sudo bash`-from-paste accident. `clipboard-paste-bracketed-safe = true` disables bracketed paste for shells/apps that don't advertise support — prevents garbled input when you paste into something primitive.

### Transparent titlebar + blur

`macos-titlebar-style = transparent` + `background-opacity = 0.8` + `background-blur-radius = 20` → content sits on a frosted-glass layer. Your wallpaper stays as a soft anchor, the window stops being a big opaque slab. If you feel transparency hurts contrast, bump `background-opacity = 0.9` (closer to opaque).

## Change a setting

1. Edit `~/.config/ghostty/config` (or `dot_config/ghostty/config` in this repo and `chezmoi apply`).
2. In an open Ghostty: `Ctrl+s r`. No restart.
3. If the change is invalid, Ghostty prints an error in a banner but keeps the previous value — nothing breaks silently.
4. To verify from CLI without launching Ghostty: `ghostty +validate-config --config-file=~/.config/ghostty/config`.

## Add a keybind

Ghostty chord syntax: `keybind = ctrl+s>KEY=ACTION[:ARG]`. Examples:

```
# Ctrl+s then w → write scrollback to a file
keybind = ctrl+s>w=write_scrollback_file

# Ctrl+s then b → previous prompt (shell-integration hook)
keybind = ctrl+s>b=jump_to_prompt:-1

# Global (works from any app): Cmd+option+space → quick-terminal
keybind = global:cmd+opt+space=toggle_quick_terminal
```

List all actions: `ghostty +list-actions`. List themes: `ghostty +list-themes`. List fonts: `ghostty +list-fonts`.

**Avoid bare `ctrl+hjkl`** — Karabiner on this machine intercepts them before Ghostty sees them. Put them behind the chord prefix.

## Health check

### Automated
```bash
bash tests/ghostty.sh
```
Exits 0 iff every item below is green: `ghostty` on PATH, config parses, chord prefix wired to hjkl + c + x + r, no stray bare `ctrl+hjkl`, Maple font + Mocha theme discoverable by Ghostty. ~1 second.

### Manual (needs a real Ghostty window — visual fidelity)
- [ ] **Theme**: colors match `bat test.md` output. Background is Mocha's `base` (#1e1e2e), not plain black.
- [ ] **Font**: powerline triangles in starship prompt render without gaps. CJK text (`echo 你好`) aligns to cell boundary, not half-width-squished.
- [ ] **Transparency + blur**: wallpaper visible through window, slightly frosted (not sharp).
- [ ] **Titlebar**: no visible chrome strip at top — titlebar blends into background.
- [ ] **Quick-terminal**: `⌘ + \`` from any app drops a slim terminal from the top; `⌘ + \`` again or click-away dismisses it.
- [ ] **Chord prefix**: `Ctrl+s  c` opens a new tab. `Ctrl+s  |` opens a right-split. `Ctrl+s  h/l` jumps between them.
- [ ] **Zoom**: `Ctrl+s  z` makes the focused split fill the tab; `Ctrl+s  z` again restores.
- [ ] **Karabiner coexist**: bare `Ctrl+h` inside any split moves cursor one char left (arrow key behavior), not deletes-word. If it deletes, Karabiner's rule is off — check `~/.config/karabiner/`.
- [ ] **Reload**: edit config (change `font-size = 13`), `Ctrl+s  r`, font resizes without reopening.
- [ ] **Quit + restart**: open two tabs with a split each, `⌘ + q`, relaunch → layout restored.
- [ ] **Image preview** (via yazi): `y` → pick a `.png` or `.jpg` → preview pane renders the actual image, not a text placeholder.

## Troubleshooting

**Chord doesn't fire (pressing `Ctrl+s` then a key does nothing)**
- Timeout: Ghostty drops the prefix ~1s after `Ctrl+s`. Press the second key faster.
- Another app grabbed `Ctrl+s`: check System Settings → Keyboard → Shortcuts, or Karabiner rules.
- Config typo: run `ghostty +validate-config --config-file=~/.config/ghostty/config`; fix any reported line.

**`Ctrl+s` freezes my shell output**
- Shouldn't happen — Ghostty intercepts the keybind before the PTY. If it does, the config isn't applying. Reload with `Ctrl+s  r` or restart Ghostty.
- If you added a pass-through (`ctrl+s>ctrl+s=text:\x13`), that sends literal XOFF. Run `stty -ixon` in the affected shell to disable flow control, or remove the pass-through.

**Font looks blurry / has gaps**
- `ghostty +list-fonts | grep "^Maple Mono NF CN$"` — if empty, the cask hasn't installed the font. Run `chezmoi apply` (triggers `brew bundle`) or `brew install --cask font-maple-mono-nf-cn`.
- If font is listed but Ghostty renders it wrong: `atsutil databases -remove` (purges macOS font cache), relaunch Ghostty.

**Quick-terminal doesn't drop from global hotkey**
- System Settings → Privacy & Security → Accessibility → Ghostty must be allowed (grants global hotkey capture).
- Another app binds `⌘ + \``: change `keybind = global:cmd+grave_accent=...` in config.

**Image preview in yazi shows placeholder instead of image**
- Verify `TERM`: `echo $TERM` should print `xterm-ghostty`. If `xterm-256color` (our forced value), yazi still sniffs `TERM_PROGRAM=ghostty` and uses Kitty protocol. Check `echo $TERM_PROGRAM`.
- If running through `ssh` / `tmux`, neither layer passes through the Kitty graphics protocol without extra config. Use Ghostty directly for image preview.

**Chezmoi apply doesn't update live Ghostty**
- Ghostty watches the config file: changes apply on next launch OR on `Ctrl+s  r`. `chezmoi apply` writes the file; Ghostty only re-reads it when you reload.

## Gotchas

- **No `tmux` here** — if you muscle-memory `Ctrl+b c` for a new window, it won't do anything. Prefix is `Ctrl+s`.
- **`Ctrl+s` prefix conflicts with literal XOFF only if you bypass Ghostty** — happens inside `ssh` to a server (the server sees `Ctrl+s` pre-PTY freeze), NOT in local Ghostty splits. On remote sessions, either run `stty -ixon` on login, or use `Cmd+s`-shaped bindings for remote work.
- **Tab numbers `1..9` reach tabs 1-9 only** — no `0` for tab 10. If you end up with ≥10 tabs, use `Ctrl+s  n/p` to walk.
- **Equalize splits (`Ctrl+s  =`) balances the tree, not the visible pane** — in a nested split tree, `=` resets all sizes to even, not just the current level.
- **`copy-on-select = clipboard` overwrites the pasteboard on every mouse drag** — no separate "selection" buffer on macOS, so if you drag-select to re-read something, you lose whatever was previously copied. Use `Cmd+c` intentionally if the current clipboard matters.

## Rebuild from scratch

Fresh Mac or fresh `~/.config`:

```bash
# 1. Install via cask (brew bundle covers it via Brewfile)
brew install --cask ghostty font-maple-mono-nf-cn

# 2. Drop the config into place
chezmoi apply   # writes ~/.config/ghostty/config from dot_config/ghostty/config

# 3. Launch Ghostty once so macOS registers it
open -a Ghostty

# 4. First-time accessibility permission (for global quick-terminal hotkey)
#    System Settings → Privacy & Security → Accessibility → enable Ghostty

# 5. Validate
bash tests/ghostty.sh
```

If `tests/ghostty.sh` passes, walk the Manual checklist above to confirm visual fidelity — the automated tests can't see color/blur/transparency.
