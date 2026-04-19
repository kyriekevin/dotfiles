# Claude Code

> English · [中文](claude.zh.md)

Cross-machine Claude Code config: **`~/.claude/settings.json` only.** Everything else under `~/.claude/` — sessions, auto-memory, plugin caches, session-env, logs, allowlists — is machine-local runtime state and **ignored on purpose** (see `.chezmoiignore`).

The per-plugin / per-MCP / per-skill deep-dive lives in [`claude-plugins.md`](claude-plugins.md); this doc is the settings spine.

## How it works

| Source (repo) | Target (`$HOME`) | Behavior |
|---|---|---|
| `dot_claude/settings.json` | `~/.claude/settings.json` | Plain copy. No template — every field is currently cross-machine. |
| _(excluded)_ | `~/.claude/settings.local.json` | Per-project permission allowlist; machine-specific paths only. |
| _(excluded)_ | `~/.claude/sessions/` `projects/` `plans/` `cache/` `…` | Runtime only — see **Runtime exclusions** below. |

`chezmoi apply` renders `dot_claude/settings.json` to `~/.claude/settings.json`. No hook scripts, no plugin re-install — `enabledPlugins` declares intent, Claude's internal marketplace fetcher resolves it on next launch.

## Two persistence systems (why we only manage one)

Claude Code has **two** cross-session memory mechanisms. We only version the first:

