# Agent Workflows

> English · [中文](agent-workflows.zh.md)

This branch splits Claude Code / Codex multi-session work into two active layers. The conclusion is explicit: **cmux is the primary terminal surface**. Standalone Ghostty is no longer installed; `~/.config/ghostty/config` stays only because cmux/libghostty reads it for rendering/keybind defaults. tmux is only a fallback.

cmux matches the actual problem: it is a Ghostty/libghostty-based native macOS terminal that adds vertical tabs, workspace metadata, browser panes, and a CLI. It addresses the control-plane question: "which agent session needs me now?"

## Try Order

### A. cmux

Use this once you have several projects and several Claude/Codex sessions running, and the main issue is seeing which session is waiting.

Install:

```bash
brew tap manaflow-ai/cmux
brew install --cask cmux
```

This branch also declares it in Brewfile:

```bash
brew bundle --file ~/.dotfiles/Brewfile
```

cmux config is dotfiles-managed: source `dot_config/cmux/cmux.json`, target `~/.config/cmux/cmux.json`. The Ghostty-compatible terminal config is also dotfiles-managed at `dot_config/ghostty/config` because cmux/libghostty reads it. The current cmux config makes the left sidebar quieter: match the terminal background, remove tint, and hide port/PR/log noise.

```bash
chezmoi --source=/Users/zyz/.dotfiles apply ~/.config/cmux/cmux.json ~/.config/ghostty/config
cmux reload-config
```

Entrypoints:

```bash
cmux
cmux claude-teams
cmux codex-teams
```

zsh alias:

```bash
cm
```

cmux shortcuts use the same `Ctrl+s` chord shape:

| Key | Action |
|---|---|
| `Ctrl+s b` | Toggle the left workspace sidebar |
| `Ctrl+s w` | Open workspace switcher |
| `Ctrl+s n/p` | Next / previous workspace |
| `Ctrl+s ;` | New workspace |
| `Ctrl+s c` | New surface/tab in the current pane |
| `Ctrl+s \|` / `Ctrl+s -` | Split right / down |
| `Ctrl+s h/j/k/l` | Move between panes |
| `Ctrl+s m` | Zoom current pane |
| `Ctrl+s =` | Equalize panes |
| `Ctrl+s x` | Close current surface/tab |

cmux calls the New Workspace shortcut `newTab` in config; actual pane tabs/surfaces are `newSurface`. This branch binds both explicitly so `Ctrl+s ;` means workspace and `Ctrl+s c` means tab/surface.

Why this is preferred over Claude Squad / tmux:

- No tmux required; sessions, splits, and tabs are native cmux surfaces.
- Reads the Ghostty-compatible config, so existing font/theme/color/keybind choices carry over without installing Ghostty.app.
- Sidebar shows git branch, PR status, cwd, ports, and workspace state in one place.
- Built-in browser pane and scriptable API fit local web app debugging.
- It remains a terminal primitive rather than an opinionated agent orchestrator.

### B. tmux Fallback

Use this for remote/TTY cases, instability in cmux, or when you need a low-level dashboard.

```bash
chezmoi --source=/Users/zyz/.dotfiles apply ~/.tmux.conf ~/.config/zsh/aliases.zsh ~/.config/zsh/tools.zsh
```

Commands:

| Command | Action |
|---|---|
| `am` | Attach/create a tmux session for the current directory |
| `am name` | Attach/create a named session |
| `ad` | Create an agent desk with `shell`, `claude`, and `codex` windows |
| `ad name` | Use a named agent desk |

tmux uses `Ctrl+a`, not `Ctrl+s`, so it does not collide with the cmux/libghostty `Ctrl+s` chord layer.

## Decision Table

| Option | Good For | Not Good For |
|---|---|---|
| cmux | Many projects/agents, context sidebar, native terminal panes | Avoiding a new GUI app |
| tmux `am` / `ad` | Remote/TTY/fallback dashboard | Avoiding tmux prefixes; wanting the native cmux UI |

Recommendation: primarily try cmux. Do not make tmux the main path unless cmux does not fit your day-to-day work.

## Health Check

```bash
bash tests/ghostty.sh
bash tests/cmux.sh
bash tests/tmux.sh
bash tests/yazi.sh
```

`tests/cmux.sh` fails until cmux is installed. `tests/ghostty.sh` validates the Ghostty-compatible config but no longer requires Ghostty.app. `tests/tmux.sh` expects `chezmoi apply ~/.tmux.conf` to have run. `tests/yazi.sh` catches terminal-file-manager config parse errors that show up immediately when launching `y`.

## Rollback

If cmux does not stick, stop opening it. To roll config back after checking out `main`:

```bash
chezmoi --source=/Users/zyz/.dotfiles apply ~/.config/ghostty/config ~/.claude/settings.json ~/.config/zsh/aliases.zsh ~/.config/zsh/tools.zsh ~/.config/cmux/cmux.json
rm -f ~/.tmux.conf
```
