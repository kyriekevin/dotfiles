# Git & companion tools

Minimal global git config + global ignore, plus `lazygit` (TUI) and `gh` (CLI). Identity switches per machine via the `is_work` chezmoi prompt — no `includeIf`, no per-directory rules.

---

## How it works

| Source (repo) | Target (`$HOME`) | Behavior |
|---|---|---|
| `dot_gitconfig.tmpl` | `~/.gitconfig` | Identity switched by `is_work`; shared knobs (delta, rebase, conflict style, …) are the same on every machine |
| `dot_gitignore_global` | `~/.gitignore_global` | Referenced from `core.excludesFile` |
| `dot_config/lazygit/config.yml` | `~/.config/lazygit/config.yml` | Catppuccin Mocha theme + delta pager + nvim edit |
| `dot_config/gh/config.yml` | `~/.config/gh/config.yml` | PR-heavy aliases (`pv`, `pl`, `pc`, `pm`, …) |

chezmoi renders the template on each `chezmoi apply` — no hook scripts needed.

> **Note on lazygit's config path.** macOS lazygit defaults to `~/Library/Application Support/lazygit/`. We set `XDG_CONFIG_HOME="$HOME/.config"` in `dot_zshenv` so lazygit (and every XDG-aware tool) reads `~/.config/` instead — same as Linux. Verify with `lazygit --print-config-dir` (expected: `~/.config/lazygit`).

---

## Why these choices

1. **Identity per machine, not per directory.** Historical plan mentioned `includeIf "gitdir:~/personal/"`; dropped because the user's actual habit is "whichever Mac I'm on, commit as that Mac." Same repo cloned on both machines authors under different identities automatically.
2. **`delta` as pager + `interactive.diffFilter`.** Side-by-side, line numbers, navigate (n/N between hunks) — installed in Phase 2's Brewfile (`git-delta`). When piping to a script, override with `-c core.pager=cat`.
3. **`merge.conflictstyle = zdiff3`.** Shows the common ancestor in conflict markers — dramatically easier three-way merges than default `merge` style. Requires git ≥ 2.35 (Brewfile pulls latest).
4. **`rebase.autoStash = true`.** `git pull --rebase` on a dirty tree auto-stashes instead of erroring. Saves a manual `git stash` / `git stash pop` every time.
5. **No `pull.rebase` pin.** zsh `OMZP::git` plugin provides `gl`/`gp` shortcuts; explicit pull strategy stays a per-repo decision. Git's default (merge) is kept.
6. **Minimal aliases.** `OMZP::git` already ships `gst` / `gco` / `gcb` / … Only `lg` (pretty graph log) stays in `~/.gitconfig` because it's longer than an alias can cleanly be.
7. **`credential.helper = osxkeychain`.** macOS Keychain for HTTPS credentials. For GitHub specifically, `gh auth login` installs its own credential helper in front of this — both work.

---

## Identity per machine

| Machine | `is_work` | `user.name` | `user.email` |
|---|---|---|---|
| Work Mac | `true` | `zyz` | `zhongyuzhe@bytedance.com` |
| Personal Mac | `false` | `Kyrie` | `yuzhezhong0117@qq.com` |

The values live inside `dot_gitconfig.tmpl` guarded by `{{ if .is_work }} … {{ else }} … {{ end }}`. `is_work` is prompted once at `chezmoi init` and stored in `~/.config/chezmoi/chezmoi.toml`. To flip it, re-run `chezmoi init` (or edit the toml directly and `chezmoi apply`).

---

## Alias reference

Git aliases kept in `~/.gitconfig`:

| Alias | Expands to |
|---|---|
| `git lg` | `log --graph --pretty=format:'%C(auto)%h%d %s %C(blue)(%cr) %C(bold blue)<%an>' --abbrev-commit` |

Shell aliases for git live in `dot_config/zsh/aliases.zsh` (Phase 3): `gst`, `gco`, `gcb`, `gcm`, `ga`, `gaa`, `gd`, `gl`, `gp`. See that file for the full list.

---

## Global ignore

`~/.gitignore_global` covers OS + editor cruft only — **not** `.env` / `.idea/` / `.vscode/`, which are per-project decisions:

- macOS Finder metadata: `.DS_Store`, `.AppleDouble`, `.LSOverride`
- Editor swap / temp: `.*.swp`, `.*.swo`, `*~`
- Local-only env overrides: `.env.local`, `.envrc.local` (project-level `.env` / `.env.example` stay tracked)

---

## lazygit

Kickstart-style 80%-useful config — customize as real needs emerge.

