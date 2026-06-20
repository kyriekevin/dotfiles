# Ghostty

> 中文 · [English](ghostty.md)

Ghostty 是这个 repo 的主终端 app。它负责渲染、字体、主题、Yazi 的 Kitty 图片协议、quick terminal，以及普通 shell tab/split。需要 agent-aware workspace 时，在 Ghostty pane 里运行 Herdr。

## 组件分布

| 组件 | 位置 | 说明 |
|---|---|---|
| 配置 | `~/.config/ghostty/config` ← 源 `dot_config/ghostty/config` | 单个 `key = value` 文件。`Ctrl+s r` 重载，或重启 Ghostty。 |
| App | `/Applications/Ghostty.app` | Brewfile 里 `cask "ghostty"` 安装。 |
| 字体 | `Maple Mono NF CN` | Nerd Font 字形 + CJK 覆盖。 |
| 主题 | `Catppuccin Mocha` | Ghostty 内置。 |
| Agent multiplexer | Ghostty pane 里的 `herdr` | 见 [Agent 工作流试验](agent-workflows.zh.md)。 |

## 快捷键

Ghostty 继续保留现有 `Ctrl+s` chord，用于终端原生 tab/split。Herdr 在 pane 内保留默认 `Ctrl+b` 前缀。

| 键 | 动作 |
|---|---|
| `Ctrl+s c` | 新 Ghostty tab |
| `Ctrl+s n/p` | 下一个 / 上一个 Ghostty tab |
| `Ctrl+s \|` | 左右分屏 |
| `Ctrl+s -` | 上下分屏 |
| `Ctrl+s h/j/k/l` | Ghostty split 间移动 |
| `Ctrl+s m` | 当前 split 最大化 |
| `Ctrl+s =` | 均分 splits |
| `Ctrl+s x` | 关闭当前 surface |
| `Ctrl+s r` | 重载 Ghostty 配置 |
| `Cmd+\`` | 显隐 quick terminal |

## 为什么保留 Ghostty

- Yazi 图片预览直接走 Ghostty 的 Kitty graphics。
- 不需要 Herdr 时，Ghostty 原生 tab/split 仍然够用。
- Herdr 可以跑在 Ghostty 里，不替换终端 app。
- Catppuccin Mocha + Maple Mono NF CN 的视觉栈保持一致。

## 健康检查

### 自动化

```bash
bash tests/ghostty.sh
```

检查 Brewfile 意图、Ghostty app 是否存在、配置字段、快捷键守卫；如果系统里有 `ghostty` executable，则额外跑 CLI validate。

### 手动

- [ ] Spotlight 打开 Ghostty。
- [ ] `Ctrl+s c` 打开 tab。
- [ ] `Ctrl+s |` 和 `Ctrl+s -` 可以分屏。
- [ ] `Ctrl+s h/j/k/l` 可以在 split 间移动。
- [ ] `Ctrl+s m` 可以最大化/恢复当前 split。
- [ ] 运行 `y` 并预览 PNG/JPG；应该显示图片，而不是 ASCII 或空白。
- [ ] 在某个 pane 里运行 `herdr`；Herdr 只接管这个 pane。

## 排障

**Ghostty app 不存在** —— 运行 `brew install --cask ghostty` 或 `brew bundle --file ~/.dotfiles/Brewfile`。

**Yazi 图片预览空白** —— 看 `echo $TERM_PROGRAM`；在 Ghostty 里应为 `ghostty`。如果经过 tmux/screen/SSH 且没有 graphics passthrough，Yazi 可能静默不显示图片。

**`Ctrl+s` 冻住输出** —— Ghostty 理应在 PTY 之前拦截这个 chord。若冻结，说明配置没加载；重启 Ghostty 或 `Ctrl+s r` 重载。

**Herdr 吃快捷键** —— Herdr 在 pane 内用 `Ctrl+b` 当前缀。Ghostty 层用 `Ctrl+s`，Herdr 层用 `Ctrl+b`。
