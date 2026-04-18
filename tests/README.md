# Tests

> English — bilingual split is only for user-facing runbooks under `docs/`.

Per-package non-interactive health checks. One script per phase.

## Principles

- **Non-interactive** — runs in a plain bash subshell, no TTY, no user input. Safe for CI.
- **Fast** — < 3 seconds per script. Batches probes into a single `zsh -ic` where useful.
- **Scope** — file presence, syntax parse, env-var set-ness, alias definition, cache directories, CLI tool availability.
- **Out of scope** — anything requiring real terminal rendering: plugin widgets that only fire on `precmd`, fzf-tab menu, autosuggestion overlay, syntax-highlight colors, prompt theme rendering. Those live in `docs/<pkg>.md` under `## Health check → Manual`.

## Run

```bash
bash tests/<pkg>.sh
```

Exit 0 = all checks green. Exit 1 = at least one red; script prints each failure and points back at the manual checklist.

## Add a new one (new phase)

1. Copy `tests/zsh.sh` as a template.
2. Keep the section headers: **File presence / Syntax / Shell probe / Aliases / Caches / CLI tools**. Drop sections that don't apply; don't invent new ones (consistency matters more than flexibility here).
3. Mirror the automated/manual split in `docs/<pkg>.md`. The `## Health check` section there should link to `tests/<pkg>.sh` for Automated and list Manual steps for anything this script can't cover.

See [project_phase_package_layout memory] — three-part convention (config + tests + docs) applies to every phase from Phase 3 onward.
