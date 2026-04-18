# Starship prompt

> English · [中文](starship.zh.md)

Cross-shell prompt written in Rust. We use it for: single-line powerline context + trailing feedback on terminal bg, Catppuccin Mocha palette matching `$BAT_THEME`, vi-mode visual cue (paired with OMZP::vi-mode), and four feedback modules that only show when they matter.

## How it works

| Thing | Where | Note |
|---|---|---|
| Config | `~/.config/starship.toml` → source `dot_config/starship.toml` | Single file, chezmoi-managed. |
| Shell init | `~/.config/zsh/tools.zsh` → `eval "$(starship init zsh)"` | Guarded by `$+commands[starship]`. |
| Palette | `catppuccin_mocha` defined inline | Matches `BAT_THEME="Catppuccin Mocha"` in `env.zsh`. |

## Prompt layout

Line 1 holds the powerline ribbon; feedback trails it on terminal bg so semantic colors aren't eaten by `bg:mauve`. Line 2 is just `$character`.

    ╭─  ~/.dotfiles   main  ✓    19:42 ▶ ✘ ERROR took 14s ✦ 2 󰭹 claude
    ╰─ ❯

**Line 1, ribbon — context (always visible, coloured backgrounds):**

| Segment | What | Rationale |
|---|---|---|
| `$os` | OS icon | multi-platform cue (mac/linux). |
| `$username` | user, only if ≠ default | `show_always = false` — spelling out `bytedance` on every line is noise. |
| `$directory` | 3-level truncated path | substitutions render common dirs as nerd-font icons. |
| `$git_branch + $git_status` | branch + dirty markers | single segment, one color — branch always fits on one glance. |
| `$c + $python` | C / Python version | algo research stack. `$package` removed (node/rust noise). |
| `$time` | `%R` wall clock | no tmux status bar, so prompt is where the clock lives. Closes the ribbon. |

**Line 1, trailing — feedback (inline after the ribbon, no background, shown only when triggered):**

| Module | Fires when | Color | Why |
|---|---|---|---|
| `$status` | last command exited non-zero | `bold fg:red` | fail-loud instead of fail-quiet. |
| `$cmd_duration` | last command ran ≥ 3s | `fg:yellow` | training / OJ runs — "did this actually take that long?" without `time`. |
| `$jobs` | ≥ 1 background job | `fg:sapphire` | `&`-launched training jobs stay visible. |
| `$custom.claude` | `CLAUDECODE=1` is set | `bold fg:mauve` | prompt in a shell spawned inside a Claude Code session is visually distinct. |

**Line 2 — `$character` only:** green `❯` on success, red `❯` on failure, mauve `❮` in vi-normal.

## Change a segment

1. Find the segment in `dot_config/starship.toml` (grouped under `# ─── Context segments ───` and `# ─── Feedback modules ───`).
2. Edit in place — no shell reload needed; starship re-reads config on every prompt.
3. Add/remove from the top-level `format = """..."""` block to change left-to-right order or drop a segment entirely.

## Add a custom module

```toml
[custom.mymodule]
description = "..."
when        = 'test -n "$SOME_ENV"'   # POSIX test, evaluated by /bin/sh
command     = "echo"                   # empty stdout; format carries literal text
format      = '[  mymodule ]($style)'
style       = "bold fg:lavender"
```

Append `$custom` to the `format` block once — it expands to every `[custom.*]` module registered.

## Health check

### Automated

```bash
bash tests/starship.sh
```

25 checks: starship on PATH, config file present, `starship print-config` parses, tools.zsh wires it, `starship prompt` renders clean + error states, each feedback module fires under the right input (`--status=1`, `--cmd-duration=5000`, `--jobs=1`, `CLAUDECODE=1`), live prompt output carries Powerline + macOS + arrow codepoints, config still has git / c / python / clock / Downloads / Pictures nerd-font glyphs (PUA codepoints are invisible in most editors and got stripped five times during earlier rewrites), feedback modules don't carry `bg:mauve` (regression guard — they used to sit inside the ribbon with salmon-on-purple contrast), and `vimcmd_symbol` uses `fg:mauve` (regression guard — was `fg:green` and visually identical to success).

### Manual (real TTY required)

Open a new terminal tab:

1. Prompt shows **two lines** — first line ribbon + (possibly) trailing feedback, second line just `❯`.
2. Nerd-font glyphs render as icons (mac 󰀵, chat 󰭹, ✦), not `□` boxes. The Brewfile-pinned font is **Maple Mono NF CN**; if glyphs are boxes your terminal's `font-family` isn't pointing at it.
3. `sleep 4` — after the time segment, yellow `took 4s` appears (trails the ribbon, no bg).
4. `false` — trailing feedback shows **bold red** `✘ ERROR`.
5. `sleep 100 &` — trailing feedback shows **sapphire** `✦ 1`. `wait` or `kill %1` to clean up.
6. Inside Claude Code, `$CLAUDECODE=1` — trailing feedback shows **bold mauve** `󰭹 claude`.
7. Press Esc after typing something — the line-2 arrow flips from green `❯` to **mauve `❮`** (vi-normal).

## Troubleshooting

**Nerd-font glyphs show as `□` boxes** — terminal font isn't a Nerd Font. The Brewfile ships `font-maple-mono-nf-cn`; point your terminal's `font-family` at `Maple Mono NF CN`. Phase 4b wires this into Ghostty automatically; on stock Terminal.app or iTerm2 set it in preferences.

**`$custom.claude` never fires inside Claude Code** — check `echo $CLAUDECODE` in the session. If empty, the parent Claude Code version is older than the `CLAUDECODE=1` injection (≥ 1.x). Workaround: add a second detection branch via `when = 'test -n "$CLAUDECODE" -o -n "$CLAUDE_CODE_ENTRYPOINT"'`.

**vi-mode indicator stuck on green after Esc** — OMZP::vi-mode didn't toggle `$KEYMAP`. Verify `zinit snippet OMZP::vi-mode` is loaded in `plugins.zsh` (sync, not Turbo — vi-mode needs to bind keys before the first prompt).

**Color looks wrong** — `palette = 'catppuccin_mocha'` but a module references a name not in the palette. Starship silently falls back to default terminal foreground. Grep the config for suspect color names and cross-check against `[palettes.catppuccin_mocha]`.

**`starship prompt` hangs in a script** — rare, but `$cmd_duration` or `$custom` can invoke slow subprocesses. Run `starship timings` in an interactive shell to spot the offender.

## Gotchas

**Starship init must come AFTER `OMZP::vi-mode`.** Order in `tools.zsh`: fzf → zoxide → starship; `plugins.zsh` loads vi-mode synchronously. If you flip the order, `vimcmd_symbol` binds to an uninitialised `$KEYMAP` and the indicator never switches.

**Catppuccin color names are not universal.** Mocha does NOT define `orange` or `purple`. Old config had `orange = "#cba6f7"` (actually mauve's hex) and `bg:purple` references that silently fell back to terminal default. Fixed in this phase — if you add modules, reference names from `[palettes.catppuccin_mocha]` only.

**`starship prompt` in a non-TTY returns ANSI codes, not glyphs.** The automated tests grep for literal `✘`, `took`, etc. — keep format strings using these markers or the tests break.

## Rebuild from scratch

```bash
# Nothing to wipe — starship is stateless. Just re-apply config:
chezmoi --source ~/.dotfiles apply
```

If `starship init zsh` stops firing, verify `starship` is on PATH (`brew install starship`) and `tools.zsh` still has the guarded block.
