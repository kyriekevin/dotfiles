<h1 align="center">dotfiles</h1>

<p align="center">
  The machine loadout of the <strong>Nightglass Protocol</strong> —
  a reproducible macOS terminal and development environment, managed with
  <a href="https://www.chezmoi.io">chezmoi</a>, Homebrew, and age.
</p>

<p align="center">
  English · <a href="README_zh-CN.md">简体中文</a>
</p>

<p align="center">
  <a href="https://github.com/kyriekevin/dotfiles/actions/workflows/verify.yml"><img alt="Verify" src="https://github.com/kyriekevin/dotfiles/actions/workflows/verify.yml/badge.svg"></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/github/license/kyriekevin/dotfiles?style=flat-square"></a>
  <a href="https://www.chezmoi.io"><img alt="Managed by chezmoi" src="https://img.shields.io/badge/managed%20by-chezmoi-5fafd7?style=flat-square"></a>
</p>

> [!IMPORTANT]
> This is a personal setup, not a universal starter kit. A fresh install requires the matching age
> identity. Forks must replace the age recipient and encrypted files before bootstrap.

## What it manages

- Reproduces packages and apps from one [`Brewfile`](Brewfile).
- Renders machine-specific Git settings and keeps secrets encrypted in Git.
- Configures the shell, terminal, editor, navigation tools, key mappings, and coding-agent surface.
- Uses the same deterministic `make verify` gate locally and in GitHub Actions.

| Area | Main components | Guide |
|---|---|---|
| Shell and prompt | Zsh, zinit, Starship, Fastfetch | [Zsh](docs/zsh.md) · [Starship](docs/starship.md) · [Fastfetch](docs/fastfetch.md) |
| Terminal workflow | Ghostty, Herdr, Yazi | [Ghostty](docs/ghostty.md) · [Agent workflows](docs/agent-workflows.md) · [Yazi](docs/yazi.md) |
| Editor and Git | Neovim, Git, Lazygit, GitHub CLI | [Neovim](docs/nvim.md) · [Git](docs/git.md) |
| Automation | Karabiner-Elements, Homebrew hooks | [Karabiner](docs/karabiner.md) · [Maintenance](docs/maintenance.md) |
| Coding agents | Claude Code settings, plugins, MCP boundaries | [Claude Code](docs/claude.md) · [Extensions](docs/claude-plugins.md) |

## Set up a Mac

Copy the existing age identity to the new Mac, then run bootstrap:

```bash
mkdir -p ~/.config/chezmoi
chmod 700 ~/.config/chezmoi
cp /path/to/key.txt ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt

sh -c "$(curl -fsSL https://raw.githubusercontent.com/kyriekevin/dotfiles/main/bootstrap.sh)"
```

Bootstrap installs Homebrew when missing, installs the core tools, clones this repository to
`~/.dotfiles`, and runs `chezmoi init --apply`. The first run asks for:

| Value | Meaning |
|---|---|
| `git_email` | Git identity for this Mac |
| `is_work` | Selects work or personal machine settings |

For key transfer, rotation, or a forked setup, follow the [secrets runbook](docs/secrets.md).

## Update an existing Mac

```bash
cd ~/.dotfiles
git pull --ff-only
chezmoi --source="$PWD" diff
chezmoi --source="$PWD" apply
```

Review the diff before apply. A `Brewfile` change automatically triggers `brew bundle`; other
`run_once_*` and `run_onchange_*` hooks reconcile package-specific state.

## How it works

```text
Git source (~/.dotfiles)
├── chezmoi render / decrypt ──→ files in HOME
├── Brewfile change ───────────→ brew bundle
└── apply-time hooks ──────────→ plugins and supporting state
```

This repository intentionally uses `~/.dotfiles` instead of chezmoi's default source directory.
The config template pins that path for fresh installs; the update commands above pass it explicitly
so they also work on older machines initialized before the pin existed.

## Documentation

| I want to… | Start here |
|---|---|
| Change configuration safely | [Maintenance workflow](docs/maintenance.md) |
| Open a branch or pull request | [Contributing](CONTRIBUTING.md) |
| Add, edit, or rotate a secret | [Secrets runbook](docs/secrets.md) |
| Diagnose one tool | The matching guide in the component table above |
| Run applied-machine checks | `make health PACKAGE=zsh` and [live health notes](tests/README.md) |

The short hand-off loop for repository changes is:

```bash
make verify
chezmoi --source="$PWD" diff
make health PACKAGE=zsh   # replace zsh with the affected package
```

## License

MIT — see [LICENSE](LICENSE).
