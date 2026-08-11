# Contributing

> English · [中文](CONTRIBUTING.zh.md)

This file defines the Git and pull-request contract. For source files, apply behavior, package
checks, and rollback, use the [maintenance workflow](docs/maintenance.md).

## One-time setup

```bash
brew install chezmoi gitleaks uv
uv tool install pre-commit
pre-commit install
```

The repository config installs both `pre-commit` and `commit-msg` hooks. Run the full hand-off gate
at any time with `make verify`.

## Branches

`main` is protected and must remain deployable. Create a focused typed branch:

| Prefix | Use |
|---|---|
| `feat/<name>` | New package or behavior |
| `fix/<name>` | Bug fix |
| `docs/<name>` | Documentation only |
| `chore/<name>` | CI, hooks, dependencies, or repository maintenance |

Do not commit or push directly to `main`.

## Commits and PR titles

Use [Conventional Commits](https://www.conventionalcommits.org):

```text
<type>(<scope>?): <subject>
```

Allowed types are `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `ci`, `build`, and
`style`. Prefer a package scope such as `zsh`, `nvim`, `karabiner`, `maintenance`, or `automation`.
Use an imperative, lowercase subject without a trailing period.

Local hooks validate commits; the `checks` job validates the PR title because squash merge uses it
as the final commit subject.

## Before opening a PR

```bash
make verify
chezmoi --source="$PWD" diff
make health PACKAGE=<name>   # after applying the affected package on a real Mac
```

Also complete the package guide's manual GUI or TTY checklist when relevant. Keep English and
Chinese user-facing docs semantically aligned.

## Pull-request flow

1. Open a PR from the typed branch to `main` and complete the PR template.
2. Wait for the required `checks` job and resolve review conversations.
3. Use **Squash merge** by default. Use rebase only when preserving separate authors or independent
   commits materially improves the history.
4. After merge, update local `main`; delete the feature branch only after verifying the squash tree.

Branch protection requires an up-to-date successful `checks` run and applies to administrators.
Force-pushes and branch deletion are disabled on `main`.

## Issues and labels

Use the bug or feature-request template. Blank issues are disabled. Every PR should have at least
one type label matching its primary Conventional Commit type; `build` and `style` map to `chore`.

## Secrets

Never commit plaintext credentials or an age identity. Gitleaks and ignore rules are safety nets,
not substitutes for review. Follow the [secrets runbook](docs/secrets.md) for additions and rotation.