| | **Settings** (`settings.json`) | **Memory** (`CLAUDE.md` + auto-memory) |
|---|---|---|
| Writes | You, declarative JSON | You write `CLAUDE.md`; Claude writes auto-memory |
| Strength | Hard — `deny` rules and hooks can block tool calls | Soft — context injected as a user message, no enforcement |
| Cross-machine | Yes (when placed in repo) | **No — auto-memory is explicitly machine-local per [docs](https://code.claude.com/docs/en/memory#storage-location)** |
| Our repo | `dot_claude/settings.json` | Deferred; no user-level `CLAUDE.md` tracked yet |

The second system is worth knowing about but *must not* enter the repo: `~/.claude/projects/<proj>/memory/MEMORY.md` is a per-working-tree artifact that would leak between work and personal Macs if shared.

## Pinned fields

`dot_claude/settings.json` holds six keys. All are cross-machine preferences — no `{{ if .is_work }}` branching needed today.

| Field | Value | Why pinned |
|---|---|---|
| `$schema` | `json.schemastore.org/claude-code-settings.json` | Autocomplete + inline validation in any JSON-schema-aware editor. Zero runtime cost. |
| `hooks.PreToolUse[Bash]` | `npx block-no-verify@1.1.2` | Intercepts `git commit --no-verify` / `git push --no-verify` — matches the "never skip hooks" rule in CLAUDE.md. |
| `statusLine` | `bash -c '... bun … claude-hud/src/index.ts'` | Picks highest-versioned claude-hud install, execs it via bun. Hardcoded `/opt/homebrew/bin/bun` is fine on Apple Silicon Macs (both of ours). |
| `enabledPlugins` | 4 entries | `claude-hud` (status HUD) · `codex` (OpenAI Codex lifecycle hooks) · `andrej-karpathy-skills` (skill pack) · `chrome-devtools-mcp` (frontend debug over live Chrome). |
| `extraKnownMarketplaces` | 4 GitHub sources | Registers the `github:owner/repo` marketplaces that satisfy `enabledPlugins`. Needed on a fresh Mac before Claude can resolve plugin IDs. |
| `syntaxHighlightingDisabled` | `true` | Response highlighting has intermittent terminal-render bugs in ghostty — killed it, prefer plain. |
| `effortLevel` | `"xhigh"` | Claude's [extended-thinking budget](https://code.claude.com/docs/en/model-config#adjust-effort-level). Persisted automatically when you run `/effort`; pin it so new Macs don't default back to medium. |

## Runtime exclusions (why each is ignored)

`.chezmoiignore` blocks the following from ever entering source control:

| Path | Contains | Why not cross-machine |
|---|---|---|
| `dot_claude/settings.local.json` | Per-project Bash/WebFetch allowlists | Paths are `/Users/bytedance/...` — worthless on another Mac. Entries can also embed machine-specific internal URLs or credential fragments. |
| `dot_claude/sessions/` | JSONL transcripts of every Claude run | Grows to MB/day. Resume data, not config. |
| `dot_claude/projects/<proj>/memory/` | Auto-memory files Claude writes itself | Docs: **machine-local by design**. Sharing would collide between work and personal. |
| `dot_claude/plans/` | `/plan` mode outputs | Work artifacts, not config. Our `0-1-dotfiles-*.md` plan lives here locally; each machine has its own. |
| `dot_claude/plugins/` | Marketplace cache + install metadata | Re-created on launch from `enabledPlugins` + `extraKnownMarketplaces`. Includes `blocklist.json` and `install-counts-cache.json` which churn. |
| `dot_claude/cache/` `image-cache/` `paste-cache/` | Throwaway caches | — |
| `dot_claude/file-history/` `shell-snapshots/` | Undo / command history | Per-session; huge. |
| `dot_claude/tasks/` | Background subagent outputs | Per-invocation. |
| `dot_claude/telemetry/` `metrics/` `homunculus/` | Usage telemetry | Anthropic-internal shape, machine-specific. |
| `dot_claude/session-data/` `session-env/` | Current-session env snapshots | Per-session. |
| `dot_claude/chrome/` `downloads/` | Browser-extension cache | Machine-local. |
| `dot_claude/*.jsonl` `*.log` `*-cache.json` | `history.jsonl`, `bash-commands.log`, `cost-tracker.log`, `stats-cache.json` | Logs and caches. |
| `dot_claude/agents/` `skills/` `commands/` `rules/` `CLAUDE.md` | **Unused extension points** | Not currently populated. Pre-emptively ignored so a stray `chezmoi add ~/.claude` can't silently start versioning something we haven't evaluated. Delete the ignore entry before opting any of these into source. |
| `dot_claude.json` (note: `.claude.json`, **not** under `.claude/`) | App state: `mcpServers{}` entries (often embedding API tokens / OAuth secrets in plaintext env blocks), OAuth account, onboarding + feature-flag caches | Per-machine runtime + live credentials. Defensive ignore so `chezmoi add ~/.claude.json` is a no-op. Any MCP with a token is configured per-user with `claude mcp add` and stays in this file. |

## Scopes cheat-sheet (2026)

Precedence high→low, same as [upstream docs](https://code.claude.com/docs/en/settings#settings-precedence):

```
managed (MDM/server)     ← IT, can't be overridden
CLI flags                ← one session
.claude/settings.local.json (project, gitignored)
.claude/settings.json       (project, shared)
~/.claude/settings.json     ← we manage this
```

So our `dot_claude/settings.json` is the **lowest-precedence** layer — project-level settings always win. That's desirable: projects should be free to tighten permissions or swap the model without fighting `~/.claude/`.

## Hooks at a glance

Claude Code now supports **29 lifecycle events** × **4 handler types** (`command` / `http` / `prompt` / `agent`). We use one:

- **PreToolUse, matcher=Bash** → `npx block-no-verify@1.1.2`. Runs before every Bash tool call; exits non-zero → Claude is told the command was blocked.

Hooks we intentionally *don't* configure at user level:

- Plugin `.mjs` hooks (e.g. `openai-codex` SessionStart/SessionEnd/Stop) live in `~/.claude/plugins/cache/openai-codex/…/hooks/hooks.json` — installed by the plugin itself when `enabledPlugins` references it. **We don't duplicate them in `settings.json`.**
- Anything project-scoped (e.g. PostToolUse lint hooks) belongs in that project's `.claude/settings.json`, not here.

## Plugin model

`enabledPlugins` + `extraKnownMarketplaces` is a **declaration**, not a vendoring. On `~/.claude/plugins/` being empty, Claude re-fetches from the declared marketplaces on next launch.

Four plugins are currently declared — see [`claude-plugins.md`](claude-plugins.md) for per-plugin usage / commands / skills:

| Plugin | What it ships | Namespace |
|---|---|---|
| `claude-hud@claude-hud` | `statusLine` backend (the bun script pointed to by our `statusLine` field) | — |
| `codex@openai-codex` | `.mjs` SessionStart / SessionEnd / Stop hooks + `codex-rescue` subagent | `/codex:*` skills |
| `andrej-karpathy-skills@karpathy-skills` | Skill pack | `/karpathy-skills:*` skills |
| `chrome-devtools-mcp@claude-plugins-official` | MCP server wrapping Chrome DevTools Protocol — console / network / performance traces against a live Chrome | MCP tools (no skill namespace) |

> **Token-bearing or network-restricted MCPs** are not declared in this repo. Add them per-user with `claude mcp add` — the config lands in `~/.claude.json` (which we `.chezmoiignore` defensively so secrets can't leak in).

---

## Using Claude Code effectively

This section is the "how to actually use it" companion to the config above. Everything here is a feature Claude Code *already ships* — no setup needed beyond the six fields we pinned. Pulled from the 2026 docs (last fetched during Phase 6b).

### Core mental model

| Concept | Lives in | When to reach for it |
|---|---|---|
| **Conversation / session** | `~/.claude/sessions/` | One chat thread. `/resume` picks one up. `/clear` starts a new one; old one still resumable. |
| **Context window** | Runtime memory | Everything Claude can "see" in this turn. Finite. `/context` shows what's eating it. |
| **Checkpoint** | `~/.claude/file-history/` | Pre-edit file snapshot. `Esc` `Esc` or `/rewind` restores. **Not** tracked for bash `rm`/`mv`. |
| **CLAUDE.md** | Markdown, user/project | You write; Claude reads at session start. Soft rule, always in context. |
| **Auto-memory** | `~/.claude/projects/<proj>/memory/MEMORY.md` | Claude writes itself. First 200 lines auto-loaded. **Machine-local** — doesn't sync across Macs. |
| **Skill** | `SKILL.md` (+ optional files) | On-demand playbook. Loads when invoked or when Claude sees a match. |
| **Subagent** | `~/.claude/agents/<name>.md` | Forked context window for side tasks (explore, review). Parent only sees the summary. |

### Permission modes (Shift+Tab cycles them)

The mode sets the baseline — what runs without asking. Layer per-tool `allow` / `deny` rules in `/permissions` on top.

| Mode | What runs without asking | When to use |
|---|---|---|
| `default` | Reads only | New task, sensitive work, "I want to review each edit" |
| `acceptEdits` | Reads + file edits + `mkdir` / `touch` / `mv` / `cp` / `rm` / `sed` | Iterating on code you'll review afterward via `git diff` |
| `plan` | Reads only, **no edits** — Claude proposes a plan then stops | Exploring before changing. Claude delegates research to the **Plan** subagent. |
| `auto` | Everything, with a classifier blocking escalations | Long autonomous tasks (requires Max/Team/Ent plan + Sonnet 4.6 / Opus 4.6+) |
| `dontAsk` | Only `allow`-listed tools + read-only bash | Locked-down CI / scripted runs |
| `bypassPermissions` | Everything (except protected paths) | **Isolated VMs only.** Started with `--dangerously-skip-permissions`. |

**Protected paths** are *never* auto-approved in any mode: `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `agents`, `skills`, `worktrees`), `.gitconfig`, `.zshrc`, `.mcp.json`, `.claude.json`.

### Keyboard shortcuts — the actually-useful subset

| Keys | What it does |
|---|---|
| `Shift+Tab` | **Cycle permission mode** (default → acceptEdits → plan → auto*) |
| `Esc` | Interrupt current turn / cancel menu |
| `Esc` `Esc` | **Rewind / checkpoint menu** — restore code, conversation, or both to an earlier prompt |
| `Ctrl+O` | Toggle transcript viewer (see every tool call + its result) |
| `Ctrl+G` | Open external editor for the prompt (multi-paragraph prompts) |
| `Ctrl+T` | Toggle task-list panel |
| `Ctrl+R` | Reverse-search prompt history |
| `Ctrl+B` | Background the current bash command (tmux users press twice) |
| `Ctrl+X Ctrl+K` | Kill all background agents (press twice in 3s to confirm) |
| `Ctrl+V` / `Cmd+V` | Paste image — becomes an `[Image #N]` chip you can reference |
| `\` + `Enter` | Multiline input (works everywhere; `Shift+Enter` works in Ghostty/iTerm2/WezTerm/Kitty) |
| `/` at start | Slash-command / skill picker |
| `!` at start | **Bash mode** — run a shell cmd directly and add output to context |
| `@` | File-path autocomplete — pull a file into the conversation |
| `#` (followed by text) | Add to CLAUDE.md / auto-memory via prompt |

`*` auto only appears in the cycle if your plan supports it.

### Slash commands — researcher's pick-list

Type `/` for the full menu. The ones that actually earn their keystrokes for our use case:

**Session management**
- `/clear` (= `/reset`, `/new`) — new conversation, old one still resumable
- `/resume` / `/continue` — open session picker (or pass an ID)
- `/branch [name]` — fork current conversation at this point
- `/rewind` — same as `Esc` `Esc` (checkpoint menu)
- `/compact [focus]` — summarize conversation to free context; optionally give focus hints
- `/context` — visualize what's eating the context window
- `/diff` — interactive diff viewer (git diff + per-turn diffs)

**Modes & effort**
- `/plan [description]` — enter plan mode directly
- `/effort low|medium|high|xhigh|max|auto` — session-level thinking budget
- `/fast` — toggle fast Opus 4.6 (2.5× faster, higher $ — use for interactive iteration)
- `/model` — pick a model; for models that support effort, arrows adjust it
- `/permissions` — add/remove allow/ask/deny rules interactively

**Skills & agents**
- `/skills` — list all skills (`t` sorts by token cost)
- `/agents` — list/create/edit subagents
- `/hooks` — view all configured hooks

**Bundled skills — researcher gold**
- `/claude-api` — load Claude API reference for your language (Python/TS/…) + Managed Agents reference. Auto-activates when you import `anthropic`. Huge for a researcher writing against the API.
- `/simplify [focus]` — spawn 3 parallel review agents on your recently-changed files, aggregate, apply fixes
- `/debug [description]` — turn on debug logging, troubleshoot issues
- `/review [PR]` — local PR review
- `/security-review` — scan pending changes for injection / auth / data-exposure risks
- `/loop [interval] [prompt]` — run prompt repeatedly; omit interval and Claude self-paces. Killer for monitoring long experiments.
- `/fewer-permission-prompts` — scan your transcript, allowlist common read-only bash calls you've been re-approving

**Introspection**
- `/status` — version, model, account, which settings source wins each field
- `/doctor` — diagnose install + config (`f` auto-fixes)
- `/cost` — token usage so far
- `/insights` — analyze your last 30 days of sessions (friction points, favorite models)
- `/stats` — daily-usage graph
- `/recap` — one-line session summary

**External**
- `/mcp` — MCP server connections
- `/plugin` — marketplace browser
- `/export [file]` — dump conversation as plain text
- `/copy [N]` — copy Nth-latest assistant response (with code-block picker)
- `/btw <q>` — quick side question using current context, **doesn't enter conversation history**

### Plan mode — when to reach for it

Workflow: `Shift+Tab` until "plan" → describe the task → Claude researches (delegating to the **Plan** subagent for reads) → proposes a plan → you pick:

1. **Approve + auto** — execute hands-off (if `auto` is available)
2. **Approve + accept edits** — execute, skip edit prompts
3. **Approve + manual** — execute, prompt each edit
4. **Keep planning with feedback** — iterate
5. **Refine with Ultraplan** — browser-based multi-agent review (requires subscription)

Each approval option also offers to **clear the planning context first** — useful when the research phase bloated context but the implementation is small.

For big refactors, the "plan then acceptEdits" flow is the sweet spot: you review the plan (cheap, focused) instead of reviewing every edit (expensive, noisy).

### Subagents — the actually-often-used feature

Subagents = forked context windows. You get the summary; the main conversation doesn't see the search results.

**Built-ins, always available:**

| Agent | Model | Tools | When it fires |
|---|---|---|---|
| **Explore** | Haiku | Read-only | Claude delegates when it needs to search/understand code without changing it. Thoroughness levels: `quick`/`medium`/`very thorough`. |
| **Plan** | Inherits | Read-only | Plan mode's research helper. Prevents infinite nesting. |
| **general-purpose** | Inherits | All | Complex multi-step work that needs both exploration and action. |
| **statusline-setup** | Sonnet | — | Runs when you invoke `/statusline`. |
| **Claude Code Guide** | Haiku | — | Answering questions about Claude Code itself. |

**Explore is the single most useful feature for reading a new codebase or paper repo.** Ask "how does the training loop work in this repo?" — Claude fires Explore, gets back a summary in one reply, and your main conversation stays clean.

**Custom subagents** live at `~/.claude/agents/<name>.md`. Create via `/agents` (interactive, can "Generate with Claude") or by hand — it's just Markdown + YAML frontmatter:

```markdown
---
name: paper-reader
description: Read an ML paper PDF/repo and summarize the method, novelty, and limitations. Use when the user drops a paper URL or asks "what's new in this paper?"
tools: Read, Grep, Glob, WebFetch
model: sonnet
---

When reading a paper:
1. Method: one paragraph, equations inline
2. Novelty: what's different from the closest prior work?
3. Limitations: what the authors didn't say but a reviewer would
4. Reproducibility: does the repo match the paper?
```

Store at `~/.claude/agents/paper-reader.md` → available in every project. Invoke: `Use the paper-reader agent to summarize …`.

`/agents` → "Running" tab shows active subagents; you can open one's transcript or stop it.

### Agent Teams — for parallel debate (experimental)

`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` unlocks it. Multiple independent Claude sessions with a shared task list; teammates can **message each other** (subagents can't). The lead synthesizes.

Researcher scenarios where this earns the token cost:

- **Competing-hypothesis debugging**: "5 teammates investigate different hypotheses for why loss diverges at step 8k. Talk to each other to disprove theories. Update the findings doc with whatever consensus emerges."
- **Parallel review**: "Review PR #142 — security teammate, performance teammate, test-coverage teammate. Each reports separately."
- **Multi-angle design**: "CLI design — one teammate on UX, one on architecture, one playing devil's advocate."

Rules of thumb: 3–5 teammates, 5–6 tasks each, start with research/review (not implementation — file conflicts). Token cost scales linearly, so use when parallel exploration genuinely beats sequential.

### Skills — what's bundled, what to write

**Bundled skills** ship with Claude Code; same `/` namespace as your own. Worth knowing by heart: `/claude-api`, `/simplify`, `/debug`, `/loop`, `/review`, `/security-review`, `/init` (bootstrap a CLAUDE.md), `/team-onboarding` (generate an onboarding doc from your last 30 days).

**Custom skills** live at `~/.claude/skills/<name>/SKILL.md` (user-level) or `.claude/skills/…` (project-level). Frontmatter controls who can invoke + what tools are pre-approved:

```yaml
---
name: benchmark-run
description: Run the benchmark suite, capture wall-clock + peak memory, format as a table
disable-model-invocation: true   # only I can invoke, not Claude
allowed-tools: Bash(python bench/*.py)  Bash(/usr/bin/time *)
argument-hint: [config-file]
---

Run `python bench/run.py $ARGUMENTS`, capture stderr from /usr/bin/time,
emit a markdown table with columns: config, wall_s, peak_rss_mb, tokens/s.
```

`disable-model-invocation: true` is the killer field for skills that have **side effects** (deploy, benchmark, send-slack) — Claude won't silently trigger them. `user-invocable: false` is the inverse, for background knowledge Claude should know but you'd never type `/` to pull up.

### Headless mode — Claude Code as a shell tool

`claude -p "…"` runs non-interactively. Useful for:

```bash
# Review a diff in CI
gh pr diff 123 | claude -p --append-system-prompt "Security reviewer. Flag injection, authz, secrets." --output-format json

# Auto-commit staged changes
claude -p "Review staged changes and create a commit" --allowedTools "Bash(git diff *),Bash(git commit *)"

# Extract structured data
claude -p "List function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}}}' \
  | jq '.structured_output.functions'

# Same result on every machine (skip auto-discovery):
claude --bare -p "Summarize this paper" --allowedTools "Read"
```

`--bare` is the recommended mode for scripts: no CLAUDE.md / hooks / plugins / MCP / auto-memory. Reproducible. Combine with `--append-system-prompt-file` to keep the prompt under version control.

### Researcher playbook — scenarios that earn their keep

**1. Reading a new paper's repo.** Open Claude Code in the repo. First prompt: `Use the Explore agent (very thorough) to map the training pipeline: how data is loaded, how losses are composed, what the eval setup is. Return a markdown outline with file:line refs.` Your main context stays clean, you get a navigable outline.

**2. Debugging a flaky training run.** `/plan the root cause of the NaN at step 8k`. Claude (in plan mode) reads log files, config, model code — read-only, doesn't touch anything. Presents 2–3 hypotheses. You pick one, hit "Approve + accept edits", it implements the fix.

**3. Big refactor across 20 files.** Plan mode → review the plan → "Approve + acceptEdits" → let it run. Use `Esc` `Esc` (`/rewind`) if it derails mid-way. `git diff` at the end is your review surface.

**4. Long experiment watcher.** `/loop 10m check if training crashed or loss hit target; if so, commit and post to slack`. Or without an interval: `/loop` lets Claude self-pace. Useful for "wake me when it's done" workflows.

**5. Learning the Claude API itself.** `/claude-api` loads the Python reference for your language — tool use, streaming, batches, structured outputs, pitfalls. Then ask: `write a minimal agent that uses tool_choice: any and handles rate-limit retries`.

**6. Frontend you can't debug.** Let auto-memory accumulate ("last session we found the Tailwind class conflict was actually from the purge list"). Use `Esc` `Esc` liberally — if an edit broke the UI, rewind to the last-known-good and try a different approach. Couple with `/simplify` after a session to clean up code the model left messy.

**7. PR review you'd delegate to a colleague.** `/review <PR#>` for a local pass; `/ultrareview <PR#>` for a deeper cloud-based multi-agent pass (3 free on Pro/Max, then billed). Or spin up an Agent Team: "3 reviewers — security, performance, tests — each reports findings."

**8. Data pipeline scripts.** `acceptEdits` mode + `claude -p --bare` for scripts you want to re-run identically. Pre-approve `Bash(python …)` + `Bash(head|wc|ls …)` in project settings so the loop doesn't pause on every tool call.

### Costs / throttles / escape hatches

- `/cost` shows token usage for the session; `/usage` shows plan quota; `/stats` is the dashboard.
- `/fast` is 2.5× faster but also 2.5× the cost per token and eats **extra usage**, not plan quota. Toggle off for long unattended runs.
- `/effort low` vs `xhigh` — lower = less thinking time = faster/cheaper = maybe wrong on hard tasks. Our default is `xhigh` (pinned). Drop to `medium` for throwaway tasks via `/effort`.
- Hit a wall? `/compact [focus]` summarizes the conversation (keeps CLAUDE.md + rules). `/rewind` can restore to a pre-bloat point. `/clear` nukes and starts fresh.

---

## Change a setting

1. Edit `dot_claude/settings.json`.
2. `chezmoi diff ~/.claude/settings.json` — review the rendered diff.
3. `chezmoi apply ~/.claude/settings.json`.
4. Add a regression guard in `tests/claude.sh` under **Pinned settings fields** if the new value is something we care about keeping.
5. Restart Claude Code (`Ctrl+D` / exit, re-launch) — most settings are read at startup only.

## Health check

### Automated

```bash
bash tests/claude.sh
```

~43 checks: binary presence (`claude`, `bun`, `npx`, `node`, `ccusage`), source + target JSON validity, every pinned field (4 enabled plugins + 4 marketplaces + statusLine + PreToolUse + syntax + effort), all `.chezmoiignore` runtime exclusions (incl. `dot_claude.json` defensive guard), plugin-cache populated for all 4 plugins, smoke for `claude --version` + `npx block-no-verify` resolution.

### Manual

- [ ] `claude --version` runs cleanly
- [ ] `claude` launches interactively, statusLine renders (claude-hud bun output)
- [ ] `/hooks` lists the PreToolUse Bash hook + all plugin hooks, zero "command not found" errors
- [ ] `/status` shows `~/.claude/settings.json` as the source for `effortLevel: xhigh` and `syntaxHighlightingDisabled: true`
- [ ] Attempting `git commit --no-verify` inside a Claude session is blocked by the PreToolUse hook
- [ ] `/plugin list` shows `claude-hud`, `codex`, `andrej-karpathy-skills`, `chrome-devtools-mcp` all enabled
- [ ] `ccusage daily` prints a usage table without errors (reads `~/.claude/projects/**/*.jsonl`)
- [ ] On the **other** machine after `chezmoi apply`: the same six fields are present in `~/.claude/settings.json`

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `claude: command not found` | Claude Code not installed | `bootstrap.sh` runs the installer; one-off: `curl -fsSL https://claude.ai/install.sh \| bash` |
| `statusLine` is blank | `claude-hud` plugin not installed yet (empty `~/.claude/plugins/cache/claude-hud/`) | `claude plugin install claude-hud@claude-hud`, then restart |
| `statusLine` fails with `bun: No such file` | `bun` missing from `/opt/homebrew/bin/bun` | Currently installed as a Claude Code dependency; if absent, `brew install oven-sh/bun/bun` |
| PreToolUse hook: `node: command not found` or `npx: command not found` | `node` missing (Phase 2 fix regression) | `brew bundle` — Brewfile declares `node`. Root cause check in `docs/brewfile.md`. |
| Plugin `.mjs` hooks all fail at session start | `node` missing (same as above) — `openai-codex` lifecycle hooks shell out to `node` | Same fix: `brew bundle` |
| `syntaxHighlightingDisabled: true` seems ignored | A newer Claude Code release changed the key name | Check upstream [settings reference](https://code.claude.com/docs/en/settings) — this is an area actively evolving |
| Auto-memory growing huge | Per-project `~/.claude/projects/<proj>/memory/MEMORY.md` > 200 lines → content beyond the threshold stops auto-loading | Run `/memory`, prune, or let Claude offload to topic files |
| `chezmoi apply` tries to create `~/.claude/sessions/` / `~/.claude/cache/` | An ignore pattern was deleted | Restore it in `.chezmoiignore` — `tests/claude.sh` will flag which |

## Gotchas

- **`enabledPlugins` is declarative, not a vendor.** Wiping `~/.claude/plugins/` and re-launching re-downloads from the marketplaces. First launch on a fresh Mac needs network to GitHub.
- **`statusLine` hard-codes `/opt/homebrew/bin/bun`.** Fine on Apple Silicon (both our Macs). Would break on Intel or Linux — a future `dot_claude/settings.json.tmpl` could use `{{ env "HOMEBREW_PREFIX" }}` or expand `$(command -v bun)` if this ever ships cross-arch.
- **Don't `chezmoi add ~/.claude`.** It recurses into runtime subdirs — the `.chezmoiignore` blocks most, but adding whole-dir can still surprise. Add individual files instead (`chezmoi add ~/.claude/settings.json`).
- **`~/.claude/settings.local.json` is never tracked** but chezmoi also never manages it, so editing it locally is safe — it's entirely out of band.
- **Auto-memory is machine-local.** If you've been building up good MEMORY.md entries on the work Mac, they don't follow you home. That's by design ([upstream docs](https://code.claude.com/docs/en/memory#storage-location)); if you want cross-machine rules, write them into `~/.claude/CLAUDE.md` and version *that* in a future phase.
- **The old `includeCoAuthoredBy` key is deprecated.** Not in our settings today. When we do need commit attribution control, use the newer `attribution` object — covered in the 2026 settings docs.

## Rebuild from scratch

If `~/.claude/settings.json` gets clobbered:

```bash
chezmoi apply ~/.claude/settings.json
```

If plugin cache rots (wrong versions, partial installs):

```bash
rm -rf ~/.claude/plugins
# Restart Claude Code — enabledPlugins + extraKnownMarketplaces trigger a refetch.
```

If auto-memory gets confused (wrong or outdated entries for *this* project):

```bash
rm -rf ~/.claude/projects/<proj>/memory
# Claude starts fresh, will re-accumulate. Safe because it's per-machine anyway.
```

---

## Related

- [`claude-plugins.md`](claude-plugins.md) — per-plugin / per-MCP / per-skill usage, bundled-skill reference, how to add custom skills/agents, and the internal-vs-external split
- [`Brewfile`](../Brewfile) — `node` + `ccusage` are declared there; the inline comments cover why
- [Claude Code settings reference](https://code.claude.com/docs/en/settings)
- [Claude Code hooks reference](https://code.claude.com/docs/en/hooks)
- [Claude Code memory reference](https://code.claude.com/docs/en/memory)
