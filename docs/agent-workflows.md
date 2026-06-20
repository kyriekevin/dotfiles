# Agent Workflows

> English · [中文](agent-workflows.zh.md)

This branch makes **Ghostty + herdr** the agent workflow. Ghostty is the terminal surface: font, theme, Kitty image protocol, native quick terminal, and ordinary shell tabs/splits. Herdr runs inside Ghostty as the agent multiplexer: workspaces, tabs, panes, detach/reattach, and Claude/Codex state awareness.

This keeps the layers separate. We do not adopt cmux as another terminal app, and we do not keep a tmux dashboard by default.

## Try Order

### A. Ghostty + herdr

Use this for multi-project Claude/Codex work where you need to see which agent is idle, working, done, or blocked without leaving your terminal.

Install:

```bash
brew install --cask ghostty
brew install herdr
```

This branch also declares both in Brewfile:

```bash
brew bundle --file ~/.dotfiles/Brewfile
```

Dotfiles-managed config:

| Tool | Source | Target |
|---|---|---|
| Ghostty | `dot_config/ghostty/config` | `~/.config/ghostty/config` |
| herdr | `dot_config/herdr/config.toml` | `~/.config/herdr/config.toml` |

Apply:

```bash
chezmoi --source=/Users/zyz/.dotfiles apply ~/.config/ghostty/config ~/.config/herdr/config.toml ~/.config/zsh/aliases.zsh
```

Entrypoints:

```bash
ghostty
herdr
hd    # alias for herdr
```

Herdr keeps its default tmux-like prefix: `Ctrl+b`. No `Ctrl+s` remapping.

| Key | Action |
|---|---|
| `Ctrl+b w` | Workspace picker |
| `Ctrl+b g` | Go to session/workspace navigator |
| `Ctrl+b Shift+n` | New workspace |
| `Ctrl+b c` | New tab |
| `Ctrl+b n/p` | Next / previous tab |
| `Ctrl+b v` / `Ctrl+b -` | Split pane |
| `Ctrl+b h/j/k/l` | Move between panes |
| `Ctrl+b z` | Zoom current pane |
| `Ctrl+b x` | Close pane |
| `Ctrl+b q` | Detach; pane processes keep running |

Why this is preferred over cmux here:

- Ghostty stays the only terminal app.
- Herdr lives inside the terminal instead of wrapping it in a separate GUI surface.
- Panes are real terminal processes, so copy, shell behavior, and Yazi image preview remain terminal-native.
- Herdr has built-in agent awareness for Claude Code and Codex through process/output detection and optional integrations.
- Detach/reattach gives the persistence that a busy agent desk needs without adding tmux config to this repo.
- Notifications stay off in our config: `ui.toast.delivery = "off"`.

### B. Ghostty Native Tabs/Splits

If you do not need agent state, use Ghostty directly. Its `Ctrl+s` chord is still available for ordinary tabs and splits:

| Key | Action |
|---|---|
| `Ctrl+s c` | New Ghostty tab |
| `Ctrl+s \|` / `Ctrl+s -` | Split right / down |
| `Ctrl+s h/j/k/l` | Move between Ghostty splits |
| `Ctrl+s m` | Zoom current split |
| `Ctrl+s x` | Close current surface |

## Decision Table

| Option | Good For | Not Good For |
|---|---|---|
| Ghostty + herdr | Many projects/agents, in-terminal workspace dashboard, detach/reattach | Avoiding another terminal-mode layer |
| Ghostty only | Single project or light multitasking | Seeing agent blocked/done state across many panes |

Recommendation: use Ghostty + herdr as the default for agent-heavy work. Drop to plain Ghostty when you just need a terminal.

## Health Check

```bash
bash tests/ghostty.sh
bash tests/herdr.sh
bash tests/yazi.sh
```

`tests/ghostty.sh` validates the Ghostty config and requires Ghostty.app to be installed. `tests/herdr.sh` validates Brewfile intent, Herdr config, docs, and the installed CLI. `tests/yazi.sh` catches terminal-file-manager config parse errors and preview backend drift.

Manual checks:

- [ ] Open Ghostty and run `herdr`.
- [ ] `Ctrl+b v` and `Ctrl+b -` split panes.
- [ ] `Ctrl+b Shift+n` creates a workspace.
- [ ] Start `claude` in one pane and `codex` in another; the Herdr sidebar shows agent state.
- [ ] `Ctrl+b q` detaches; running `herdr` again reattaches to the same server.
- [ ] Run `y` in a Ghostty pane; image preview uses Ghostty's Kitty protocol.

## Rollback

If Herdr does not stick, stop opening it. To roll config back after checking out `main`:

```bash
chezmoi --source=/Users/zyz/.dotfiles apply ~/.config/ghostty/config ~/.config/zsh/aliases.zsh
rm -f ~/.config/herdr/config.toml
```
