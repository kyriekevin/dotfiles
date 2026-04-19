# Claude Code

> [English](claude.md) · 中文

跨机 Claude Code 配置：**只管 `~/.claude/settings.json` 一份。** `~/.claude/` 下其他内容 —— sessions、auto-memory、插件缓存、session-env、日志、allowlist —— 都是本机 runtime 状态，**故意排除**（见 `.chezmoiignore`）。

每个 plugin / MCP / skill 的详细用法放在 [`claude-plugins.zh.md`](claude-plugins.zh.md)；本文件只管 settings 主干。

## 运作方式

| 源（repo） | 目标（`$HOME`） | 行为 |
|---|---|---|
| `dot_claude/settings.json` | `~/.claude/settings.json` | 普通拷贝。不用模板 —— 当前所有字段都跨机通用。 |
| _（排除）_ | `~/.claude/settings.local.json` | 项目级 permission allowlist；全是本机特有路径。 |
| _（排除）_ | `~/.claude/sessions/` `projects/` `plans/` `cache/` `…` | 纯运行时 —— 见下文 **Runtime 排除**。 |

`chezmoi apply` 把 `dot_claude/settings.json` 渲染到 `~/.claude/settings.json`。没有 hook 脚本，没有插件重装 —— `enabledPlugins` 只是声明意图，Claude 自己的 marketplace fetcher 在下次启动时会拉取。

## 两种持久化机制（为什么只管一种）

Claude Code 有**两套**跨 session 的记忆机制。repo 里只 version 第一套：

