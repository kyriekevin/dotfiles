# Agent 工作流试验

> [English](agent-workflows.md) · 中文

这个分支把 Claude Code / Codex 的多开体验拆成两个实际层。结论先写清楚：**cmux 是主终端表面**。Standalone Ghostty 不再安装；`~/.config/ghostty/config` 只保留给 cmux/libghostty 读取 terminal 渲染和快捷键默认值。tmux 只是 fallback。

cmux 的定位正好命中这里的问题：它是基于 Ghostty/libghostty 的 macOS 原生终端，加了 vertical tabs、workspace 元数据、内置浏览器和 CLI。也就是说，它解决的是“很多 agent session 哪个在等我”这个控制面问题，而不是让你记更多 pane。

## 快速试用顺序

### A. cmux

适合：你已经开始多项目、多 Claude/Codex session 并行，核心痛点是“哪个 session 在等我”和“窗口太多看不出上下文”。

安装：

```bash
brew tap manaflow-ai/cmux
brew install --cask cmux
```

这个分支也把它写进 Brewfile：

```bash
brew bundle --file ~/.dotfiles/Brewfile
```

配置由 dotfiles 管：cmux 源文件是 `dot_config/cmux/cmux.json`，目标是 `~/.config/cmux/cmux.json`。Ghostty-compatible terminal 配置也保留在 `dot_config/ghostty/config`，因为 cmux/libghostty 会读取它。当前版本把左侧 sidebar 调成更安静：背景跟 terminal 走、去掉 tint、隐藏端口/PR/log 等噪声。

```bash
chezmoi --source=/Users/zyz/.dotfiles apply ~/.config/cmux/cmux.json ~/.config/ghostty/config
cmux reload-config
```

入口：

```bash
cmux
cmux claude-teams
cmux codex-teams
```

zsh alias：

```bash
cm
```

cmux 快捷键也走同一套 `Ctrl+s` chord：

| 键 | 动作 |
|---|---|
| `Ctrl+s b` | 显隐左侧 workspace sidebar |
| `Ctrl+s w` | 打开 workspace switcher |
| `Ctrl+s n/p` | 下一个 / 上一个 workspace |
| `Ctrl+s ;` | 新增 workspace |
| `Ctrl+s c` | 当前 pane 新增 surface/tab |
| `Ctrl+s \|` / `Ctrl+s -` | 左右 / 上下分屏 |
| `Ctrl+s h/j/k/l` | pane 间移动 |
| `Ctrl+s m` | 当前 pane 最大化 |
| `Ctrl+s =` | 均分 panes |
| `Ctrl+s x` | 关闭当前 surface/tab |

cmux 配置里 New Workspace 的 shortcut id 叫 `newTab`；真正 pane 里的 tab/surface 是 `newSurface`。这个分支把两者都显式绑定：`Ctrl+s ;` 是 workspace，`Ctrl+s c` 是 tab/surface。

为什么它优先于 Claude Squad / tmux：

- 不要求 tmux；session、split、tab 都是 cmux 原生表面。
- 读 Ghostty-compatible 配置，保留现有字体、主题、颜色、快捷键投资，但不需要安装 Ghostty.app。
- sidebar 能显示 git branch、PR 状态、工作目录、端口和 workspace 状态，比一堆窗口标题有效。
- 内置 browser pane 和 scriptable API 更适合前端/本地服务调试。
- 它仍然是 terminal primitive，不把你锁进某个 agent 编排模型。

### B. tmux fallback

适合：cmux 不稳定、远程/纯 TTY 环境、或你临时需要一个低层 dashboard。

```bash
chezmoi --source=/Users/zyz/.dotfiles apply ~/.tmux.conf ~/.config/zsh/aliases.zsh ~/.config/zsh/tools.zsh
```

命令：

| 命令 | 作用 |
|---|---|
| `am` | 在当前目录 attach/create 一个 tmux session |
| `am name` | attach/create 指定 session |
| `ad` | 当前目录创建 agent desk：`shell`、`claude`、`codex` 三个 window |
| `ad name` | 指定 session 名 |

tmux 前缀是 `Ctrl+a`，不是 `Ctrl+s`，避免和 cmux/libghostty 的 `Ctrl+s` chord 层抢键。

## 怎么选

| 方案 | 适合 | 不适合 |
|---|---|---|
| cmux | 多项目、多 agent、需要上下文 sidebar 和原生 terminal panes | 不想安装新 GUI app |
| tmux `am` / `ad` | 远程/纯 TTY/fallback dashboard | 不想记 tmux prefix；想用 cmux 原生 UI |

我建议：主要试 cmux。tmux 暂时不要作为主方案，除非 cmux 不适合你的日常。

## 健康检查

```bash
bash tests/ghostty.sh
bash tests/cmux.sh
bash tests/tmux.sh
bash tests/yazi.sh
```

`tests/cmux.sh` 在 cmux 未安装前会红，这是预期。`tests/ghostty.sh` 只检查 cmux/libghostty 读取的 Ghostty-compatible 配置，不再要求 Ghostty.app。`tests/tmux.sh` 需要先 `chezmoi apply ~/.tmux.conf`。`tests/yazi.sh` 会抓 `y` 启动时立即暴露的配置解析错误。

## 回滚

不喜欢 cmux：不打开它即可。要从配置层撤回，checkout 回 `main` 后：

```bash
chezmoi --source=/Users/zyz/.dotfiles apply ~/.config/ghostty/config ~/.claude/settings.json ~/.config/zsh/aliases.zsh ~/.config/zsh/tools.zsh ~/.config/cmux/cmux.json
rm -f ~/.tmux.conf
```
