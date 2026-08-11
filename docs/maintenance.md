# Maintenance and change workflow

> English · [中文](maintenance.zh.md)

This guide explains how to change the repository safely. Installation and everyday use belong in
the root README; package behavior and manual verification belong in `docs/<package>.md`.

## Two verification layers

| Layer | Entry point | What it checks | Used by CI |
|---|---|---|---|
| Source verify | `make verify` | Versioned source, templates, formatting, links, and repository invariants | Yes |
| Live health | `make health PACKAGE=<name>` | The applied HOME, installed CLIs, caches, and runtime behavior | No; run on a real Mac |

Source verification does not read decrypted secrets, require a GUI, install plugins, or assume that
HOME is configured. Live health checks may inspect target files and start programs, so they can
depend on the network or populate local caches.

## Source and destination files

The repository is the chezmoi source of truth.

| Source | Destination | Notes |
|---|---|---|
| `dot_zshrc` | `~/.zshrc` | `dot_` becomes the leading dot |
| `dot_config/zsh/aliases.zsh` | `~/.config/zsh/aliases.zsh` | Plain configuration |
| `dot_gitconfig.tmpl` | `~/.gitconfig` | Rendered as a Go template first |
| `encrypted_private_*.age` | Plaintext target with mode 0600 | Only age ciphertext is versioned |
| `.chezmoiscripts/run_*` | No direct file target | Runs before or after apply according to its filename |

Edit source directly or use `chezmoi edit <target>`. If you prototype in a destination file, bring
the result back immediately with `chezmoi add <target>` and inspect the diff; do not leave HOME and
the repository diverged.

## Standard change workflow

```sh
git switch main
git pull --ff-only
git switch -c feat/<name>       # or fix/, docs/, chore/

make verify

chezmoi diff
chezmoi apply ~/.config/<package>/...

make health PACKAGE=<package>
```

Then complete the package's manual checklist, inspect `git diff --check` and `git status --short`,
and open a pull request. The PR title must follow Conventional Commits. GitHub's `checks` job runs
the same `make verify` command.

## Change matrix

| Change | Usual source | Required check | After apply |
|---|---|---|---|
| Zsh alias or environment | `dot_config/zsh/*.zsh` | `make verify` | `make health PACKAGE=zsh` |
| Git setting | `dot_gitconfig.tmpl`, `dot_gitignore_global` | `make verify` | `make health PACKAGE=git` |
| Homebrew package | `Brewfile` | `make verify` | `brew bundle check --file=Brewfile` |
| Neovim config or plugin | `dot_config/nvim/` | `make verify` | `make health PACKAGE=nvim` plus UI checklist |
| Karabiner rule | `dot_config/karabiner/` | `make verify` | `make health PACKAGE=karabiner` plus GUI checklist |
| chezmoi hook | `.chezmoiscripts/`, including dependency hashes where needed | `make verify` | Run twice in a recoverable environment to prove idempotency |
| Secret | Age ciphertext and, when needed, ignore or recipient config | `make verify` | Follow `docs/secrets.md`; never print plaintext in a PR |
| User documentation | Matching English and Chinese files | `make verify` | Check semantic alignment and links |

## Adding a package

A new package with runtime behavior normally includes:

1. Chezmoi source configuration.
2. A `Brewfile` declaration when a binary is required.
3. `docs/<package>.md` and `docs/<package>.zh.md`.
4. `tests/<package>.sh` when behavior can be checked reliably; GUI and TTY behavior stays in the
   documentation's manual checklist.
5. An entry in the README tool stack or layout when it is a user-visible component.

Do not create empty tests for symmetry. Document a concrete manual action and expected result when
automation would be unstable.

## Changing chezmoi scripts

The filename defines both execution timing and rerun policy. Follow these rules:

- A `run_onchange_*` script must be safe to run repeatedly.
- If it depends on another source file such as `Brewfile`, embed that file's hash in the template.
- Document whether it uses the network, installs software, or mutates system state; fail nonzero.
- Do not write back into the repository or print machine identity or secrets.
- Review `chezmoi diff`, then apply on a recoverable real Mac.

## CI boundary

`.github/workflows/verify.yml` runs `make verify` for pull requests, pushes to `main`, and manual
dispatches. It does not reconstruct a personal computer: secrets, GUIs, real keybindings, and
long-lived caches remain outside CI. Branch protection requires pull requests and a successful,
up-to-date `checks` job before `main` can advance; the same rules apply to administrators.

## Rollback

- Before apply: fix the source, rerun `make verify`, and inspect `chezmoi diff`.
- After apply: revert the source change, then apply only the affected target again.
- After merge: use a revert pull request; do not rewrite shared history.
- For secrets or age keys, follow `docs/secrets.md` and never delete the only usable identity.
