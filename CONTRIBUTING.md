# Contributing

> English · [中文](CONTRIBUTING.zh.md)

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

## Labels

PRs and issues share one taxonomy that mirrors the Conventional Commit types:

| Label | Use for |
|---|---|
| `feat` | new feature or capability |
| `fix` | bug fix |
| `chore` | tooling, deps, infrastructure |
| `docs` | documentation only |
| `refactor` | code change with no behavior change |
| `test` | test additions or fixes |
| `perf` | performance improvement |
| `ci` | CI configuration |

Every PR must carry **at least one** type label. Multi-type PRs can stack labels (e.g. `feat,docs`). `build` / `style` commits map to `chore`.

Issue templates pre-fill the right label — `bug_report.yml` → `fix`, `feature_request.yml` → `feat` — so nothing needs a manual hand-off.

## Pull requests

1. Open a PR against `main` from your `feat/<name>` branch — the [PR template](.github/pull_request_template.md) gives you the checklist
2. Merge via the **GitHub web UI**. **Default is Squash** — phase PRs typically ship 3–5 atomic commits whose granularity was only useful during review, and squashing keeps `main`'s log scannable. Use **Rebase** only when commits come from multiple authors, or when one PR genuinely spans multiple independent features whose history should be preserved

## Issues

Use the provided templates:

- **Bug**: something in a config (zsh / nvim / karabiner / ...) is misbehaving
- **Feature request**: new tool, new config, new automation

Blank issues are disabled — templates keep the triage fast.

## Pre-commit hooks

### Install pre-commit (one-time, global)

Preferred path — via [uv](https://github.com/astral-sh/uv) (consistent with the rest of the Python toolchain):

```bash
# Install uv itself if you don't have it
brew install uv
# …or the official installer (no Homebrew needed)
# curl -LsSf https://astral.sh/uv/install.sh | sh

# Install pre-commit as an isolated global tool
uv tool install pre-commit
```

Alternatives if you don't use uv:

```bash
brew install pre-commit     # Homebrew-managed
# …or
pipx install pre-commit     # classic pipx
```

### Register hooks for this repo (one-time per clone)

```bash
cd ~/.dotfiles
pre-commit install
```

That single command registers both the `pre-commit` and `commit-msg` hooks (the config sets `default_install_hook_types: [pre-commit, commit-msg]`).

### Run the suite manually

```bash
pre-commit run --all-files
```

### Bump hook versions

```bash
pre-commit autoupdate
```

### Current hooks

| Hook | Purpose |
|---|---|
| `trailing-whitespace`, `end-of-file-fixer`, `mixed-line-ending` | whitespace hygiene |
| `check-added-large-files` | blocks accidental large binaries |
| `check-json` / `check-toml` / `check-yaml` | syntax gates |
| `check-merge-conflict` | catches stray conflict markers |
| [`gitleaks`](https://github.com/gitleaks/gitleaks) | scans for committed secrets (age keys, tokens) |
| [`conventional-pre-commit`](https://github.com/compilerla/conventional-pre-commit) | enforces Conventional Commits (commit-msg stage) |

## Secrets

Never commit plaintext secrets — `.gitignore` + `gitleaks` enforce this. For the add/edit/rotate workflow and common gotchas, see [docs/secrets.md](docs/secrets.md).
