<h1 align="center">dotfiles</h1>

<p align="center">
  <em>Personal macOS setup managed with <a href="https://www.chezmoi.io">chezmoi</a> + <a href="https://github.com/FiloSottile/age">age</a>.</em>
</p>

<p align="center">
  <a href="LICENSE"><img alt="license" src="https://img.shields.io/github/license/kyriekevin/dotfiles?style=flat-square"></a>
  <a href="https://www.chezmoi.io"><img alt="managed by chezmoi" src="https://img.shields.io/badge/managed%20by-chezmoi-5fafd7?style=flat-square&logo=homeassistantcommunitystore&logoColor=white"></a>
  <a href="https://www.conventionalcommits.org"><img alt="conventional commits" src="https://img.shields.io/badge/commits-conventional-fe5196?style=flat-square&logo=conventionalcommits&logoColor=white"></a>
  <a href="https://github.com/pre-commit/pre-commit"><img alt="pre-commit" src="https://img.shields.io/badge/pre--commit-enabled-brightgreen?style=flat-square&logo=pre-commit&logoColor=white"></a>
</p>

---

## ✨ Quickstart

On a fresh Mac:

```bash
# 1. Install Homebrew                https://brew.sh

# 2. Drop your age private key       (transferred from an existing Mac)
mkdir -p ~/.config/chezmoi && chmod 700 ~/.config/chezmoi
cp /path/to/key.txt ~/.config/chezmoi/key.txt && chmod 600 ~/.config/chezmoi/key.txt

# 3. Bootstrap
sh -c "$(curl -fsSL https://raw.githubusercontent.com/kyriekevin/dotfiles/main/bootstrap.sh)"
```

On first run, `chezmoi init` prompts for:

| Variable    | Purpose                                             |
| ----------- | --------------------------------------------------- |
| `git_email` | primary email for `~/.gitconfig` on this machine    |
| `is_work`   | `true` on the work Mac, `false` on the personal one |

## 🧰 Toolchain

`bootstrap.sh` handles the user-facing stack — listed here for transparency:

| Tool | Role | How it gets on the machine |
| --- | --- | --- |
| [Homebrew](https://brew.sh) | macOS package manager | `bootstrap.sh` installs it non-interactively if missing |
| [chezmoi](https://www.chezmoi.io) | dotfiles manager | `brew install chezmoi` (inside bootstrap) |
| [age](https://github.com/FiloSottile/age) | secret encryption | `brew install age` (inside bootstrap) |

Contributor-only tools (needed to **edit** the repo, not to use it):

| Tool | Role | Install |
| --- | --- | --- |
| [uv](https://github.com/astral-sh/uv) | Python tool runner | `brew install uv` · or `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| [pre-commit](https://pre-commit.com) | Git hooks (whitespace / secrets / conventional-commits) | `uv tool install pre-commit` — full setup in [CONTRIBUTING.md](CONTRIBUTING.md) |

## 🗂 Layout

```text
~/.dotfiles/
├── dot_*                         → ~/.*            (real dotfiles)
├── private_* / encrypted_*       → chmod 0600, age-decrypted on apply
├── *.tmpl                        → Go-rendered with chezmoi data
├── run_once_before_* /           → apply-time hooks
│   run_onchange_after_*
├── Brewfile                      → brew bundle (triggered by a hook)
└── bootstrap.sh                  → new-Mac entrypoint
```

> [!NOTE]
> This repo lives at `~/.dotfiles` (not chezmoi's default `~/.local/share/chezmoi`). Every `chezmoi` command needs `--source=$HOME/.dotfiles`, or set `sourceDir = "~/.dotfiles"` in `~/.config/chezmoi/chezmoi.toml`.

## 🔐 Secrets

Secrets are committed **encrypted** using [age](https://github.com/FiloSottile/age). Files with the `encrypted_` prefix are transparently decrypted on `chezmoi apply`, using the age identity at `~/.config/chezmoi/key.txt` (chmod 600, never committed — enforced by `.gitignore` + `gitleaks`).

Edit an encrypted secret without manual steps:

```bash
chezmoi edit ~/.config/zsh/secrets.zsh
```

## 🧪 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for commit/branch conventions and pre-commit setup.

## 🔗 Related

- [nousresearch/hermes-agent](https://github.com/nousresearch/hermes-agent) — open-source agent framework
- _(future)_ self-authored Claude Code agents / skills — extracted to standalone repos

## 📄 License

MIT — see [LICENSE](LICENSE).
