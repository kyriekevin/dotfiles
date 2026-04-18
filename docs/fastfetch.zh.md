# Fastfetch

> [English](fastfetch.md) · 中文

带 Apple logo banner 的系统信息工具。绑在 `s` 上（`aliases.zsh` 里的单字母 alias）—— 任何新 shell 跑一下就能看到机器/VM/dev 工具的当前状态。配置只有一个 JSONC 文件 + 一个 Bash helper 负责渲染 lume 子树。

## How it works

| 东西 | 位置 | 说明 |
|---|---|---|
| 配置 | `~/.config/fastfetch/config.jsonc` ← 源 `dot_config/fastfetch/config.jsonc` | 单个 JSONC，chezmoi 管 |
| lume helper | `~/.config/fastfetch/lume-status.sh` ← 源 `dot_config/fastfetch/executable_lume-status.sh` | chezmoi `executable_` 前缀自动加 +x。兼容 bash 3.2（macOS 系统 shell） |
| Alias | `~/.config/zsh/aliases.zsh` → `alias s='fastfetch'` | Phase 3 加的 |

## Layout

5 组 module，组间用 `● ● ●` powerline 圆点分隔。每组一个主色调 —— 整个面板视觉上就是几条语义带：

| 组 | 颜色 | Modules |
|---|---|---|
| Identity | green | `Account`, `os`, `Host`, `Kernel`, `Uptime`, `Packages`, `Terminal`, `TerminalFont`, `Shell` |
| Computer | yellow | `CPU`, `Usage`, `GPU`, `Memory`, `Battery`, `Swap`, `LocalIP` |
| Disk | red + magenta | `PhysicalDisk`/`Drive`, `MountedFileSystems`/`FileSystem` |
| **Dev** | cyan | `Editor` (nvim), `Claude`, `lume`（+ 按 VM 嵌套的子行） |
| Peripherals | blue | `Bluetooth`, `Monitor`, `Brightness` |

### Dev 组

放日常频繁关注的 dev 工具版本。`lume` 单独特殊处理 —— Hermes agent 跑在它上面：helper 脚本先出版本号，然后每个 VM 一行，用树形前缀 `├` / `└` 表示子项：

```
󰚩 Dev
󰈙 Editor    nvim 0.12.1
󰭹 Claude    2.1.114
󰡢 lume      0.3.8
             └ openclaw: stopped · 4c/8G · 32G/96G · nat/home
```

每个 VM 的字段：`name: status · cpu/mem · diskUsed/diskTotal · network/storage`。VM 在 running 状态会额外追加 `· <ip>`。没注册任何 VM 时只有版本号那一行。

## 改一段

1. 打开 `dot_config/fastfetch/config.jsonc` —— module 在顶层 `modules` 数组里按显示顺序排列。
2. 删 / 调序 / 直接改 —— 不用 reload，fastfetch 每次调用都重读配置。
3. 改 lume 子树：编 `dot_config/fastfetch/executable_lume-status.sh`，fastfetch 每次渲染都重跑它。

## 加一个 module

大部分 module 一行搞定：

```jsonc
{ "type": "command", "key": " mymod", "keyColor": "cyan",
  "text": "echo hello" }
```

多行输出时，fastfetch 只给**第一行**加 logo-skip + value-goto 的 ANSI 序列；后续行从终端绝对第 0 列起，会落在 logo 区。每个续行都要自己发 CHA（`\x1b[<col>G`）重新对齐 —— `lume-status.sh` 就是这么做的（`VCOL=55` = Apple logo 34 cols + key.width 21）。

## 健康检查

### 自动化

```bash
bash tests/fastfetch.sh
```

~44 条检查：fastfetch 在 PATH、config + helper 脚本存在并可执行、`s` alias 接线、prompt 渲染无 `JsonConfig` / `Error:` 字样、每个 module 都在输出里、Dev 组命令（`claude`, `lume`, `python3`）在 PATH、lume 版本能解析、lume 子行带树形前缀 + status（没注册 VM 时跳过）、schema drift 回归保护（`general.multithreading` 已被 fastfetch ≥2.x 移除、`display.bar.charElapsed` 已重命名）、每个 nerd-font PUA 码点还在 config 里（PUA 在大多数编辑器里隐形，重写时会被静默吞掉）。

### 手动（需要真实 TTY）

1. 在新的 Ghostty tab 里跑 `s`。
2. Apple logo 渲成 ASCII（不是方框）。
3. 所有 nerd-font 字形正常（󰀵 mac、󰂯 蓝牙、● 圆点），不是 `□`。
4. 5 条色带视觉上明显（green → yellow → red/magenta → cyan → blue）。
5. Dev 组里 Editor/Claude/lume 的 key 列对齐一致。
6. `lume run <vm>` 后再 `s` —— VM 子行从 `stopped` 翻到 `running · <ip>`。

## Troubleshooting

**`JsonConfig Error: ...` 启动报错** —— schema drift。fastfetch ≥2.x 改了 / 删了几个 key。已经修过的：`general.multithreading`（被删，现在默认就是多线程）、`display.bar.charElapsed` → `display.bar.char.elapsed`。新的 drift 出现时，`fastfetch --gen-config-force` 会写一份新的默认 config，可以 diff 对比。

**TerminalFont 显示 "Unknown terminal: <version>"** —— fastfetch 还没认出 Ghostty（它读 `$TERM_PROGRAM` 兜底失败）。这一行被 `display.showErrors: false` 藏住了。fastfetch 加上 Ghostty 支持后会自动好，不用在这边绕开。

**lume 行显示 `(unavailable)`** —— `lume` 不在 `PATH` 或者 CLI 挂了。先手动 `command -v lume` + `lume --version`。Brewfile 没装 lume（走 Hermes 独立安装流程）。

**启动 VM 之后 lume 子行不出现** —— `lume ls --format json` 返 null / 空。手动跑 `lume ls` 看原始状态。如果 `/usr/bin/python3` 不在（macOS 26 上少见），`lume-status.sh` 里那段 Python JSON 解析会静默无输出 —— 装 Command Line Tools。

**字形显示为 `□` 方框** —— 终端字体不是 Nerd Font。Brewfile 锁了 `font-maple-mono-nf-cn`，把终端 `font-family` 指到 `Maple Mono NF CN`。跟 starship 那边是同一个坑。

## Gotchas

**`lume-status.sh` 的 `VCOL` 和 logo + key 宽度强耦合。** `VCOL=55` = Apple logo（34 cols）+ `display.key.width`（21）。换 logo（别的 OS）或者调 `display.key.width`，`VCOL` 就得同步改 —— fastfetch 不把这些暴露给 helper，只能手动对齐。

**lume-status.sh 目标 bash 3.2。** macOS 只带 `/bin/bash 3.2`，所以没有 `mapfile`、没有关联数组。不要假设能用 bash 5 "现代化" 重写它 —— 新装的 Mac 会挂。

**PUA 码点在大多数编辑器里隐形。** 每个 nerd-font 字形都在 U+E000–U+F8FF 或 U+F0000+。把 config 复制到不保留 PUA 的格式化工具里，字形会静默变空格，`tests/fastfetch.sh` 的回归保护会响。

## 从零重建

```bash
# 没状态要清 —— fastfetch 是无状态的，重新 apply 就行：
chezmoi --source ~/.dotfiles apply
```

`s` 跑起来但没 logo / 字形？检查：(1) `fastfetch` 在 PATH（`brew install fastfetch`），(2) 终端字体是 Nerd Font，(3) `config.jsonc` 能解析（`fastfetch 2>&1 | grep -i error`）。
