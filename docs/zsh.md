# Zsh runbook

> English · [中文](zsh.zh.md)

zsh + zinit Turbo. Goals: fast startup (~70-100ms critical path once plugins are cached), predictable load order, and a module split where each file has exactly one job. This doc is the operator's manual — extend, debug, rebuild.

## How it works

### Entry points

| File | Read by | Job |
|---|---|---|
| `~/.zshenv` | every zsh invocation (login, interactive, subshell, script) | PATH baseline, EDITOR, LANG |
| `~/.zshrc` | interactive zsh only | orchestrator — sources modules in order, nothing else |

### Modules (`~/.config/zsh/*.zsh`)

Each module has exactly one responsibility — adding or debugging a feature means touching exactly one file.

| File | Content | Rule |
|---|---|---|
| `env.zsh` | `export`s + `brew shellenv` | Only env vars. No tool init, no aliases. |
| `plugins.zsh` | zinit bootstrap + all plugin declarations | All `zinit` calls live here. |
| `tools.zsh` | CLI tool runtime activation (`fzf --zsh`, `zoxide init`) | Must load AFTER plugins — fzf-tab depends on fzf widgets. |
| `aliases.zsh` | aliases grouped by `# ─── Topic ───` headers | Only `alias` lines. Nothing else. |
| `keybinds.zsh` | `bindkey` overrides | Reserved slot (empty in Phase 3). |
| `secrets.zsh` | decrypted from `encrypted_private_secrets.zsh.age` | Managed by age + chezmoi; see [secrets.md](secrets.md). |

### Load order

`.zshrc` sources modules in this fixed order:

    env → plugins → tools → aliases → keybinds → secrets

Changing the order breaks things:

- `tools` before `plugins` → fzf-tab has no compinit state to hook into.
- `aliases` before `plugins` → plugin-defined aliases override yours instead of the other way around.

## Add a plugin

Edit `plugins.zsh`, add a line inside the `zinit wait lucid for` block:

```zsh
# Most plugins — load async, no setup needed
zinit wait lucid for \
    ...existing... \
    author/plugin-name

# Plugin that registers completions — needs `blockf` to protect fpath
zinit wait lucid for \
    ...existing... \
    blockf \
        author/completion-plugin

# Plugin that needs a post-load callback
zinit wait lucid for \
    ...existing... \
    atload'_plugin_init_fn' \
        author/needs-init
```

No `chezmoi apply` needed; zinit auto-clones on the next `zsh` prompt.

## Add an alias

Edit `aliases.zsh`. File is grouped by `# ─── Topic ───` comment headers — drop your alias under the matching section, or start a new one if the topic is genuinely new.

## Add a CLI tool integration

- Needs runtime activation (keybinds, prompt hook, auto-cd) → `tools.zsh`
- Just exports env vars → `env.zsh`

Rule of thumb: if the tool's docs say `eval "$(tool init)"` or `source <(tool)`, it belongs in `tools.zsh`.

## Health check

### Automated

```bash
bash tests/zsh.sh
```

49 checks covering: file presence, `zsh -n` syntax, env vars, aliases, zinit + plugin caches, CLI tools on PATH. Exit 0 = all green.

### Manual (real TTY required)

Turbo plugins load on the `precmd` hook, so `zsh -i -c '...'` or scripted shells never trigger them. Open a new terminal tab and verify by eye:

1. Type `git sta` — "tus" should appear as grey inline suggestion (autosuggestions).
2. Type `ls` — the command should render colored (green/cyan), not plain white (syntax-highlighting).
3. Press Tab on an empty `git ` — fzf-style menu should appear (fzf-tab).
4. Press Esc — right side of prompt should show `[NORMAL]`. *Phase 3 caveat: this requires a prompt theme that calls `vi_mode_prompt_info`. Starship (Phase 4) covers this; until then bindings work but the indicator is invisible.*

## Startup perf

| State | `time zsh -i -c exit` |
|---|---|
| Cold (plugins uncached) | 30-60s — zinit downloads 4 plugins from GitHub |
| Warm (plugins cached) | 60-100ms |

Turbo (`wait lucid`) moves plugin load **off** the critical path: plugins attach after the first prompt renders. In `zsh -i -c exit` this looks misleadingly fast (no prompt = no Turbo fire); what matters interactively is that prompt shows immediately and plugins fill in within ~50ms.

Measure:

```bash
time zsh -i -c exit
```

Profile:

```bash
zsh -xvis 2>&1 | ts -i "%.s" | head -200
```

Check whether a specific plugin is loaded via Turbo:

```zsh
zinit report author/plugin-name
```

## Troubleshooting

**Health check `tests/zsh.sh` reports a plugin as "downloaded: FAIL"** — `chezmoi apply` didn't re-run the install hook, or zinit failed to clone. Run `rm -rf ~/.local/share/zinit && zsh` — the self-install fallback in `plugins.zsh` re-clones on first prompt.

**Tab just inserts a literal Tab, completions are gone** — `compinit` didn't run. Check that `atinit"zicompinit; zicdreplay"` is still on fzf-tab in `plugins.zsh`; that's the single place where compinit fires.

**`(eval):1: can't change option: zle` warnings in scripts** — OMZP::vi-mode toggles `setopt zle`; non-interactive shells refuse. Harmless; don't "fix" it by removing vi-mode.

**Startup suddenly got slow** — a newly-added plugin is probably outside the `zinit wait lucid for` block, making it load synchronously. Check `plugins.zsh`.

**Syntax highlighting silently stopped working** — you loaded something **after** `zsh-syntax-highlighting`. It can only wrap widgets that existed at its load time. Move the new plugin higher in the `for` block.

## Gotchas

**`zsh-syntax-highlighting` must be last.** Anything declared after it is outside its widget-wrap scope. Single most common zinit footgun.

**`COLUMNS` export trick.** The `export COLUMNS=$(tput cols 2>/dev/null || echo 200)` line in `env.zsh` exists because claude-hud's statusLine subprocess otherwise inherits `COLUMNS=0` and falls back to a 40-char terminal width — "compact" mode then wraps onto 5+ lines. See [claude-hud#408](https://github.com/jarrodwatts/claude-hud/issues/408).

**First `chezmoi apply` downloads all plugins — expect 30-60s.** Subsequent applies are instant. If it looks hung, it's pulling from GitHub.

**Prompt has no vi-mode indicator until Phase 4.** OMZP::vi-mode defines `vi_mode_prompt_info` but relies on the theme to call it. Bindings work; the visual `[NORMAL]` lands with Starship.

## Rebuild from scratch

```bash
# Wipe zinit state + plugin caches (keeps your config files)
rm -rf ~/.local/share/zinit

# Open a new `zsh` — the self-install in plugins.zsh re-clones zinit,
# and Turbo re-downloads each plugin on first prompt.
```

The chezmoi install hook (`run_once_after_30-zinit-install.sh`) is a bootstrap safety net; `plugins.zsh` self-installs on its own, so deleting `~/.local/share/zinit` is enough.
