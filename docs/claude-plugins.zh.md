# Claude Code 扩展 —— plugins · MCP · skills

> [English](claude-plugins.md) · 中文

本文件是每个扩展的详细参考。配置总览（pin 什么、为什么、chezmoi 怎么渲染）在 [`claude.zh.md`](claude.zh.md)；这里回答 *"每一块具体干什么，什么时候用"*。

范围：**跨机、可公开发布的扩展。** 任何带 token / 内网 URL / 工作机专用凭据的东西都按 per-user 放 `~/.claude.json`（已故意 `.chezmoiignore`），不在这里。

## 扩展模型速览

四种机制，常被混为一谈：

| 机制 | 声明在哪 | 住在 | 加什么 | 谁来调 |
|---|---|---|---|---|
| **Plugin** | `settings.json` → `enabledPlugins` | `~/.claude/plugins/cache/<mp>/<plugin>/<ver>/` | 一个*打包体* —— 可含 commands / skills / subagents / hooks / MCP servers 任意组合。通过 `marketplace` 解析。 | 取决于包内每个条目 |
| **MCP server** | `~/.claude.json`（项目级）或 `settings.json`（user 级），也可由 plugin 打包 | 进程外；Claude spawn 并走 JSON-RPC | Tool 函数（`mcp__<server>__<tool>`） | Claude 自动发现；每 session 你预批准 |
| **Skill** | YAML frontmatter（`name`、`description`） | `~/.claude/skills/<name>/SKILL.md`，或 plugin 的 `skills/` 目录内 | 按需加载的 playbook —— Claude 觉得匹配 description 或用户打 `/<name>` 时加载 | Claude（自动）或用户 —— 由 frontmatter 控制 |
| **Subagent** | YAML frontmatter（`name`、`tools`、`model`） | `~/.claude/agents/<name>.md`，或 plugin 的 `agents/` 目录内 | Fork 出的 context window 跑工具、回摘要 | Claude 自动委托；用户可指名调 |

一个 plugin 可以 ship 其他三种的任意组合。所以看下面表格时，把 plugin 当*打包格式*，真正好用的表面永远是 commands / skills / subagents / MCP tools 的某种组合。

---

## Plugins（4 个，均外部）

pin 在 `dot_claude/settings.json`。`chezmoi apply` + 新 Mac 首次启动 Claude 会触发 marketplace fetcher；不用每个 plugin 手动装。

### `claude-hud@claude-hud`

**是什么**：bun 驱动的 `statusLine` 后端 —— 咱 pin 的 `statusLine` 字段 exec 的就是它。渲染 Claude Code 底部那条显示 context 占用 / 活跃 subagents / 当前权限模式的状态条。

**Ships**：
- `/claude-hud:configure` —— 打开 HUD 配置 UI
- `/claude-hud:setup` —— 一次性 setup（statusLine 接入）

**上游**：<https://github.com/jarrodwatts/claude-hud>

**何时**：始终在用 —— 它就是 `statusLine` 本身。`/claude-hud:*` 命令只有你想改显示内容时才用得上。

**Cache 目录**：`~/.claude/plugins/cache/claude-hud/claude-hud/<semver>/` —— `tests/claude.sh` 在 runtime 挑版本号最高的（见 `dot_claude/settings.json` 的 `statusLine`）。

### `codex@openai-codex`

**是什么**：把 OpenAI Codex 作为"第二意见"引擎接入 Claude Code。把一个重型编码任务、一次调查、或者一遍"帮我看看"派过去 —— Codex 在独立 context 里跑完给回。

**Ships**：
- `/codex:setup` · `/codex:status` · `/codex:cancel` —— 生命周期
- `/codex:review` —— Codex 审 diff 或文件
- `/codex:rescue` —— 把卡住的任务委托给 Codex
- `/codex:result` —— 读最近一次 Codex 跑的输出
- `/codex:adversarial-review` —— Codex **反对**你的方案来做压测
- **Subagent**：`codex:codex-rescue` —— Claude 卡住时自动委托的目标
- **Skills**：`codex-cli-runtime` · `codex-result-handling` · `gpt-5-4-prompting`（内部辅助，自动加载）
- **Hooks**：`.mjs` SessionStart / SessionEnd / Stop —— shell 出去调 `node`（Brewfile 声明了）

