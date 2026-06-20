# Ghostty

> English · [中文](ghostty.zh.md)

Ghostty is the primary terminal app in this repo. It owns rendering, font, theme, Kitty graphics for Yazi, the quick terminal, and ordinary shell tabs/splits. Herdr runs inside Ghostty when agent-aware workspaces are needed.

## How It Works

| Thing | Where | Note |
|---|---|---|
| Config | `~/.config/ghostty/config` ← source `dot_config/ghostty/config` | Single `key = value` file. Restart Ghostty after edits, or use the app menu. |
| App | `/Applications/Ghostty.app` | Installed via `cask "ghostty"` in Brewfile. |
| Font | `Maple Mono NF CN` | Nerd Font glyphs plus CJK coverage. |
| Theme | `Catppuccin Mocha` | Built into Ghostty. |
| Agent multiplexer | `herdr` inside a Ghostty pane | See [Agent Workflows](agent-workflows.md). |

## Keymap

Ghostty no longer defines a custom `Ctrl+s` multiplexer chord. Use Ghostty's app/default shortcuts for terminal-only work, and use Herdr's `Ctrl+b` prefix when you need agent-aware workspaces.

| Key | Action |
|---|---|
| `Cmd+\`` | Toggle quick terminal |

## Why Keep Ghostty

- Yazi image previews use Ghostty's Kitty graphics support directly.
- Native app/default shortcuts remain available when Herdr is overkill.
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
- [ ] Ghostty default app shortcuts still open tabs and splits.
- [ ] Run `y` and preview a PNG/JPG; the preview should render as an image, not ASCII or blank text.
- [ ] Run `herdr` inside a pane; Herdr should take over that pane only.

## Troubleshooting

**Ghostty app missing** — run `brew install --cask ghostty` or `brew bundle --file ~/.dotfiles/Brewfile`.

**Image preview in Yazi is blank** — check `echo $TERM_PROGRAM`; in Ghostty it should be `ghostty`. If running through tmux/screen/SSH without graphics passthrough, Yazi can silently fall back to no image.

**`Ctrl+s` freezes output** — this repo no longer binds `Ctrl+s` in Ghostty. Press `Ctrl+q` to resume terminal output if a foreground app receives XOFF.

**Herdr eats keys** — Herdr uses `Ctrl+b` as its own prefix inside the pane. Press `Ctrl+b ?` to see Herdr's current keybindings.
