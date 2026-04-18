# Fastfetch

> English · [中文](fastfetch.zh.md)

System-info tool with an Apple-logo banner. Bound to `s` (the single-letter `$EDITOR`-adjacent alias in `aliases.zsh`) — run it in any fresh shell to see machine/VM/dev-tool state at a glance. Config is a single JSONC file; one tiny Bash helper renders the lume subtree.

## How it works

| Thing | Where | Note |
|---|---|---|
| Config | `~/.config/fastfetch/config.jsonc` ← source `dot_config/fastfetch/config.jsonc` | Single JSONC file, chezmoi-managed. |
| lume helper | `~/.config/fastfetch/lume-status.sh` ← source `dot_config/fastfetch/executable_lume-status.sh` | +x via chezmoi `executable_` prefix. bash 3.2-safe (macOS system shell). |
| Alias | `~/.config/zsh/aliases.zsh` → `alias s='fastfetch'` | Set in Phase 3. |

## Layout

5 groups separated by `● ● ●` powerline dots. Each group has a single color theme so the whole pane reads as semantic bands:

| Group | Color | Modules |
|---|---|---|
| Identity | green | `Account`, `os`, `Host`, `Kernel`, `Uptime`, `Packages`, `Terminal`, `TerminalFont`, `Shell` |
| Computer | yellow | `CPU`, `Usage`, `GPU`, `Memory`, `Battery`, `Swap`, `LocalIP` |
| Disk | red + magenta | `PhysicalDisk`/`Drive`, `MountedFileSystems`/`FileSystem` |
| **Dev** | cyan | `Editor` (nvim), `Claude`, `lume` (+ per-VM tree sub-lines) |
| Peripherals | blue | `Bluetooth`, `Monitor`, `Brightness` |

### Dev group

Frequently-checked dev-tool versions. `lume` is treated specially because Hermes agent lives on top of it: the helper script emits the version, then one indented sub-line per VM with the tree prefix `├` / `└`:

```
󰚩 Dev
󰈙 Editor    nvim 0.12.1
󰭹 Claude    2.1.114
󰡢 lume      0.3.8
             └ openclaw: stopped · 4c/8G · 32G/96G · nat/home
```

Per-VM fields: `name: status · cpu/mem · diskUsed/diskTotal · network/storage`. When the VM is running, `· <ip>` is appended. When no VMs are registered, only the version line shows.

## Change a segment

1. Open `dot_config/fastfetch/config.jsonc` — modules live under the top-level `modules` array in visual order.
2. Drop, reorder, or edit in place. No reload — fastfetch re-reads config on every invocation.
3. For the lume subtree, edit `dot_config/fastfetch/executable_lume-status.sh` — fastfetch calls it fresh each render.

## Add a module

Most modules are one-liners:

```jsonc
{ "type": "command", "key": " mymod", "keyColor": "cyan",
  "text": "echo hello" }
```

For multi-line output from a `command` module, fastfetch only prepends its logo-skip + value-goto ANSI sequences to the **first** line. Subsequent lines start at absolute col 0 in the terminal, which lands in the logo area. Re-align each continuation line by emitting CHA (`\x1b[<col>G`) yourself — `lume-status.sh` does this with `VCOL=55` (= 34 Apple-logo cols + 21 key.width).

## Health check

### Automated

```bash
bash tests/fastfetch.sh
```

~44 checks: fastfetch on PATH, config + helper script present/executable, `s` alias wired, prompt renders without `JsonConfig` / `Error:` strings, every expected module appears in rendered output, Dev-group commands (`claude`, `lume`, `python3`) are reachable, lume version parses, lume sub-line carries tree prefix + status (skipped when no VMs registered), schema-drift regression guards (no `general.multithreading`, no `display.bar.charElapsed` — both rejected by fastfetch ≥2.x), and every nerd-font PUA codepoint still sits in the config (PUA chars are invisible in most editors and get silently stripped during rewrites).

### Manual (real TTY required)

1. Run `s` in a fresh Ghostty tab.
2. Apple logo renders as ASCII art (not boxes).
3. All nerd-font glyphs render (󰀵 mac, 󰂯 bluetooth, ● circles), not `□`.
4. Five color bands are visibly distinct (green → yellow → red/magenta → cyan → blue).
5. Dev group shows Editor/Claude/lume with matching column alignment.
6. `lume run <vm>` then `s` again — VM sub-line flips from `stopped` to `running · <ip>`.

## Troubleshooting

**`JsonConfig Error: ...` on startup** — schema drift. fastfetch ≥2.x has renamed/dropped several keys. Known cases fixed in this config: `general.multithreading` (removed — default is multithreaded), `display.bar.charElapsed` → `display.bar.char.elapsed`. If a new one shows up, `fastfetch --gen-config-force` writes a fresh default you can diff against.

**TerminalFont shows "Unknown terminal: <version>"** — fastfetch doesn't recognise Ghostty yet (it falls back to reading `$TERM_PROGRAM`). The row is hidden by `display.showErrors: false`. Will self-resolve when fastfetch adds Ghostty detection; no workaround needed here.

**lume row shows `(unavailable)`** — `lume` not on `PATH` or the CLI errored. Check `command -v lume` and `lume --version` by hand. Brewfile doesn't install lume (it's manually installed per the Hermes setup).

**lume sub-line missing after starting a VM** — `lume ls --format json` returns null/empty. Run `lume ls` directly to see raw state. If `/usr/bin/python3` is missing (rare on macOS 26), the Python JSON parser in `lume-status.sh` silently yields nothing — install Command Line Tools.

**Glyphs render as `□` boxes** — terminal font isn't a Nerd Font. Brewfile pins `font-maple-mono-nf-cn`; point your terminal's `font-family` at `Maple Mono NF CN`. Same fix as starship.

## Gotchas

**`lume-status.sh`'s `VCOL` is coupled to logo + key widths.** `VCOL=55` = Apple logo (34 cols) + `display.key.width` (21). If you switch logo (another OS) or bump `display.key.width`, update `VCOL` to match — fastfetch doesn't expose these to the helper, so the coupling is manual.

**lume-status.sh targets bash 3.2.** macOS only ships `/bin/bash 3.2`, so no `mapfile`, no associative arrays. Don't "modernise" it assuming bash 5 — a fresh Mac will break.

**PUA codepoints are invisible in most editors.** Each nerd-font glyph lives in U+E000–U+F8FF or U+F0000+. If you copy the config to a reformatter that doesn't preserve PUA, the glyph silently becomes a space and the regression guards in `tests/fastfetch.sh` will fire.

## Rebuild from scratch

```bash
# Nothing to wipe — fastfetch is stateless. Re-apply source config:
chezmoi --source ~/.dotfiles apply
```

If `s` runs but shows no logo/glyphs, check: (1) `fastfetch` on PATH (`brew install fastfetch`), (2) terminal font is Nerd Font, (3) `config.jsonc` parses (`fastfetch 2>&1 | grep -i error`).
