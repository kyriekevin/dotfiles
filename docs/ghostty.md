# Ghostty

> English · [中文](ghostty.zh.md)

Ghostty is the primary terminal app in this repo. It owns rendering, font, theme, Kitty graphics for Yazi, the quick terminal, and ordinary shell tabs/splits. Herdr runs inside Ghostty when agent-aware workspaces are needed.

## How It Works

| Thing | Where | Note |
|---|---|---|
| Config | `~/.config/ghostty/config` ← source `dot_config/ghostty/config` | Single `key = value` file. Reload with `Ctrl+s r` or restart Ghostty. |
| App | `/Applications/Ghostty.app` | Installed via `cask "ghostty"` in Brewfile. |
| Font | `Maple Mono NF CN` | Nerd Font glyphs plus CJK coverage. |
| Theme | `Catppuccin Mocha` | Built into Ghostty. |
| Agent multiplexer | `herdr` inside a Ghostty pane | See [Agent Workflows](agent-workflows.md). |

## Keymap

Ghostty keeps the existing `Ctrl+s` chord for terminal-native tabs and splits. Herdr keeps its own default `Ctrl+b` prefix inside the pane.

| Key | Action |
|---|---|
| `Ctrl+s c` | New Ghostty tab |
| `Ctrl+s n/p` | Next / previous Ghostty tab |
| `Ctrl+s \|` | Split right |
| `Ctrl+s -` | Split down |
| `Ctrl+s h/j/k/l` | Move between Ghostty splits |
| `Ctrl+s m` | Zoom current split |
| `Ctrl+s =` | Equalize splits |
| `Ctrl+s x` | Close current surface |
| `Ctrl+s r` | Reload Ghostty config |
| `Cmd+\`` | Toggle quick terminal |

## Why Keep Ghostty

- Yazi image previews use Ghostty's Kitty graphics support directly.
- Native tabs/splits remain available when Herdr is overkill.
- Herdr can run inside it without replacing the terminal app.
- The visual stack stays consistent with Catppuccin Mocha and Maple Mono NF CN.

## Health Check

### Automated

```bash
bash tests/ghostty.sh
```

Checks Brewfile intent, Ghostty app presence, config fields, keybind guards, and optional CLI validation when a `ghostty` executable is available.

### Manual

- [ ] Open Ghostty from Spotlight.
- [ ] `Ctrl+s c` opens a tab.
- [ ] `Ctrl+s |` and `Ctrl+s -` split panes.
- [ ] `Ctrl+s h/j/k/l` moves between splits.
- [ ] `Ctrl+s m` zooms and unzooms the focused split.
- [ ] Run `y` and preview a PNG/JPG; the preview should render as an image, not ASCII or blank text.
- [ ] Run `herdr` inside a pane; Herdr should take over that pane only.

## Troubleshooting

**Ghostty app missing** — run `brew install --cask ghostty` or `brew bundle --file ~/.dotfiles/Brewfile`.

**Image preview in Yazi is blank** — check `echo $TERM_PROGRAM`; in Ghostty it should be `ghostty`. If running through tmux/screen/SSH without graphics passthrough, Yazi can silently fall back to no image.

**`Ctrl+s` freezes output** — Ghostty should intercept this chord before the PTY. If it freezes, the config is not loaded; restart Ghostty or reload with `Ctrl+s r`.

**Herdr eats keys** — Herdr uses `Ctrl+b` as its own prefix inside the pane. Use `Ctrl+s` for Ghostty-level actions and `Ctrl+b` for Herdr-level actions.
