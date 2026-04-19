# Claude Code extensions — plugins · MCP · skills

> English · [中文](claude-plugins.zh.md)

This is the per-extension reference. The overall settings model (what's pinned, why, how chezmoi renders it) is in [`claude.md`](claude.md); this doc answers *"what does each piece actually do, and when would I reach for it?"*

Scope: **cross-machine, publishable extensions only.** Anything that ships with a token, an internal URL, or work-laptop-only credentials belongs per-user in `~/.claude.json` (which we `.chezmoiignore` on purpose) — not here.

## Extension model at a glance

Four mechanisms, often confused:

| Mechanism | Declared where | Lives at | What it adds | Who invokes |
|---|---|---|---|---|
| **Plugin** | `settings.json` → `enabledPlugins` | `~/.claude/plugins/cache/<mp>/<plugin>/<ver>/` | A *bundle* — any mix of commands / skills / subagents / hooks / MCP servers. Resolved via a `marketplace`. | Depends on each bundled item |
| **MCP server** | `~/.claude.json` (project) or `settings.json` (user), or bundled inside a plugin | Out-of-process; Claude spawns and talks JSON-RPC | Tool functions (`mcp__<server>__<tool>`) | Claude auto-discovers; you pre-approve per session |
| **Skill** | YAML frontmatter (`name`, `description`) | `~/.claude/skills/<name>/SKILL.md`, or inside a plugin's `skills/` | On-demand playbook, loaded when Claude matches the description or user types `/<name>` | Claude (auto) or user — controlled via frontmatter |
| **Subagent** | YAML frontmatter (`name`, `tools`, `model`) | `~/.claude/agents/<name>.md`, or inside a plugin's `agents/` | Forked context window that runs tools and returns a summary | Claude delegates; user can name it explicitly |

A plugin can ship any mix of the other three. So when reading the table below, think of a plugin as "shipping format"; the *useful surface* is always some combination of commands, skills, subagents, or MCP tools.

---

## Plugins (4 declared — all external)

Pinned in `dot_claude/settings.json`. `chezmoi apply` + first Claude launch on a fresh Mac triggers the marketplace fetcher; no per-plugin install command needed.

### `claude-hud@claude-hud`

**What**: the bun-based `statusLine` backend — the thing our pinned `statusLine` field execs. Renders the little status strip at the bottom of Claude Code showing context usage, active subagents, current permission mode.

**Ships**:
- `/claude-hud:configure` — open the HUD config UI
- `/claude-hud:setup` — one-time setup (statusLine wiring)

**Upstream**: <https://github.com/jarrodwatts/claude-hud>

**When**: always on — it's the `statusLine` itself. The `/claude-hud:*` commands are only useful if you want to tweak what it shows.

**Cache folder**: `~/.claude/plugins/cache/claude-hud/claude-hud/<semver>/` — `tests/claude.sh` picks the highest-versioned directory at runtime (see `statusLine` in `dot_claude/settings.json`).

### `codex@openai-codex`

**What**: brings OpenAI Codex into Claude Code as a second-opinion engine. Hand off a substantial coding task, an investigation, or a "check my work" pass — Codex runs in a separate context and reports back.

**Ships**:
- `/codex:setup` · `/codex:status` · `/codex:cancel` — lifecycle
- `/codex:review` — Codex reviews a diff or file range
- `/codex:rescue` — delegate a stuck task to Codex
- `/codex:result` — read back the latest Codex run's output
- `/codex:adversarial-review` — Codex argues *against* your approach to stress-test it
- **Subagent**: `codex:codex-rescue` — auto-delegate target when Claude is stuck
- **Skills**: `codex-cli-runtime` · `codex-result-handling` · `gpt-5-4-prompting` (internal helpers; auto-loaded)
- **Hooks**: `.mjs` SessionStart / SessionEnd / Stop — shell out to `node` (Brewfile declares it)

**Upstream**: <https://github.com/openai/codex-plugin-cc>

**When**:
- Claude has iterated twice on the same bug and isn't converging → `/codex:rescue`
- You want an independent review of a nontrivial change before you ship → `/codex:adversarial-review`
- You're stuck in "am I missing something obvious" → `/codex:review` on the file
- `codex:codex-rescue` fires automatically if Claude's runtime guidance matches the agent's proactive trigger — no typing needed

### `andrej-karpathy-skills@karpathy-skills`

**What**: a single skill packaging Karpathy's [behavioral guidelines](https://github.com/karpathy/claude-guidelines) for LLM coding — think-before-acting, root-cause over patch, don't-add-layers, etc. The skill loads when Claude detects a pattern that matches the guidelines (e.g. you're about to add an abstraction when the user asked for a fix).

**Ships**:
- Skill: `karpathy-guidelines` (auto-invoked by Claude when matched)

**Upstream**: <https://github.com/forrestchang/andrej-karpathy-skills>

**When**: passive. Useful for dotfiles / one-shot tasks where you want the model to stay disciplined about scope. Turn off via `/skills` if you're doing an intentional architecture pass and the "don't-add-abstractions" nudge gets in the way.

### `chrome-devtools-mcp@claude-plugins-official`

**What**: an MCP server packaged as a plugin — wraps the Chrome DevTools Protocol so Claude can drive and **diagnose** a live Chrome instance. Navigate pages, evaluate JS, record network / performance traces, read console logs with source-mapped stack traces, emulate CPU / network throttling.

This is the **runtime-debug** layer: claude-in-chrome (DOM) and computer-use (pixels) let Claude *interact* with Chrome; this lets Claude *investigate* Chrome.

**Ships**: a large set of `mcp__chrome__*` tools (navigate, new_page, evaluate, screenshot, get_console, get_network, list_pages, performance_start/stop, emulate_cpu/network, fill_form, click, etc.). Claude auto-discovers them — no commands / skills to memorize.

**Upstream**: <https://github.com/ChromeDevTools/chrome-devtools-mcp>

**When** (mapped to our researcher profile):
- **Generated a web UI with Claude but it's broken** — "check the console on http://localhost:5173, pull stack traces, tell me what's failing". Before: you open DevTools, paste errors. Now: Claude does the round-trip itself.
- **Slow page**: "record a performance trace on http://localhost:5173/dashboard and tell me what's blocking the main thread." Claude sets up the profile, reads the trace, reports Long Tasks / layout thrash / huge JS eval.
- **Network failure**: "why is POST /api/foo returning 500?" — Claude inspects request/response headers + body directly.

**Cache folder**: `~/.claude/plugins/cache/claude-plugins-official/chrome-devtools-mcp/latest/` (note: `latest/`, not semver — this plugin's marketplace entry fetches from a Git URL rather than a release tag).

---

## MCP servers (beyond what plugins ship)

Besides `chrome-devtools-mcp` (declared above as a plugin), three more MCP surfaces are relevant:

### `computer-use` (ambient, Anthropic-built-in)

**What**: native desktop control + screenshot. Comes with the Claude Code desktop app — no `mcpServers` entry needed, no install.

**Surface**: `mcp__computer-use__*` — `screenshot`, `left_click`, `type`, `key`, `scroll`, `request_access`, `list_granted_applications`, `zoom`, etc.

**Tiering**: apps are restricted by category. Browsers are `read` tier (visible, no clicks/typing), terminals + IDEs are `click` tier (clickable, no typing), everything else `full`. The error message tells you the tier when you hit it. For browsers, `claude-in-chrome` below is the right tool.

**When**: native apps (Finder, Notes, Maps, System Settings, third-party apps); cross-app workflows; or as the **pixel-level fallback** when DOM reads fail — see the 1+3 workflow below.

### `claude-in-chrome` (Chrome Web Store extension)

**What**: the Claude for Chrome browser extension. DOM-aware navigation, clicking, form-filling — much faster and more precise than pixel-level mouse-moves for web apps.

**Surface**: `mcp__claude-in-chrome__*` — tools for page reads, clicks, typing, etc.

**Install**: Chrome Web Store → "Claude for Chrome" (not an MCP server in `.claude.json`; onboarding state is in `~/.claude.json` flags like `hasCompletedClaudeInChromeOnboarding`). No chezmoi wiring possible — browser extensions can't be versioned here.

**When**: DOM-level work in any website. First-choice for browser automation; fall back to computer-use only when permissions or missing DOM fields block you.

### The 1+3 workflow (DOM-first, pixel-fallback)

When a browser page's content isn't readable via DOM (permission walls, redirect gates, empty / redacted fields, cross-origin iframes), don't stop and ask for access immediately — the pixels may still be there. Order:

1. Try `mcp__claude-in-chrome__*` first — fast, structured
2. Empty / permission-denied result? Don't stop yet
3. `mcp__computer-use__screenshot` (after `request_access` confirms Chrome is on the allowlist) — maybe the pixels rendered even though the DOM is empty
4. `zoom` on small text before giving up
5. **Only then** ask the user for access

Some pages visually render content that DOM reads can't see; the pixel fallback bypasses the DOM/API layer entirely.

### `chrome-devtools-mcp` recap

Third-tier browser surface: debugging the *runtime*, not navigating the page. Installed as a plugin (see above). When Claude needs console / network / performance insight, it reaches here — not claude-in-chrome.

### Per-user MCPs (not in this repo)

Any MCP that carries a token, points at an internal network, or is otherwise machine-specific is installed per-user with `claude mcp add`. The config lands in `~/.claude.json` — defensively ignored as `dot_claude.json` in `.chezmoiignore`, so secrets and per-machine configs can't leak into this repo.

---

## Skills — bundled inventory + how to add your own

### What's loaded by default (no declaration needed)

Built into Claude Code proper (worth knowing by name):

- `/claude-api` — Claude API reference loader (Python / TS). Auto-fires when you `import anthropic` in a file.
- `/simplify [focus]` — parallel review agents on recent changes, aggregate, apply fixes
- `/debug [description]` — debug-logging + investigation walkthrough
- `/review [PR#]` — local PR review
- `/security-review` — scan pending changes for injection / authz / data-exposure
- `/loop [interval] [prompt]` — repeat prompt, self-paced if no interval
- `/init` — bootstrap a `CLAUDE.md`
- `/team-onboarding` — generate onboarding doc from last 30 days of sessions

### From plugins above

| Skill | From | Auto-invoke? |
|---|---|---|
| `karpathy-guidelines` | `andrej-karpathy-skills` | Yes — when Claude detects anti-patterns |
| `codex-cli-runtime` | `codex` | Auto — internal helper for Codex delegation |
| `codex-result-handling` | `codex` | Auto — parses Codex output |
| `gpt-5-4-prompting` | `codex` | Auto — when formatting prompts for Codex |

`/skills` lists everything currently loaded, with token costs (`t` to sort).

### Writing your own

User-level custom skills go at `~/.claude/skills/<name>/SKILL.md`. Currently our `dot_claude/skills/**` is defensively ignored in `.chezmoiignore` — delete that line before opting a skill into the repo.

Minimal shape:

```markdown
---
name: benchmark-run
description: Run the benchmark suite, capture wall-clock + peak memory, format as a markdown table
disable-model-invocation: true   # only the user can invoke; Claude can't silently trigger
allowed-tools: Bash(python bench/*.py) Bash(/usr/bin/time *)
argument-hint: [config-file]
---

Run `python bench/run.py $ARGUMENTS`, capture stderr from /usr/bin/time,
emit a markdown table with columns: config, wall_s, peak_rss_mb, tokens/s.
```

Two knobs matter:
- **`disable-model-invocation: true`** — for side-effectful skills (deploy, benchmark, send-slack). The model can't trigger them; you type `/<name>` explicitly.
- **`user-invocable: false`** — inverse: background knowledge the model should load in context automatically but that'd never be typed as a slash command (e.g. a project's invariants).

For skills that shell out to usage data, `ccusage` (declared in `Brewfile`) reads `~/.claude/projects/**/*.jsonl` and emits day/week/month/session tables — stable input for anything that needs token-usage numbers.

---

## Subagents & commands — pointers

Both mechanisms are covered in [`claude.md`](claude.md) → "Using Claude Code effectively" — `/agents`, custom subagent template, built-in Explore / Plan / general-purpose, Agent Teams. Commands are declared similarly (Markdown + YAML frontmatter at `~/.claude/commands/<name>.md`, or bundled inside a plugin's `commands/` dir).

Both `dot_claude/agents/**` and `dot_claude/commands/**` are defensively ignored in `.chezmoiignore` — opt in by deleting the ignore entry when you have something worth versioning.

---

## Adding a new extension — which mechanism?

Decision order:

1. **Is it a published plugin?** → add to `enabledPlugins` + register marketplace in `extraKnownMarketplaces`. Cheapest, auto-updates via marketplace SHA.
2. **Is it a third-party MCP server?** → `claude mcp add`. Saves to `~/.claude.json` (machine-local by design — holds tokens). If the config is token-free, consider an `.mcp.json` at project root that *is* cross-machine.
3. **Is it a prompt pattern you want on-tap?** → skill. `~/.claude/skills/<name>/SKILL.md`.
4. **Is it a tool-wielding background worker?** → subagent. `~/.claude/agents/<name>.md`.
5. **Is it a one-off slash command?** → command. `~/.claude/commands/<name>.md`.

For each, ask "does this belong in the public repo?":
- Cross-machine, no secrets → yes, version it. Delete the corresponding `.chezmoiignore` entry first.
- Carries a token / internal URL / machine-specific state → no. Keep it per-user in `~/.claude.json` (for MCPs) or the relevant runtime dir.

---

## Rebuild / troubleshoot

**Plugin cache rot (wrong versions, stale fetch):**
```bash
rm -rf ~/.claude/plugins
# Restart Claude Code — enabledPlugins + extraKnownMarketplaces re-fetch from GitHub.
```

**`chrome-devtools-mcp` tools missing on the second Mac after `chezmoi apply`:**
- Check `~/.claude/plugins/cache/claude-plugins-official/chrome-devtools-mcp/latest/` exists — if not, launch Claude once; the marketplace fetcher resolves `enabledPlugins`.
- Puppeteer needs a Chrome binary on first use; `npx puppeteer browsers install chrome` if it errors out trying to launch. We don't Brewfile-declare this — it's a lazy one-time cost.

**`ccusage daily` fails** after a fresh install:
- It reads `~/.claude/projects/**/*.jsonl`. On a fresh Mac there's nothing to read → empty table is correct. Use Claude once, retry.

**`computer-use` tool calls blocked:**
- `request_access` must be called with the app list first; the user approves each. Tier restrictions (browsers: read-only, terminals: click-only) are by category — the error response says which tier hit.

**Per-user MCP not loading:**
- `claude mcp list` reports health per server. Most failures are token expiry or the server's upstream (registry / endpoint) unreachable from the current network. The config is in `~/.claude.json` under `projects.<cwd>.mcpServers` — not in this repo.

---

## Related

- [`claude.md`](claude.md) — settings / hooks / permission modes / keyboard shortcuts / researcher playbook
- [`Brewfile`](../Brewfile) — `ccusage`, `node` declared here with rationale
- [Claude Code plugin reference](https://code.claude.com/docs/en/plugins)
- [Claude Code MCP reference](https://code.claude.com/docs/en/mcp)
- [Claude Code skills reference](https://code.claude.com/docs/en/skills)
- [Claude Code subagents reference](https://code.claude.com/docs/en/subagents)