**上游**：<https://github.com/openai/codex-plugin-cc>

**何时**：
- Claude 同一个 bug 迭代两轮还不收敛 → `/codex:rescue`
- 想在 ship 前对非平凡改动做独立 review → `/codex:adversarial-review`
- 卡在"我是不是漏了什么明显的东西" → `/codex:review` 当前文件
- 只要 Claude 的 runtime 指南命中 agent 的 proactive trigger，`codex:codex-rescue` 会自动触发 —— 无需手动

### `andrej-karpathy-skills@karpathy-skills`

**是什么**：打包了 Karpathy 写的 [LLM 编码行为指南](https://github.com/karpathy/claude-guidelines) 的单个 skill —— 动手前先思考、追根因而非打补丁、别加抽象等。当 Claude 检测到匹配模式（比如用户只让修 bug 但它开始加抽象）时该 skill 自动加载。

**Ships**：
- Skill：`karpathy-guidelines`（Claude 匹配时自动调）

**上游**：<https://github.com/forrestchang/andrej-karpathy-skills>

**何时**：被动作用。对 dotfiles / 一次性任务很有用 —— 你希望模型守住范围。如果你有意做架构重写、"别加抽象"的 nudge 碍事，去 `/skills` 里关掉。

### `chrome-devtools-mcp@claude-plugins-official`

**是什么**：以 plugin 形式打包的 MCP server —— 包装 Chrome DevTools Protocol，让 Claude 能**驱动并诊断**活 Chrome。导航页面、执行 JS、录 network / performance trace、读带 source map 的 console 栈、模拟 CPU / 网络节流。

这是**运行时 debug** 层：claude-in-chrome（DOM）和 computer-use（像素）让 Claude *操作* Chrome；这个让 Claude *调查* Chrome。

**Ships**：一批 `mcp__chrome__*` 工具（navigate、new_page、evaluate、screenshot、get_console、get_network、list_pages、performance_start/stop、emulate_cpu/network、fill_form、click 等）。Claude 自动发现 —— 没有命令 / skill 要记。

**上游**：<https://github.com/ChromeDevTools/chrome-devtools-mcp>

**何时**（对上咱研究员场景）：
- **用 Claude 生成了网页但跑不起来** —— "打开 http://localhost:5173 的 console，把栈贴出来，告诉我挂在哪"。以前：你开 DevTools 复制错误。现在：Claude 自己闭环。
- **页面慢**：「在 http://localhost:5173/dashboard 录 performance trace，告诉我主线程被什么挡了」。Claude 启 profile、读 trace、报 Long Task / layout thrash / 大 JS eval。
- **网络挂**：「为什么 POST /api/foo 返 500？」—— Claude 直接看请求 / 响应头 + body。

**Cache 目录**：`~/.claude/plugins/cache/claude-plugins-official/chrome-devtools-mcp/latest/`（注意是 `latest/`，不是 semver —— 这个 plugin 的 marketplace entry 走 Git URL 拉，不走 release tag）。

---

## MCP servers（plugin 之外的）

除了上面声明为 plugin 的 `chrome-devtools-mcp`，还有三种 MCP 表面要知道：

### `computer-use`（ambient，Anthropic 内建）

**是什么**：原生桌面控制 + 截图。Claude Code 桌面 app 自带 —— 不需要 `mcpServers` 条目，不用装。

**表面**：`mcp__computer-use__*` —— `screenshot`、`left_click`、`type`、`key`、`scroll`、`request_access`、`list_granted_applications`、`zoom` 等。

**分级**：按类别限制 app。浏览器是 `read` 级（可见，不能点 / 打字），终端 + IDE 是 `click` 级（可点，不能打字），其他 `full` 级。撞到限制时错误消息会告诉你是哪级。浏览器场景下用下面 `claude-in-chrome` 更合适。

**何时**：原生 app（Finder、Notes、Maps、系统设置、第三方 app）；跨 app 流程；或者作为 **像素级 fallback** —— DOM 读失败时用，见下文 1+3 工作流。

### `claude-in-chrome`（Chrome 应用商店扩展）

**是什么**：Claude for Chrome 浏览器扩展。DOM 感知的导航、点击、填表 —— 对网页应用比像素级鼠标移动快得多、准得多。

**表面**：`mcp__claude-in-chrome__*` —— 读页、点、打字等。

**安装**：Chrome Web Store → 搜 "Claude for Chrome"（它不是 `.claude.json` 里的 MCP server；onboarding 状态存在 `~/.claude.json` 的 flag 如 `hasCompletedClaudeInChromeOnboarding`）。chezmoi 无法接管 —— 浏览器扩展在这里没法 version。

**何时**：任何网页的 DOM 级操作。浏览器自动化的首选；只有权限或缺失字段挡路时再降级到 computer-use。

### 1+3 工作流（DOM 先行，像素兜底）

浏览器页面 DOM 读不出来内容（权限墙、redirect 登录、空 / 脱敏字段、跨域 iframe）时，别直接找用户要权限 —— 像素可能还在：

1. 试 `mcp__claude-in-chrome__*` —— 快，结构化
2. 空 / 权限被拒？先别停
3. `mcp__computer-use__screenshot`（`request_access` 确认 Chrome 在 allowlist 后）—— 也许像素渲染了但 DOM 是空
4. 小字用 `zoom` 再试
5. **再不行**才找用户要权限

有些页面视觉渲染了内容但 DOM 读不到，像素 fallback 绕开 DOM / API 层的权限限制。

### `chrome-devtools-mcp` 回顾

第三层浏览器表面：调试*运行时*，不是导航页面。以 plugin 形式装（见上）。Claude 需要 console / network / performance 信息时走这里，不走 claude-in-chrome。

### Per-user MCP（不在本 repo）

任何带 token、指向内网、或机器特有的 MCP，都按 per-user 用 `claude mcp add` 装。config 落到 `~/.claude.json` —— 作为 `dot_claude.json` 已在 `.chezmoiignore` 防御性 ignore，secret 和 per-machine 配置不会泄进本 repo。

---

## Skills —— 自带清单 + 如何自己写

### 默认就有的（无需声明）

Claude Code 自带（值得按名字记住）：

- `/claude-api` —— Claude API 参考加载器（Python / TS）。文件里 `import anthropic` 时自动触发。
- `/simplify [focus]` —— 对近改动派并行 review agent，汇总，应用修复
- `/debug [description]` —— 开 debug log + 排障走读
- `/review [PR#]` —— 本地 PR review
- `/security-review` —— 扫 pending 改动的注入 / 鉴权 / 数据泄露
- `/loop [interval] [prompt]` —— 重复跑 prompt，不给 interval 则自己调速
- `/init` —— 生成 `CLAUDE.md` 起步版
- `/team-onboarding` —— 基于过去 30 天 session 生成 onboarding 文档

### 来自上面 plugin 的

| Skill | 来自 | 自动触发？ |
|---|---|---|
| `karpathy-guidelines` | `andrej-karpathy-skills` | 是 —— Claude 检测到反模式时 |
| `codex-cli-runtime` | `codex` | 自动 —— Codex 委托时的内部辅助 |
| `codex-result-handling` | `codex` | 自动 —— 解析 Codex 输出 |
| `gpt-5-4-prompting` | `codex` | 自动 —— 给 Codex 格式化 prompt 时 |

`/skills` 列出当前已加载的全部，带 token 成本（`t` 排序）。

### 自己写

user 级自定义 skill 放 `~/.claude/skills/<name>/SKILL.md`。当前 `dot_claude/skills/**` 被防御性 ignore（`.chezmoiignore`），要把 skill 纳入 repo 先删那行。

最小骨架：

```markdown
---
name: benchmark-run
description: 跑 benchmark 套件，抓 wall-clock + peak memory，格式化成 markdown 表
disable-model-invocation: true   # 只有用户能调；Claude 不能悄悄触发
allowed-tools: Bash(python bench/*.py) Bash(/usr/bin/time *)
argument-hint: [config-file]
---

跑 `python bench/run.py $ARGUMENTS`，抓 /usr/bin/time 的 stderr，
输出 markdown 表：config、wall_s、peak_rss_mb、tokens/s。
```

两个关键旋钮：
- **`disable-model-invocation: true`** —— 有副作用的 skill（deploy、benchmark、send-slack）。模型不能自己触发，你必须打 `/<name>`。
- **`user-invocable: false`** —— 反向：模型应该载入 context 的背景知识，但你永远不会手打 slash（比如某个项目的 invariant）。

需要 shell 出去读用量数据的 skill，`ccusage`（`Brewfile` 声明）读 `~/.claude/projects/**/*.jsonl` 出日 / 周 / 月 / session 表 —— 任何需要 token 用量数字的 skill 都能拿它当稳定输入。

---

## Subagents & commands —— 指路

两个机制都在 [`claude.zh.md`](claude.zh.md) 的"高效使用 Claude Code"里写了 —— `/agents`、自定义 subagent 模板、内置 Explore / Plan / general-purpose、Agent Teams。commands 声明方式类似（Markdown + YAML frontmatter 放 `~/.claude/commands/<name>.md`，或打包在 plugin 的 `commands/` 目录）。

`dot_claude/agents/**` 和 `dot_claude/commands/**` 都在 `.chezmoiignore` 防御性 ignore —— 有值得 version 的内容时先删 ignore 条目再 opt in。

---

## 加新扩展 —— 该用哪种机制？

决策顺序：

1. **是已发布的 plugin 吗？** → 加 `enabledPlugins` + 在 `extraKnownMarketplaces` 注册 marketplace。最便宜，marketplace SHA 自动跟新。
2. **是第三方 MCP server 吗？** → `claude mcp add`。存 `~/.claude.json`（按设计 machine-local —— 放 token）。config 无 token 的话，可考虑项目根放 `.mcp.json` 做跨机共享。
3. **是想随手触发的 prompt 套路？** → skill。`~/.claude/skills/<name>/SKILL.md`。
4. **是后台跑工具的 worker？** → subagent。`~/.claude/agents/<name>.md`。
5. **是一次性 slash 命令？** → command。`~/.claude/commands/<name>.md`。

每种都要问："该不该进公开 repo？"
- 跨机、无 secret → 是，version 住。先删对应的 `.chezmoiignore` 条目。
- 带 token / 内网 URL / 机器特有状态 → 否。Per-user 保留在 `~/.claude.json`（MCP 场景）或对应的 runtime 目录。

---

## 重建 / 排障

**插件 cache 烂了（版本不对、拉取卡住）：**
```bash
rm -rf ~/.claude/plugins
# 重启 Claude Code —— enabledPlugins + extraKnownMarketplaces 会从 GitHub 重拉。
```

**第二台 Mac `chezmoi apply` 后 `chrome-devtools-mcp` tools 没出现：**
- 检查 `~/.claude/plugins/cache/claude-plugins-official/chrome-devtools-mcp/latest/` 存在 —— 没有的话先启动一次 Claude，marketplace fetcher 会解析 `enabledPlugins`。
- Puppeteer 首次用要 Chrome 二进制；launch 报错时跑 `npx puppeteer browsers install chrome`。没写进 Brewfile —— 这是一次性懒装成本。

**新机 `ccusage daily` 报错：**
- 它读 `~/.claude/projects/**/*.jsonl`。新 Mac 上没有内容 → 空表是正确行为。用 Claude 一次再试。

**`computer-use` 调用被拦：**
- 得先用 `request_access` 传 app 列表；用户逐个批。分级（浏览器：只读，终端：只点）是按类别。错误 response 会告诉你撞到哪级。

**Per-user MCP 加载失败：**
- `claude mcp list` 按 server 报健康状态。多数失败是 token 过期，或 server 上游（registry / endpoint）当前网络进不去。config 在 `~/.claude.json` 的 `projects.<cwd>.mcpServers` 下 —— 不在本 repo。

---

## 相关

- [`claude.zh.md`](claude.zh.md) —— settings / hooks / 权限模式 / 快捷键 / 研究员 playbook
- [`Brewfile`](../Brewfile) —— `ccusage`、`node` 在那声明，带理由
- [Claude Code plugin 参考](https://code.claude.com/docs/en/plugins)
- [Claude Code MCP 参考](https://code.claude.com/docs/en/mcp)
- [Claude Code skills 参考](https://code.claude.com/docs/en/skills)
- [Claude Code subagents 参考](https://code.claude.com/docs/en/subagents)
