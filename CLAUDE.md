# Repo conventions for Claude Code

Personal macOS dotfiles managed with [chezmoi](https://www.chezmoi.io) + [age](https://github.com/FiloSottile/age). Source dir is `~/.dotfiles` (non-default — all chezmoi commands need `--source=$HOME/.dotfiles` unless `sourceDir` is set in `~/.config/chezmoi/chezmoi.toml`).

## Git workflow

- **Commits follow [Conventional Commits](https://www.conventionalcommits.org)**: `<type>(<scope>?): <subject>`
  - Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `ci`, `build`, `style`
  - Scope is optional — use it for package names (e.g., `feat(zsh): ...`, `fix(karabiner): ...`)
- **Branch-per-feature**: each package / phase in its own `feat/<name>` branch; `chore/<name>` for meta work
- **No auto-push**: show the user the pending commits and wait for approval before `git push`
- **Merges happen on the GitHub web UI** — do **not** run `gh pr merge` yourself. `gh pr create` to open the PR is fine.

## chezmoi source conventions

| Pattern | Effect |
|---|---|
| `dot_X` | apply target renamed to `.X` |
| `private_X` | chmod 0600 / 0700 |
| `encrypted_X` | age-decrypted on apply (identity at `~/.config/chezmoi/key.txt`) |
| `executable_X` | chmod +x |
| `X.tmpl` | rendered as Go template using `[data]` from `chezmoi.toml` |
| `run_once_before_*` | one-shot hook before files are written (e.g., install Homebrew) |
| `run_onchange_after_*` | re-runs when the file's rendered content changes (e.g., `brew bundle`) |

Prefixes can stack: `encrypted_private_dot_secrets.zsh.age` → `~/.secrets.zsh`, chmod 600, decrypted.

## Secrets

- age identity at `~/.config/chezmoi/key.txt` (chmod 600, **never committed** — enforced by `.gitignore`)
- Encrypted source files use the `encrypted_` prefix + `.age` extension
- Edit via `chezmoi edit <target-path>` (transparent decrypt / re-encrypt)

## Incremental build history

This repo was rebuilt from scratch using an incremental phased plan — see `~/.claude/plans/0-1-dotfiles-stow-dotfiles-bk-jolly-boole.md`. New packages should follow the same pattern: one branch, one package, user-reviewed PR, web-UI merge.
