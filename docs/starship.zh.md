# Starship prompt

> [English](starship.md) · 中文

Rust 写的跨 shell prompt。我们用它做：双行 powerline 上下文、Catppuccin Mocha 色板（与 `$BAT_THEME` 一致）、vi-mode 视觉反馈（配合 OMZP::vi-mode），以及三个"只在需要时出现"的反馈 module。

## How it works

| 东西 | 位置 | 说明 |
|---|---|---|
| 配置 | `~/.config/starship.toml` ← 源 `dot_config/starship.toml` | 单文件，chezmoi 管 |
| shell 初始化 | `~/.config/zsh/tools.zsh` → `eval "$(starship init zsh)"` | 用 `$+commands[starship]` 做守卫 |
| 色板 | 内联定义的 `catppuccin_mocha` | 与 `env.zsh` 里 `BAT_THEME="Catppuccin Mocha"` 对齐 |

## Prompt 布局

两行：

    ╭─  bytedance  ~/.dotfiles   feat/starship  ✓    19:42  ╮
    ╰─   ✘ 1 took 14s ✦ 2 󰭹 claude

**第 1 行 —— 上下文（powerline 段，始终可见）：**

| 段 | 内容 | 理由 |
|---|---|---|
| `$os` | 系统图标 | 跨平台提示（mac / linux） |
| `$username` | 非默认用户才显示 | `show_always = false` —— 单人 mac 每行挂 `bytedance` 是噪音 |
| `$directory` | 3 级截断路径 | substitutions 把常用目录渲成 nerd-font 图标 |
| `$git_branch + $git_status` | 分支 + dirty 标记 | 一段一色 —— 瞟一眼就知道分支状态 |
| `$c + $python` | C / Python 版本 | 算法研究栈。`$package` 删掉了（node / rust 噪音） |
| `$time` | `%R` 时钟 | 没有 tmux status bar，prompt 就是时钟位置 |

**第 2 行 —— 反馈（无背景，只在触发时出现）：**

| Module | 触发条件 | 理由 |
|---|---|---|
| `$status` | 上条命令 exit ≠ 0 | fail-loud，不要静默失败 |
| `$cmd_duration` | 上条命令 ≥ 3s | 训练 / OJ run —— 不用 `time` 就知道"这条真的跑了这么久？" |
| `$jobs` | 至少一个后台任务 | `&` 启的训练任务一直可见 |
| `$custom.claude` | `CLAUDECODE=1` | 在 Claude Code session 内部开的 shell 视觉上可区分 |
| `$character` | 永远最后 | 失败红、成功绿、vi-normal 紫 |

## 改段

1. 在 `dot_config/starship.toml` 找到段（按 `# ─── Context segments ───` / `# ─── Feedback modules ───` 分组）。
2. 直接改 —— 不用 reload shell，starship 每次渲染都重读配置。
3. 要改左右顺序或删段，改顶层 `format = """..."""` 块。

## 加一个 custom module

```toml
[custom.mymodule]
description = "..."
when        = 'test -n "$SOME_ENV"'   # POSIX test，由 /bin/sh 跑
command     = "echo"                   # stdout 空，format 里写死文本
format      = '[  mymodule ]($style)'
style       = "bold fg:lavender"
```

`format` 顶层块里写一次 `$custom` 就够 —— 它会展开所有注册过的 `[custom.*]` module。

## 健康检查

### 自动化

```bash
bash tests/starship.sh
```

20 条检查：starship 在 PATH、config 文件存在、`starship print-config` 解析、tools.zsh 接线成功、`starship prompt` 正常 + 异常都能渲染、每个反馈 module 在正确输入下 fire（`--status=1`、`--cmd-duration=5000`、`--jobs=1`、`CLAUDECODE=1`）、live prompt 输出携带 Powerline + macOS + arrow 码点，以及 config 文件里 git / c / python / 时钟 / Downloads / Pictures 的 nerd-font 字形依然在位 —— 这些 PUA 码点在大多数编辑器里隐形，早期重写时被静默吞掉过五次。

### 手动（需要真实 TTY）

开新 terminal tab：

1. Prompt 是**两行** —— 第一行 powerline 段，第二行只有 `❯`。
2. Nerd-font 字形渲成图标（mac 󰀵、chat 󰭹、✦ 等），不是 `□` 方框。Brewfile 锁的字体是 **Maple Mono NF CN**；若看到方框，说明终端 `font-family` 没指向它。
3. `sleep 4` —— 第二行应显示黄色 `took 4s`。
4. `false` —— 第二行应显示红色 `✘ 1`。
5. `sleep 100 &` —— `$jobs` 应显示青色 `✦ 1`；用 `wait` 或 `kill %1` 清理。
6. 在 Claude Code 里 `$CLAUDECODE=1` —— 第二行应显示紫色 `󰭹 claude`。
7. 键入后按 Esc —— `❯` 应变紫色（vi-normal 模式）。

## Troubleshooting

**Nerd-font 字形显示为 `□` 方框** —— 终端字体不是 Nerd Font。Brewfile 锁了 `font-maple-mono-nf-cn`，把终端的 `font-family` 指到 `Maple Mono NF CN`。Phase 4b 会自动写进 Ghostty；Terminal.app / iTerm2 需要在偏好设置里手动选。

**在 Claude Code 里 `$custom.claude` 不显示** —— `echo $CLAUDECODE` 检查一下。如果空，父进程 Claude Code 版本太老没注入（≥ 1.x 才有）。兜底方案：`when = 'test -n "$CLAUDECODE" -o -n "$CLAUDE_CODE_ENTRYPOINT"'`。

**vi-mode 指示按 Esc 后卡在绿色** —— OMZP::vi-mode 没切换 `$KEYMAP`。查 `plugins.zsh` 里 `zinit snippet OMZP::vi-mode` 是否还在（同步加载，不走 Turbo —— vi-mode 得在第一个 prompt 之前绑好按键）。

**颜色看起来不对** —— `palette = 'catppuccin_mocha'` 但某段引用了色板里没有的名字。Starship 会静默回退到终端默认前景。grep 配置里可疑的颜色名，对比 `[palettes.catppuccin_mocha]`。

**`starship prompt` 在脚本里卡住** —— 少见，但 `$cmd_duration` 或 `$custom` 可能调起慢子进程。交互 shell 里跑 `starship timings` 看是谁。

## Gotchas

**Starship init 必须在 `OMZP::vi-mode` 之后。** `tools.zsh` 顺序：fzf → zoxide → starship；`plugins.zsh` 同步加载 vi-mode。顺序反了 `vimcmd_symbol` 会绑到未初始化的 `$KEYMAP`，指示永远不切。

**Catppuccin 的颜色名不通用。** Mocha **没有** `orange` 也**没有** `purple`。旧配置里 `orange = "#cba6f7"`（其实是 mauve 的 hex）和 `bg:purple` 都是坏的，静默回退到终端默认。本 phase 修复了 —— 加 module 时只引用 `[palettes.catppuccin_mocha]` 里存在的名字。

**`starship prompt` 在非 TTY 下输出的是 ANSI code 不是字形。** 自动化测试 grep 的是字面 `✘`、`took` 等字符，格式串改了就得同步改测试。

## 从零重建

```bash
# 没东西要清 —— starship 无状态。重新 apply 即可：
chezmoi --source ~/.dotfiles apply
```

`starship init zsh` 没执行？先确认 starship 在 PATH 上（`brew install starship`），再确认 `tools.zsh` 里带守卫的那块还在。
