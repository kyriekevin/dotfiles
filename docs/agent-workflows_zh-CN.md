# Agent 工作流试验

> [English](agent-workflows.md) · 中文

这个分支把 agent 工作流改成 **Ghostty + herdr**。Ghostty 负责终端表面：字体、主题、Kitty 图片协议、原生 quick terminal 和普通 shell tab/split。Herdr 跑在 Ghostty 里面，负责 agent multiplexer：workspace、tab、pane、detach/reattach，以及 Claude/Codex 状态感知。

这次保持层次分离：不再把 cmux 当另一个终端 app，也不默认保留 tmux dashboard。

## 快速试用顺序

### A. Ghostty + herdr

适合：多项目、多 Claude/Codex session 并行，需要在终端里看哪个 agent idle、working、done、blocked。

安装：

```bash
brew install --cask ghostty
brew install herdr
```

这个分支也把它们写进 Brewfile：

```bash
brew bundle --file ~/.dotfiles/Brewfile
```

dotfiles 管理的配置：

| 工具 | 源文件 | 目标 |
|---|---|---|
| Ghostty | `dot_config/ghostty/config` | `~/.config/ghostty/config` |
| herdr | `dot_config/herdr/config.toml` | `~/.config/herdr/config.toml` |

应用：

```bash
chezmoi --source=/Users/zyz/.dotfiles apply ~/.config/ghostty/config ~/.config/herdr/config.toml ~/.config/zsh/aliases.zsh
```

入口：

```bash
ghostty
herdr
hd    # herdr alias
```

Herdr 保留 tmux 的 prefix 形状：`Ctrl+b`。Ghostty 不再定义另一套 `Ctrl+s` 终端 chord。

| 键 | 动作 |
|---|---|
| `Ctrl+b ?` | 显示 Herdr help 和当前 keybindings |
| `Ctrl+b w` | workspace picker |
| `Ctrl+b g` | session/workspace navigator |
| `Ctrl+b Shift+n` | 新 workspace |
| `Ctrl+b c` | 新 tab |
| `Ctrl+b n/p` | 下一个 / 上一个 tab |
| `Ctrl+b %` / `Ctrl+b "` | tmux-style 分 pane |
| `Ctrl+b h/j/k/l` | pane 间移动 |
| `Ctrl+b z` | 当前 pane 最大化 |
| `Ctrl+b x` | 关闭 pane |
| `Ctrl+b q` | detach；pane 里的进程继续跑 |

为什么这次优先于 cmux：

- Ghostty 仍然是唯一终端 app。
- Herdr 住在终端里，不用另一个 GUI surface 包住终端。
- pane 是真实 terminal process，复制、shell 行为、Yazi 图片预览都保留终端原生体验。
- Herdr 对 Claude Code 和 Codex 有内置 agent 状态感知，可通过进程/输出检测和可选 integration 增强。
- detach/reattach 给 agent desk 需要的持久性，不需要在 repo 里继续维护 tmux config。
- 我们的配置保持通知关闭：`ui.toast.delivery = "off"`。

### B. 只用 Ghostty

不需要 agent 状态时，直接用 Ghostty 自己的 app/default 快捷键。这个 repo 不再给 Ghostty 加自定义 `Ctrl+s` prefix；终端复用键位统一放在 Herdr。

## 怎么选

| 方案 | 适合 | 不适合 |
|---|---|---|
| Ghostty + herdr | 多项目、多 agent、终端内 workspace dashboard、detach/reattach | 不想多一层 terminal-mode multiplexer |
| 只用 Ghostty | 单项目或轻量多任务 | 同时看很多 agent 的 blocked/done 状态 |

建议：agent-heavy 工作默认用 Ghostty + herdr。只是开 shell 时直接用 Ghostty。

## 健康检查

```bash
bash tests/ghostty.sh
bash tests/herdr.sh
bash tests/yazi.sh
```

`tests/ghostty.sh` 验证 Ghostty 配置，并要求 Ghostty.app 已安装。`tests/herdr.sh` 验证 Brewfile 意图、Herdr 配置、文档和已安装 CLI。`tests/yazi.sh` 抓文件管理器配置解析和预览后端漂移。

手动检查：

- [ ] 打开 Ghostty，运行 `herdr`。
- [ ] `Ctrl+b ?` 打开 Herdr help，并显示当前配置后的 keybindings。
- [ ] `Ctrl+b %` 和 `Ctrl+b "` 可以分 pane。
- [ ] `Ctrl+b Shift+n` 可以创建 workspace。
- [ ] 一个 pane 跑 `claude`，另一个 pane 跑 `codex`；Herdr sidebar 能显示 agent 状态。
- [ ] `Ctrl+b q` detach；再次运行 `herdr` 能 reattach 到同一个 server。
- [ ] 在 Ghostty pane 里运行 `y`；图片预览走 Ghostty Kitty 协议。

## 回滚

不喜欢 Herdr：不打开它即可。要从配置层撤回，checkout 回 `main` 后：

```bash
chezmoi --source=/Users/zyz/.dotfiles apply ~/.config/ghostty/config ~/.config/zsh/aliases.zsh
rm -f ~/.config/herdr/config.toml
```
