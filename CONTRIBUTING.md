# Contributing

This repo is a personal dotfiles scaffold, but it's intentionally reusable by teammates. These conventions keep the history readable and review cheap.

## Branches

- `main` — always deployable; never commit directly
- `feat/<name>` — new package or feature (e.g. `feat/zsh`, `feat/nvim`)
- `fix/<name>` — bug fix
- `chore/<name>` — meta work (CI, hooks, infrastructure, README polish)
- `docs/<name>` — docs-only changes

## Commits

Follow [Conventional Commits](https://www.conventionalcommits.org):

```
<type>(<scope>?): <subject>
```

- **type**: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `ci`, `build`, `style`
- **scope** (optional): package name — `feat(zsh): …`, `fix(karabiner): …`
- **subject**: imperative mood, lowercase start, no trailing period

Body and footer are optional. Breaking changes go in the footer as `BREAKING CHANGE: ...`.

Commit messages are validated by the `commit-msg` pre-commit hook — non-conforming messages are rejected locally.

## Pull requests

1. Open a PR against `main` from your `feat/<name>` branch
2. Wait for pre-commit checks to pass
3. Merge via the **GitHub web UI** — Squash for small PRs, Rebase for well-structured multi-commit PRs

## Pre-commit hooks

One-time setup after cloning:

```bash
brew install pre-commit             # if not already installed
pre-commit install                  # register pre-commit hook
pre-commit install --hook-type commit-msg   # register commit-msg hook
```

Run the full suite manually at any time:

```bash
pre-commit run --all-files
```

Current hooks:

| Hook | What it does |
|---|---|
| `trailing-whitespace`, `end-of-file-fixer`, `mixed-line-ending` | whitespace hygiene |
| `check-added-large-files` | blocks accidental large binaries |
| `check-json` / `check-toml` / `check-yaml` | syntax gates |
| [`gitleaks`](https://github.com/gitleaks/gitleaks) | scans for committed secrets (age keys, tokens) |
| [`conventional-pre-commit`](https://github.com/compilerla/conventional-pre-commit) | enforces Conventional Commits (commit-msg stage) |

## Secrets

Never commit plaintext secrets. The age identity at `~/.config/chezmoi/key.txt` and any unencrypted `secrets.zsh` are blocked by `.gitignore`, and `gitleaks` catches accidental commits.

Add a new encrypted secret:

```bash
chezmoi add --encrypt ~/.config/zsh/secrets.zsh
```

Edit it later (transparent decrypt/re-encrypt via `$EDITOR`):

```bash
chezmoi edit ~/.config/zsh/secrets.zsh
```
