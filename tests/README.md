# Live health checks

> English — bilingual split is only for user-facing runbooks under `docs/`.

Per-package checks for a real Mac after `chezmoi apply`. Deterministic source checks live in
`scripts/check_repo.py` and run through `make verify`; CI never runs this directory.

## Principles

- **Live environment** — reads rendered files under HOME plus installed CLIs and caches.
- **Non-interactive entrypoint** — no prompts, though a check can initialize a cache or install a
  missing plugin as part of the program's normal headless startup.
- **Scope** — applied file presence, runtime parse, environment values, aliases, caches, and CLI availability.
- **Out of scope** — anything requiring real terminal rendering: plugin widgets that only fire on `precmd`, fzf-tab menu, autosuggestion overlay, syntax-highlight colors, prompt theme rendering. Those live in `docs/<pkg>.md` under `## Health check → Manual`.

## Run

```bash
make health PACKAGE=<pkg>
```

Exit 0 = all checks green. Exit 1 = at least one red; script prints each failure and points back at the manual checklist.

Agent workflow checks are split by layer: `tests/ghostty.sh` for the primary terminal surface, `tests/herdr.sh` for the in-terminal agent multiplexer, and `tests/claude.sh` for Claude Code hooks.

## Add a new one

1. Copy `tests/zsh.sh` as a template.
2. Keep the section headers: **File presence / Syntax / Shell probe / Aliases / Caches / CLI tools**. Drop sections that don't apply; don't invent new ones (consistency matters more than flexibility here).
3. Mirror the automated/manual split in `docs/<pkg>.md`. The `## Health check` section there should link to `tests/<pkg>.sh` for Automated and list Manual steps for anything this script can't cover.
4. Keep source-only invariants in `scripts/check_repo.py`; a live check must not become a hidden CI dependency.