- **Theme:** Catppuccin Mocha, same palette as ghostty / yazi / starship (`#89b4fa` blue active border, `#313244` selection background, …)
- **Pager:** `delta --paging=never` so lazygit's diff pane matches `git diff` output
- **Editor:** `nvim` via `os.edit` / `os.editAtLine` — `e` on a file in the staging pane opens it at the right line
- **Other:** file tree on, random tip off, mouse events on, nerd fonts v3

Runtime note: lazygit **does not** read `~/.gitconfig` `[alias]` entries; lazygit's own keymap drives the TUI. Keep custom git aliases in `~/.gitconfig` for shell use.

---

## gh (GitHub CLI)

Only non-default values are in `config.yml`; unset keys fall back to gh's built-in defaults. Verify with `gh config list`.

Aliases optimized for the PR-review loop:

| Alias | Expands to | Use case |
|---|---|---|
| `gh co` | `pr checkout` | Pull a PR locally for testing |
| `gh pv` | `pr view` | Read PR body + comments in terminal (`-w` for browser) |
| `gh pl` | `pr list` | See open PRs |
| `gh pc` | `pr checks` | CI status for the current branch's PR |
| `gh pm` | `pr merge` | Merge (use `--squash` / `--rebase` per repo policy) |
| `gh prs` | `pr status` | PRs involving you (authored / assigned / review-requested) |
| `gh il` / `gh iv` | `issue list` / `issue view` | Issue equivalents |

> **`hosts.yml` is NOT tracked.** It holds per-machine auth state (username + keyring path; the oauth token itself lives in macOS Keychain). `.chezmoiignore` pre-emptively excludes `dot_config/gh/hosts.yml` in case it ever lands in source.

---

## Change / Add a setting

1. Edit `dot_gitconfig.tmpl` (or `dot_gitignore_global`).
2. `chezmoi diff` — review the rendered diff against `~/.gitconfig`.
3. `chezmoi apply`.
4. Add a regression guard in `tests/git.sh` under **Active global config** if it's a knob we care about keeping.

---

## Health check

### Automated

```bash
bash tests/git.sh
```

Covers: binary presence, target-file presence, every pinned setting under `[core] [init] [push] [fetch] [rebase] [merge] [interactive] [delta] [commit] [credential] [alias]`, and a template-side regression guard that both identity branches exist.

### Manual

- [ ] `git config --global user.email` matches the current machine's identity
- [ ] `git diff <some-file-with-changes>` renders through delta (side-by-side, line numbers visible)
- [ ] `git lg -5` shows a colored graph
- [ ] Cloning a fresh HTTPS repo prompts for credentials once, then caches via Keychain
- [ ] `lazygit --print-config-dir` returns `~/.config/lazygit` (not `~/Library/…`)
- [ ] `lazygit` opens with Mocha-blue borders and delta-rendered diffs
- [ ] `gh pv` / `gh pc` run from any dir and target the current repo's PR
- [ ] On the **other** machine after `chezmoi apply`: `user.email` is the other identity

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `fatal: bad config line N in file ~/.gitconfig` | Template failed to render cleanly | `chezmoi diff` / `chezmoi execute-template < dot_gitconfig.tmpl` to reproduce |
| Identity is wrong after switching machines | `is_work` wasn't re-prompted | Edit `~/.config/chezmoi/chezmoi.toml` (flip `is_work`) → `chezmoi apply` |
| `fatal: unknown style 'zdiff3'` | git < 2.35 | `brew upgrade git` |
| Delta not invoked on `git diff` | `delta` missing from PATH | `brew install git-delta` |
| `interactive.diffFilter` noise when stdin is not a tty | Expected: it only triggers interactively | Not a bug |
| lazygit ignores `~/.config/lazygit/config.yml` | `XDG_CONFIG_HOME` not exported in current shell | Open a new zsh (reads `dot_zshenv`), or `export XDG_CONFIG_HOME=$HOME/.config` manually |
| `gh` asks to re-auth on a machine that was logged in | `hosts.yml` missing (never tracked) | `gh auth login` — runs once per machine |

---

## Gotchas

- **Scripts that parse `git diff` output** must pass `-c core.pager=cat` — otherwise delta's colored, paginated output confuses them.
- **No global `.idea/` / `.vscode/` ignore** — these are per-project decisions. Add to repo-local `.gitignore` when relevant.
- **`gh` credential helper** shadows `osxkeychain` for GitHub URLs after `gh auth login`. This is intentional; removing one doesn't break the other.
- **Repo-local overrides take precedence.** `~/.dotfiles/.git/config` currently pins `user.email = yuzhezhong0117@qq.com` (legacy; safe to delete after Phase 6a merges and personal identity goes global-default on the personal Mac).

---

## Rebuild from scratch

If `~/.gitconfig` / `~/.gitignore_global` get clobbered:

```bash
chezmoi apply ~/.gitconfig ~/.gitignore_global
```

No reinstall needed — chezmoi re-renders the template against current `is_work`.