| | **Settings** (`settings.json`) | **Memory** (`CLAUDE.md` + auto-memory) |
|---|---|---|
| 写入方 | 你，声明式 JSON | 你写 `CLAUDE.md`；Claude 写 auto-memory |
| 约束强度 | 硬 —— `deny` 规则和 hooks 能拦截 tool 调用 | 软 —— 以 user message 注入上下文，不强制 |
| 跨机共享 | 是（只要进 repo） | **否 —— auto-memory 按[官方文档](https://code.claude.com/docs/en/memory#storage-location)就是 machine-local** |
| 我们的 repo | `dot_claude/settings.json` | 暂未纳入；user-level `CLAUDE.md` 也还没 track |

第二套值得知道但**绝不能进 repo**：`~/.claude/projects/<proj>/memory/MEMORY.md` 是 per-working-tree 的产物，共享给另一台 Mac 会互相污染。

## 固定字段

`dot_claude/settings.json` 六个 key，全部跨机通用 —— 今天还不需要 `{{ if .is_work }}` 分支。

| 字段 | 值 | 为什么 pin |
|---|---|---|
| `$schema` | `json.schemastore.org/claude-code-settings.json` | 任何支持 JSON schema 的编辑器都能自动补全 + 即时校验，零运行时成本。 |
| `hooks.PreToolUse[Bash]` | `npx block-no-verify@1.1.2` | 拦截 `git commit --no-verify` / `git push --no-verify` —— 呼应 CLAUDE.md 里"绝不跳 hook"那条。 |
| `statusLine` | `bash -c '... bun … claude-hud/src/index.ts'` | 选最高版本的 claude-hud，用 bun 执行。硬编码 `/opt/homebrew/bin/bun` 在 Apple Silicon Mac 上没问题（咱两台都是）。 |
| `enabledPlugins` | 4 项 | `claude-hud`（状态 HUD）· `codex`（OpenAI Codex 生命周期 hooks）· `andrej-karpathy-skills`（技能包）· `chrome-devtools-mcp`（对活 Chrome 做前端 debug）。 |
| `extraKnownMarketplaces` | 4 个 GitHub 源 | 注册 `github:owner/repo` 类 marketplace，`enabledPlugins` 才能解析。新 Mac 首启必需。 |
| `syntaxHighlightingDisabled` | `true` | 回复高亮在 ghostty 偶发渲染 bug —— 关了，偏好纯文本。 |
| `effortLevel` | `"xhigh"` | Claude 的[思考预算](https://code.claude.com/docs/en/model-config#adjust-effort-level)。跑 `/effort` 会自动持久化；pin 住防止新 Mac 回退成 medium。 |

## Runtime 排除（为什么每个都 ignore）

`.chezmoiignore` 阻止以下内容进入源：

| 路径 | 内容 | 为什么不跨机 |
|---|---|---|
| `dot_claude/settings.local.json` | 项目级 Bash / WebFetch allowlist | 路径都是 `/Users/bytedance/...`，另一台 Mac 没用。条目还可能含机器特有的内网 URL / 凭据片段。 |
| `dot_claude/sessions/` | 每次跑 Claude 的 JSONL 对话记录 | 每天 MB 级增长。Resume 数据，不是配置。 |
| `dot_claude/projects/<proj>/memory/` | Claude 自己写的 auto-memory | 文档明确说**按设计就是 machine-local**。共享会让工作机 / 个人机互相污染。 |
| `dot_claude/plans/` | `/plan` 模式输出 | 工作产物，不是配置。本地 `0-1-dotfiles-*.md` plan 就放在这，每台机各有一份。 |
| `dot_claude/plugins/` | Marketplace 缓存 + 安装元数据 | 启动时根据 `enabledPlugins` + `extraKnownMarketplaces` 重建。包含常变的 `blocklist.json` 和 `install-counts-cache.json`。 |
| `dot_claude/cache/` `image-cache/` `paste-cache/` | 随机缓存 | — |
| `dot_claude/file-history/` `shell-snapshots/` | 撤销 / 命令历史 | Per-session；体积大。 |
| `dot_claude/tasks/` | 后台 subagent 输出 | Per-invocation。 |
| `dot_claude/telemetry/` `metrics/` `homunculus/` | 用量埋点 | Anthropic 内部 schema，机器特有。 |
| `dot_claude/session-data/` `session-env/` | 当前 session 环境快照 | Per-session。 |
| `dot_claude/chrome/` `downloads/` | 浏览器扩展缓存 | 本机。 |
| `dot_claude/*.jsonl` `*.log` `*-cache.json` | `history.jsonl`、`bash-commands.log`、`cost-tracker.log`、`stats-cache.json` | 日志和缓存。 |
| `dot_claude/agents/` `skills/` `commands/` `rules/` `CLAUDE.md` | **未使用的扩展点** | 当前都没内容。预先 ignore，防止误 `chezmoi add ~/.claude` 悄悄版本化未审查的东西。要纳入 repo 前先删这条 ignore。 |
| `dot_claude.json`（注意：`.claude.json`，**不在** `.claude/` 下） | 应用状态：`mcpServers{}` 条目（env 块里常带明文 API token / OAuth secret）、OAuth 账号、onboarding + feature-flag 缓存 | 本机 runtime + 活凭据。防御性 ignore —— `chezmoi add ~/.claude.json` 变 no-op。任何带 token 的 MCP 都用 `claude mcp add` per-user 配，留在这个文件里。 |

## Scope 速查（2026）

优先级由高到低，跟[官方文档](https://code.claude.com/docs/en/settings#settings-precedence)一致：

```
managed (MDM/server)     ← IT 管，不可覆盖
CLI flags                ← 单 session
.claude/settings.local.json (项目级，git 忽略)
.claude/settings.json       (项目级，入库共享)
~/.claude/settings.json     ← 我们管这层
```

所以 `dot_claude/settings.json` 是**优先级最低**的一层 —— 项目级 settings 永远胜过它。这是有意的：项目有权收紧权限或换模型而不被 `~/.claude/` 盖掉。

## Hooks 速览

Claude Code 现支持 **29 个生命周期事件** × **4 种 handler 类型**（`command` / `http` / `prompt` / `agent`）。我们只用一个：

- **PreToolUse, matcher=Bash** → `npx block-no-verify@1.1.2`。每次 Bash 工具调用前触发；非零退出码告诉 Claude 命令被拦截。

我们**故意不在 user 级配**的 hooks：

- 插件自带的 `.mjs` hooks（如 `openai-codex` 的 SessionStart/SessionEnd/Stop）住在 `~/.claude/plugins/cache/openai-codex/…/hooks/hooks.json` —— 插件自己安装，当 `enabledPlugins` 引用时生效。**我们不在 `settings.json` 里重复定义。**
- 项目级 hooks（如 PostToolUse 的 lint）属于该项目的 `.claude/settings.json`，不属于这里。

## 插件模型

`enabledPlugins` + `extraKnownMarketplaces` 是**声明**，不是 vendor。`~/.claude/plugins/` 空的情况下，Claude 会在下次启动重新拉取。

当前声明的四个插件 —— 每个插件的命令 / skills / 使用详见 [`claude-plugins.zh.md`](claude-plugins.zh.md)：

| 插件 | 提供 | Namespace |
|---|---|---|
| `claude-hud@claude-hud` | `statusLine` 后端（我们 `statusLine` 字段指向的 bun 脚本） | — |
| `codex@openai-codex` | `.mjs` SessionStart / SessionEnd / Stop hooks + `codex-rescue` subagent | `/codex:*` skills |
| `andrej-karpathy-skills@karpathy-skills` | 技能包 | `/karpathy-skills:*` skills |
| `chrome-devtools-mcp@claude-plugins-official` | 包装 Chrome DevTools Protocol 的 MCP server —— 对活 Chrome 做 console / network / performance trace | MCP tools（无 skill 命名空间） |

> **带 token / 受内网限制的 MCP** 不在本 repo 声明。每人用 `claude mcp add` 本地配 —— config 落到 `~/.claude.json`（我们已防御性 `.chezmoiignore`，secret 不会泄进来）。

---

## 高效使用 Claude Code

这一段是上面配置的"怎么实际用"伴读。本节所有功能都是 Claude Code **自带**的 —— 无需在咱 pin 的 6 个字段之外再做任何配置。内容抓自 2026 官方文档（Phase 6b 期间抓取）。

### 核心心智模型

| 概念 | 住在 | 什么时候想它 |
|---|---|---|
| **对话 / session** | `~/.claude/sessions/` | 一条聊天线。`/resume` 把某条接回来。`/clear` 开新的；旧的仍可 resume。 |
| **Context window** | 运行时内存 | Claude 这一轮能"看到"的所有东西。有限。`/context` 看谁在吃。 |
| **Checkpoint** | `~/.claude/file-history/` | 编辑前的文件快照。`Esc` `Esc` 或 `/rewind` 恢复。**不**追踪 bash 的 `rm`/`mv`。 |
| **CLAUDE.md** | Markdown, user / project | 你写；Claude 在 session 启动时读。软规则，始终在 context 里。 |
| **Auto-memory** | `~/.claude/projects/<proj>/memory/MEMORY.md` | Claude 自己写。前 200 行自动加载。**Machine-local** —— 不跨机同步。 |
| **Skill** | `SKILL.md`（+ 可选附件） | 按需加载的 playbook。被调用或 Claude 觉得相关时载入。 |
| **Subagent** | `~/.claude/agents/<name>.md` | 为侧任务 fork 的 context（探索、评审）。父 session 只看摘要。 |

### Permission 模式（Shift+Tab 循环）

模式设定 baseline —— 什么不问直接跑。在 `/permissions` 里按工具加 `allow` / `deny` 规则作为叠加层。

| 模式 | 不问直接跑的范围 | 什么时候用 |
|---|---|---|
| `default` | 只读 | 新任务 / 敏感工作 / "我想审核每次编辑" |
| `acceptEdits` | 读 + 文件编辑 + `mkdir` / `touch` / `mv` / `cp` / `rm` / `sed` | 迭代你会用 `git diff` 事后审的代码 |
| `plan` | 只读，**不编辑** —— Claude 提方案然后停 | 动手前先探索。Claude 把研究工作委托给 **Plan** subagent。 |
| `auto` | 所有操作，但分类器拦截升级动作 | 长时间自动任务（需要 Max / Team / Enterprise 方案 + Sonnet 4.6 / Opus 4.6+） |
| `dontAsk` | 只有 `allow` 列表里的工具 + 只读 bash | 锁死的 CI / 脚本 |
| `bypassPermissions` | 所有（除 protected paths） | **仅隔离 VM 用。** 启动时加 `--dangerously-skip-permissions`。 |

**Protected paths** 任何模式都**不会**自动批准：`.git`、`.vscode`、`.idea`、`.husky`、`.claude`（除 `.claude/commands`、`agents`、`skills`、`worktrees`）、`.gitconfig`、`.zshrc`、`.mcp.json`、`.claude.json`。

### 快捷键 —— 真正有用的那部分

| 按键 | 作用 |
|---|---|
| `Shift+Tab` | **切换权限模式**（default → acceptEdits → plan → auto*） |
| `Esc` | 中断当前 turn / 关闭菜单 |
| `Esc` `Esc` | **Rewind / checkpoint 菜单** —— 把代码、对话、或两者回滚到更早的 prompt |
| `Ctrl+O` | 切换 transcript viewer（看每次 tool 调用及其结果） |
| `Ctrl+G` | 外部编辑器打开 prompt（写多段长 prompt 用） |
| `Ctrl+T` | 切换 task-list 面板 |
| `Ctrl+R` | 反向搜索 prompt 历史 |
| `Ctrl+B` | 后台化当前 bash 命令（tmux 用户按两次） |
| `Ctrl+X Ctrl+K` | 杀光后台 agents（3s 内按两次确认） |
| `Ctrl+V` / `Cmd+V` | 粘贴图片 —— 变成可引用的 `[Image #N]` chip |
| `\` + `Enter` | 多行输入（到处能用；`Shift+Enter` 在 Ghostty / iTerm2 / WezTerm / Kitty 开箱即用） |
| `/` 开头 | Slash 命令 / skill 选择器 |
| `!` 开头 | **Bash 模式** —— 直接跑 shell 命令并把输出加入 context |
| `@` | 文件路径自动补全 —— 把文件拉进对话 |
| `#` 开头 | 通过 prompt 写入 CLAUDE.md / auto-memory |

`*` auto 只在你的方案支持时才出现在循环里。

### Slash 命令 —— 研究员精选

输入 `/` 看完整菜单。对咱这种使用场景真值得记住的：

**Session 管理**
- `/clear`（= `/reset`、`/new`）—— 新对话，旧的仍可 resume
- `/resume` / `/continue` —— 打开 session 选择器（或传 ID）
- `/branch [name]` —— 在当前位置分叉对话
- `/rewind` —— 等同于 `Esc` `Esc`（checkpoint 菜单）
- `/compact [focus]` —— 总结对话释放 context；可给 focus 提示
- `/context` —— 可视化当前 context window 被什么占满
- `/diff` —— 交互式 diff 查看器（git diff + 每轮 diff）

**模式与思考量**
- `/plan [description]` —— 直接进 plan 模式
- `/effort low|medium|high|xhigh|max|auto` —— session 级思考预算
- `/fast` —— 切换 fast Opus 4.6（快 2.5×，贵 —— 交互迭代用）
- `/model` —— 选模型；支持 effort 的模型可用左右键调
- `/permissions` —— 交互式增删 allow / ask / deny 规则

**Skills 与 agents**
- `/skills` —— 列所有 skills（`t` 按 token cost 排序）
- `/agents` —— 列 / 建 / 改 subagents
- `/hooks` —— 查看所有已配 hooks

**Bundled skills —— 研究员金矿**
- `/claude-api` —— 为你的语言（Python / TS / …）加载 Claude API 参考 + Managed Agents 参考。`import anthropic` 会自动触发。写 API 代码时超好用。
- `/simplify [focus]` —— 对最近改过的文件并行派 3 个 review agent，汇总，应用修复
- `/debug [description]` —— 开 debug 日志，排障
- `/review [PR]` —— 本地 PR review
- `/security-review` —— 扫当前分支 pending 改动的注入 / 鉴权 / 数据泄露风险
- `/loop [interval] [prompt]` —— 反复跑 prompt；不给 interval 时 Claude 自己调速。监控长实验杀手级。
- `/fewer-permission-prompts` —— 扫 transcript，把你反复批准的只读 bash 命令加到项目 allowlist

**自省**
- `/status` —— 版本、模型、账号、每字段来自哪层 settings
- `/doctor` —— 诊断安装 + 配置（`f` 自动修）
- `/cost` —— 本 session 累计 token 消耗
- `/insights` —— 分析过去 30 天 session（摩擦点、常用模型）
- `/stats` —— 日用量图
- `/recap` —— 一行本 session 摘要

**对外**
- `/mcp` —— MCP 服务器连接
- `/plugin` —— marketplace 浏览
- `/export [file]` —— 导出对话为纯文本
- `/copy [N]` —— 复制倒数第 N 条助手回复（带代码块选择器）
- `/btw <q>` —— 基于当前 context 问个小旁问，**不进对话历史**

### Plan 模式 —— 什么时候伸手

工作流：`Shift+Tab` 切到"plan" → 描述任务 → Claude 研究（读委托给 **Plan** subagent）→ 出方案 → 你选：

1. **批准 + auto** —— 撒手跑（如果有 `auto`）
2. **批准 + accept edits** —— 跑，跳过编辑 prompt
3. **批准 + manual** —— 跑，每次编辑都问
4. **继续规划，带反馈** —— 迭代
5. **用 Ultraplan 精修** —— 浏览器多 agent review（需订阅）

每个批准选项还可以**先清掉规划 context** —— 研究阶段把 context 撑大但实施小的情况很好用。

大型 refactor 的最佳组合：plan → acceptEdits。审方案（便宜、聚焦）远比审每次编辑（贵、吵）划算。

### Subagents —— 真正常用的那个特性

Subagents = fork 出去的 context window。你只拿到摘要；主对话不会被搜索结果淹。

**内置 subagents，随时可用：**

| Agent | 模型 | 工具 | 什么时候触发 |
|---|---|---|---|
| **Explore** | Haiku | 只读 | Claude 需要搜 / 读代码但不动时自动派。thoroughness 级别：`quick` / `medium` / `very thorough`。 |
| **Plan** | 继承 | 只读 | Plan 模式的研究助手。防止无限嵌套。 |
| **general-purpose** | 继承 | 全部 | 需要既探索又动手的复杂多步工作。 |
| **statusline-setup** | Sonnet | — | 跑 `/statusline` 时触发。 |
| **Claude Code Guide** | Haiku | — | 你问 Claude Code 自己的功能时。 |

**Explore 是读新 codebase / 论文 repo 的单点最实用特性。** 问一句"这个 repo 的训练循环怎么跑的？"—— Claude 派 Explore，回一条摘要，主对话保持干净。

**自定义 subagents** 住在 `~/.claude/agents/<name>.md`。通过 `/agents`（交互式，可"Generate with Claude"）或手写 —— 就是 Markdown + YAML frontmatter：

```markdown
---
name: paper-reader
description: 读 ML 论文的 PDF / repo 并总结 method / novelty / limitations。用户给论文 URL 或问"这论文有什么新东西？"时触发。
tools: Read, Grep, Glob, WebFetch
model: sonnet
---

读论文时：
1. Method：一段话，公式内嵌
2. Novelty：跟最近相关工作有什么区别？
3. Limitations：作者没说、审稿人会问的
4. Reproducibility：repo 跟论文对得上吗？
```

存到 `~/.claude/agents/paper-reader.md` → 每个项目都可用。调用：`用 paper-reader agent 总结 …`。

`/agents` → "Running" tab 看活着的 subagents；可以打开 transcript 或停掉某个。

### Agent Teams —— 并行辩论（实验性）

`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 开启。多个独立的 Claude session 共享一个 task list；teammates 可以**互相发消息**（subagents 不行）。lead 负责汇总。

研究员场景下真能赚回 token 成本：

- **竞争假设 debug**：「5 个 teammate 调查 loss 在第 8k 步发散的不同假设。互相对话试图证伪对方的理论。结果更新到 findings 文档。」
- **并行评审**：「评审 PR #142 —— security teammate、performance teammate、test-coverage teammate。各自报告。」
- **多角度设计**：「CLI 设计 —— 一个做 UX，一个做架构，一个扮演 devil's advocate。」

经验值：3–5 个 teammate，每人 5–6 个任务；从研究 / 评审开始（别上来就做实现，容易文件冲突）。token 成本随人数线性增长，所以只在并行探索明显赢过串行时用。

### Skills —— 自带的、自己写的

**Bundled skills** Claude Code 自带；跟自己写的共用 `/` 命名空间。值得背下来：`/claude-api`、`/simplify`、`/debug`、`/loop`、`/review`、`/security-review`、`/init`（生成 CLAUDE.md 起步版）、`/team-onboarding`（根据过去 30 天 session 生成 onboarding 文档）。

**自定义 skills** 放 `~/.claude/skills/<name>/SKILL.md`（user 级）或 `.claude/skills/…`（项目级）。frontmatter 控制谁能调 + 什么工具预批准：

```yaml
---
name: benchmark-run
description: 跑 benchmark 套件，抓 wall-clock + peak memory，格式化成表格
disable-model-invocation: true   # 只有我能调，不让 Claude 自己触发
allowed-tools: Bash(python bench/*.py)  Bash(/usr/bin/time *)
argument-hint: [config-file]
---

跑 `python bench/run.py $ARGUMENTS`，抓 /usr/bin/time 的 stderr，
输出 markdown 表格：config、wall_s、peak_rss_mb、tokens/s。
```

`disable-model-invocation: true` 是**有副作用** skill（deploy、benchmark、send-slack）的杀手字段 —— Claude 不会悄悄触发。`user-invocable: false` 是反向，给"Claude 应该知道但你不会去 `/` 调"的背景知识用。

### Headless 模式 —— 把 Claude Code 当 shell 工具

`claude -p "…"` 非交互式跑。实用场景：

```bash
# CI 里审 diff
gh pr diff 123 | claude -p --append-system-prompt "安全审查。标注注入、鉴权、密钥问题。" --output-format json

# 自动 commit 已 staged 的改动
claude -p "审已 staged 改动并 commit" --allowedTools "Bash(git diff *),Bash(git commit *)"

# 抽结构化数据
claude -p "列 auth.py 的函数名" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}}}' \
  | jq '.structured_output.functions'

# 每台机结果相同（跳过自动发现）：
claude --bare -p "总结这篇论文" --allowedTools "Read"
```

`--bare` 是脚本推荐模式：不读 CLAUDE.md / hooks / plugins / MCP / auto-memory。可复现。跟 `--append-system-prompt-file` 配合，把 prompt 也版本化。

### 研究员 playbook —— 真能赚回投入的场景

**1. 读新论文的 repo。** 在 repo 里开 Claude Code。第一句 prompt：`用 Explore agent (very thorough) 梳理训练管线：数据怎么加载、损失怎么组合、eval 怎么设。返回带 file:line 引用的 markdown 大纲。` 主 context 保持干净，你拿到可导航的大纲。

**2. Debug 一个不稳定的训练跑。** `/plan 第 8k 步 NaN 的根因`。Claude（plan 模式下）读 log 文件、config、model code —— 只读，啥都不动。给出 2-3 个假设。你选一个，按"Approve + accept edits"，它实施修复。

**3. 跨 20 个文件的大 refactor。** Plan 模式 → 审方案 → "Approve + acceptEdits" → 让它跑。中途跑偏就 `Esc` `Esc`（`/rewind`）。`git diff` 是最终审查面。

**4. 长实验看门狗。** `/loop 10m 检查训练是否挂 / loss 是否达标；达标就 commit 并发 slack`。或不给 interval：`/loop` 让 Claude 自己调速。"好了叫我"类工作流神器。

**5. 学 Claude API 本身。** `/claude-api` 加载你语言的 Python 参考 —— tool use、streaming、batch、结构化输出、坑。然后问：`写个最小 agent，用 tool_choice: any 并处理 rate-limit 重试`。

**6. 自己不会 debug 的前端。** 让 auto-memory 积累（"上次发现 Tailwind 类冲突是因为 purge 列表"）。多用 `Esc` `Esc` —— 某次编辑搞坏 UI 就 rewind 到上个能跑的版本，换条路。session 结束后用 `/simplify` 清一清模型留下的乱代码。

**7. 本来要找同事 review 的 PR。** `/review <PR#>` 本地过一遍；`/ultrareview <PR#>` 深度云端多 agent review（Pro / Max 免费 3 次，之后计费）。或开 Agent Team：「3 个 reviewer —— security / performance / tests —— 各自报告。」

**8. 数据管线脚本。** `acceptEdits` 模式 + `claude -p --bare` 适合想完全一致复跑的脚本。项目 settings 里预批准 `Bash(python …)` + `Bash(head|wc|ls …)`，循环里就不会每次 tool 调用都停下问。

### 成本 / 限流 / 退路

- `/cost` 看 session token；`/usage` 看方案配额；`/stats` 是看板。
- `/fast` 快 2.5× 但 token 也贵 2.5× 且吃 **extra usage**，不吃方案配额。长时间无人值守跑要关。
- `/effort low` vs `xhigh` —— 越低思考越少 = 越快越便宜 = 硬任务可能出错。我们默认 pin 成 `xhigh`。临时任务可用 `/effort medium` 降档。
- 撞墙了？`/compact [focus]` 总结对话（保 CLAUDE.md + rules）。`/rewind` 可回滚到没膨胀前。`/clear` 直接重开。

---

## 改设置

1. 编辑 `dot_claude/settings.json`。
2. `chezmoi diff ~/.claude/settings.json` —— 审渲染后的 diff。
3. `chezmoi apply ~/.claude/settings.json`。
4. 若新值是想守护住的，加到 `tests/claude.sh` 的 **Pinned settings fields** 段。
5. 重启 Claude Code（`Ctrl+D` / exit，再启）—— 大部分 settings 仅启动时读。

## 健康检查

### 自动

```bash
bash tests/claude.sh
```

~43 项：binary 存在（`claude`、`bun`、`npx`、`node`、`ccusage`），source + target JSON 合法性，每个 pin 的字段（4 个 enabledPlugins + 4 个 marketplaces + statusLine + PreToolUse + syntax + effort），所有 `.chezmoiignore` runtime 排除（含 `dot_claude.json` 防御守护），4 个插件的 cache 已填充，`claude --version` + `npx block-no-verify` 解析烟测。

### 手动

- [ ] `claude --version` 正常跑
- [ ] `claude` 交互式启动，statusLine 渲染（claude-hud bun 输出）
- [ ] `/hooks` 列出 PreToolUse Bash hook + 所有插件 hooks，没有"command not found"
- [ ] `/status` 显示 `~/.claude/settings.json` 是 `effortLevel: xhigh` 和 `syntaxHighlightingDisabled: true` 的来源
- [ ] 在 Claude session 里试 `git commit --no-verify`，被 PreToolUse hook 拦下
- [ ] `/plugin list` 显示 `claude-hud`、`codex`、`andrej-karpathy-skills`、`chrome-devtools-mcp` 都启用
- [ ] `ccusage daily` 能无报错打印用量表（读 `~/.claude/projects/**/*.jsonl`）
- [ ] 在**另一台** Mac 上 `chezmoi apply` 后：`~/.claude/settings.json` 有同样字段

## 排障

| 症状 | 可能原因 | 解决 |
|---|---|---|
| `claude: command not found` | Claude Code 没装 | `bootstrap.sh` 跑安装器；单次：`curl -fsSL https://claude.ai/install.sh \| bash` |
| `statusLine` 空白 | `claude-hud` 插件还没装（`~/.claude/plugins/cache/claude-hud/` 空） | `claude plugin install claude-hud@claude-hud`，重启 |
| `statusLine` 报 `bun: No such file` | `/opt/homebrew/bin/bun` 没装 | 当前作为 Claude Code 依赖安装；如缺：`brew install oven-sh/bun/bun` |
| PreToolUse hook：`node: command not found` 或 `npx: command not found` | `node` 缺失（Phase 2 修复回归） | `brew bundle` —— Brewfile 声明了 `node`。根因见 `Brewfile` 注释。 |
| 插件 `.mjs` hooks 在 session 启动时全挂 | `node` 缺失（同上）—— `openai-codex` 生命周期 hooks shell 出去调 `node` | 同：`brew bundle` |
| `syntaxHighlightingDisabled: true` 似乎没生效 | 新版本 Claude Code 改了 key 名 | 对照上游[settings 参考](https://code.claude.com/docs/en/settings) —— 该领域在快速演进 |
| Auto-memory 胀爆 | 某项目 `~/.claude/projects/<proj>/memory/MEMORY.md` > 200 行 → 超出部分不再自动加载 | 跑 `/memory` 精简，或让 Claude offload 到 topic 文件 |
| `chezmoi apply` 试图创建 `~/.claude/sessions/` / `~/.claude/cache/` | 某个 ignore 规则被删了 | 补回 `.chezmoiignore` —— `tests/claude.sh` 会告诉你哪条 |

## 坑

- **`enabledPlugins` 是声明，不是 vendor**。干掉 `~/.claude/plugins/` 并重启会重新从 marketplace 下载。新 Mac 首次启动需要 GitHub 连通。
- **`statusLine` 硬编码 `/opt/homebrew/bin/bun`**。Apple Silicon（咱两台）没问题。跨 Intel 或 Linux 会挂 —— 将来真要跨架构，可把 `dot_claude/settings.json.tmpl` 改成 `{{ env "HOMEBREW_PREFIX" }}` 或 `$(command -v bun)`。
- **别 `chezmoi add ~/.claude`**。它会递归进 runtime 子目录 —— `.chezmoiignore` 挡住多数，但整目录 add 仍可能出意外。按文件 add（`chezmoi add ~/.claude/settings.json`）。
- **`~/.claude/settings.local.json` 从不 track**，chezmoi 也从不管它，所以本地改动完全带外安全。
- **Auto-memory 是 machine-local**。工作机上攒的好 MEMORY.md 条目不会跟回家。这是官方设计（[上游文档](https://code.claude.com/docs/en/memory#storage-location)）；要跨机规则，写进 `~/.claude/CLAUDE.md` 并在将来某 phase version 化**那个**。
- **老 key `includeCoAuthoredBy` 已废弃**。我们 settings 里没有。将来要控制 commit attribution 用新的 `attribution` 对象 —— 2026 settings 文档有。

## 从头重建

若 `~/.claude/settings.json` 被搞坏：

```bash
chezmoi apply ~/.claude/settings.json
```

若插件缓存烂了（版本不对、半安装）：

```bash
rm -rf ~/.claude/plugins
# 重启 Claude Code —— enabledPlugins + extraKnownMarketplaces 触发重拉。
```

若 auto-memory 乱了（当前项目的条目过期或错）：

```bash
rm -rf ~/.claude/projects/<proj>/memory
# Claude 从头开始重新积累。反正本来就是 per-machine 的，安全。
```

---

## 相关

- [`claude-plugins.zh.md`](claude-plugins.zh.md) —— 每个 plugin / MCP / skill 的用法、bundled-skill 参考、如何加自定义 skill/agent、公司内外扩展如何划分
- [`Brewfile`](../Brewfile) —— `node` + `ccusage` 在那声明；内联注释讲为什么
- [Claude Code settings 参考](https://code.claude.com/docs/en/settings)
- [Claude Code hooks 参考](https://code.claude.com/docs/en/hooks)
- [Claude Code memory 参考](https://code.claude.com/docs/en/memory)
