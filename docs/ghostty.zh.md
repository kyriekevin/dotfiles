# Ghostty

> 中文 · [English](ghostty.md)

Mitchell Hashimoto 做的 GPU 加速 macOS 终端。选它而非 iTerm2/Alacritty/WezTerm 的原因：原生 **splits + tabs + quick-terminal + Kitty 图像协议**，覆盖了以前需要 tmux 的场景。Claude Code 越来越默认跑在单进程终端里，移除 tmux = 移除一整层"谁拥有我的剪贴板 / 图像协议 / 快捷键"的不确定性。

## 组件分布

| 组件 | 位置 | 说明 |
|---|---|---|
| 配置 | `~/.config/ghostty/config` ← 源 `dot_config/ghostty/config` | 单文件 `key = value`。`ctrl+s > r` 重载，或下次启动生效。 |
| 二进制 + app | `/Applications/Ghostty.app`，CLI 在 `/opt/homebrew/bin/ghostty` | Brewfile 里 `cask "ghostty"` 装。 |
| 字体 | `Maple Mono NF CN` | 通过 `cask "font-maple-mono-nf-cn"` 装。和 starship（Phase 4a）锁同一个。 |
| 主题 | `Catppuccin Mocha`（内置） | 不需要额外 flavor 安装 —— `ghostty +list-themes` 里自带。 |
| Scrollback | 内存环形缓冲 | `scrollback-limit = 10000` 行/surface。不落盘。 |

## 为什么这么选

**为什么不用 tmux？** Ghostty 原生 tabs + splits 替代 tmux 的 windows + panes，`window-save-state = always` 替代 `tmux-resurrect`，Kitty 图像协议替代 tmux 的图像透传痛点。shell 和 GPU 之间少一层 = 重绘更快 + yazi 图像预览直接能用。

**为什么 `ctrl+s` 做 chord 前缀？** 三个约束交汇：
1. 本机 **Karabiner** 全局把 `Ctrl+h/j/k/l` 映射成方向键。Ghostty 里任何裸 `ctrl+hjkl` 绑定都拿不到信号。
2. HHKB 布局下用户更喜欢 `Ctrl`（位于 Caps Lock 位 —— 小指本位）而非 `Cmd`。
3. 用户此前 tmux prefix 就是 `ctrl+s`，肌肉记忆已在。

Chord 前缀一次性解决三者：`ctrl+s` 之后的键是单字母，Karabiner 不拦；Ghostty 在 PTY 之前拦截 keybind，所以历史上 `ctrl+s` 触发的 XOFF（冻结输出）在这里不会发生。

**为什么 `Maple Mono NF CN`（非斜体）？** Starship（Phase 4a）需要 NF 字形（powerline 三角、MDI mac 图标、feedback 字符）；本仓库 zsh 源都是 ASCII，所以 CN 的 CJK 覆盖不会有坏处。正文斜体会让纯文本略显杂乱 —— 我们希望正文保持正体，需要斜体的代码段自己声明。

## 两分钟上手

1. **启动**：Spotlight 打开 Ghostty，或者在任何地方按 `⌘ + \`` 唤出下拉式 quick-terminal。
2. **Prefix**：`Ctrl+s`。按住 ctrl 点 s，松开两者，然后点下一个键。超时约 1 秒。
3. **左右分屏**（新分屏在右）：`Ctrl+s  |`（shift+backslash）。**上下分屏**（新分屏在下）：`Ctrl+s  -`。
4. **分屏间跳**：`Ctrl+s  h/j/k/l` —— 和 vim 一致；因为在 chord 之后，Karabiner 不干扰。
5. **新 tab**：`Ctrl+s  c`。**关闭当前 surface**（分屏或 tab）：`Ctrl+s  x`。
6. **当前分屏最大化**：`Ctrl+s  z`。再按一次取消。
7. **重载配置**：编辑本文件后 `Ctrl+s  r`。无需重启。

某个键无反应？见 [排错](#排错) —— 通常是 Karabiner 先吃掉了。

## 键位表

前缀 `Ctrl+s`。所有 chord 绑定 = "先按前缀，再按列出的键"。无前缀的会标注 `[global]`。

### Tabs（≈ tmux windows）

| 键 | 动作 |
|---|---|
| `c` | 新 tab |
| `n` / `p` | 下一个 / 上一个 tab |
| `1`..`9` | 跳到第 N 个 tab |
| `x` | 关闭当前 surface（分屏也适用） |

### Splits（≈ tmux panes）

| 键 | 动作 |
|---|---|
| `\|`（shift+`\`） | 左右分屏（新分屏在右） |
| `-` | 上下分屏（新分屏在下） |
| `h` / `j` / `k` / `l` | 焦点向左 / 下 / 上 / 右移 |
| `z` | 切换最大化（当前分屏占满 tab） |
| `=` | 均分所有分屏 |
| `x` | 关闭当前分屏 |

### 杂项

| 键 | 动作 |
|---|---|
| `r` | 重载 `~/.config/ghostty/config` |
| `[` | 滚动到 scrollback 顶部 |

### 全局 / Ghostty 默认（无前缀）

| 键 | 动作 |
|---|---|
| `⌘ + \`` | 切换 quick-terminal 下拉（全局 —— 其他 app 里也响应） |
| `⌘ + c` / `⌘ + v` | 复制 / 粘贴（默认） |
| `⌘ + +` / `⌘ + -` / `⌘ + 0` | 字号增 / 减 / 重置（默认） |
| 鼠标拖选 | 选中即复制到剪贴板（`copy-on-select = clipboard`） |

## 特性细节

### Quick-terminal（`⌘ + \``）

屏幕顶部下拉，跟随鼠标所在屏幕（多显示器时很方便）。任意 app 里唤起，失焦自动隐藏。适合一次性命令：`curl ifconfig.me`、临时 `grep`、用 `python -c` 当计算器。配置：

- `quick-terminal-position = top` —— 从顶边滑下
- `quick-terminal-screen = mouse` —— 用光标所在显示器
- `quick-terminal-autohide = true` —— 点别处就隐藏
- `quick-terminal-animation-duration = 0.15` —— 干脆不拖泥带水

### `window-save-state = always`

退出时 Ghostty 序列化当前 tab/split 布局 + cwd + shell 历史位置。下次启动原样恢复。Mac 睡眠/重启时很好用 —— 长 `cargo build` 或 `claude-code` 会话接着用。

### Shell 集成（`shell-integration = detect`）

Ghostty 检测到 zsh/bash/fish 后自动注入前导脚本。解锁：
- **Cwd 汇报**：新分屏/tab 继承当前目录。
- **Prompt-hook 标记**：可以 `jump_to_prompt` 跳到上一个 prompt（默认未绑定；如需，加 `keybind = ctrl+s>u=jump_to_prompt_previous`）。
- **退出码感知**：为后续"根据上次退出码改光标颜色"这类功能铺路。

### 剪贴板粘贴保护

`clipboard-paste-protection = true` —— 粘贴看起来危险的内容（含换行或控制字符）时弹窗确认。挡住经典的"粘贴 `curl example.com/install.sh | sudo bash` 意外触发"。`clipboard-paste-bracketed-safe = true` 让不声明支持的 shell/app 走非 bracketed paste —— 防止粘贴到老旧程序里乱码。

### 透明标题栏 + 模糊

`macos-titlebar-style = transparent` + `background-opacity = 0.8` + `background-blur-radius = 20` —— 内容像浮在磨砂玻璃上。壁纸保留为柔和背景，窗口不是一整块不透明板。觉得透明伤对比度：把 `background-opacity` 调到 `0.9`。

## 改一个设置

1. 编辑 `~/.config/ghostty/config`（或本仓库 `dot_config/ghostty/config` 后 `chezmoi apply`）。
2. 在开着的 Ghostty 里：`Ctrl+s r`。无需重启。
3. 改得不合法：Ghostty 会横幅报错但保留旧值 —— 不会静默崩坏。
4. CLI 验证（不启动 Ghostty）：`ghostty +validate-config --config-file=~/.config/ghostty/config`。

## 加一个快捷键

Chord 语法：`keybind = ctrl+s>KEY=ACTION[:ARG]`。例子：

```
# Ctrl+s 再按 w → 把 scrollback 写入文件
keybind = ctrl+s>w=write_scrollback_file

# Ctrl+s 再按 b → 跳到上一个 prompt（需要 shell-integration）
keybind = ctrl+s>b=jump_to_prompt:-1

# 全局（任意 app 里响应）：Cmd+option+space → quick-terminal
keybind = global:cmd+opt+space=toggle_quick_terminal
```

列出所有动作：`ghostty +list-actions`。列主题：`ghostty +list-themes`。列字体：`ghostty +list-fonts`。

**避免裸 `ctrl+hjkl`** —— 本机 Karabiner 在 Ghostty 看到之前就拦截了。放到 chord 前缀后面。

## 健康检查

### 自动化
```bash
bash tests/ghostty.sh
```
返回 0 当且仅当下面全部绿：`ghostty` 在 PATH、配置能解析、chord 前缀绑定了 hjkl/c/x/r、无残留裸 `ctrl+hjkl`、Maple 字体 + Mocha 主题可被 Ghostty 发现。~1 秒。

### 手动（需要一个真的 Ghostty 窗口 —— 视觉保真）
- [ ] **主题**：颜色和 `bat test.md` 输出一致。背景是 Mocha 的 `base`（#1e1e2e），不是纯黑。
- [ ] **字体**：starship prompt 的 powerline 三角无缝衔接。CJK（`echo 你好`）对齐到单元格边界，不是半宽压扁。
- [ ] **透明 + 模糊**：能看到壁纸，略磨砂（不是清晰）。
- [ ] **标题栏**：顶部没有可见 chrome 条 —— 标题栏融进背景。
- [ ] **Quick-terminal**：从任意 app 按 `⌘ + \`` 从顶部落下细条终端；再按或点别处消失。
- [ ] **Chord 前缀**：`Ctrl+s  c` 开新 tab。`Ctrl+s  |` 左右分屏。`Ctrl+s  h/l` 切换焦点。
- [ ] **最大化**：`Ctrl+s  z` 让焦点分屏占满 tab；再按恢复。
- [ ] **Karabiner 共存**：任意分屏里按裸 `Ctrl+h` —— 光标左移一字符（方向键行为），不是删前一个词。如果是删词，说明 Karabiner 规则没生效 —— 看 `~/.config/karabiner/`。
- [ ] **重载**：改配置（`font-size = 13`），`Ctrl+s  r`，字体立刻变大不用重开。
- [ ] **退出重启**：两个 tab 各带分屏，`⌘ + q` 退出，重开 —— 布局复原。
- [ ] **图像预览**（yazi）：`y` → 选个 `.png`/`.jpg` → 预览栏渲染真实图像，不是文本占位符。

## 排错

**Chord 没反应（按 `Ctrl+s` 再按键没动静）**
- 超时：`Ctrl+s` 之后 ~1 秒丢弃前缀。第二键按快点。
- 被其他 app 抢走 `Ctrl+s`：看系统设置 → 键盘 → 快捷键，或 Karabiner 规则。
- 配置笔误：跑 `ghostty +validate-config --config-file=~/.config/ghostty/config`，按报错改。

**`Ctrl+s` 冻住了 shell 输出**
- 理论上不会 —— Ghostty 在 PTY 之前拦截 keybind。若真发生，说明配置没生效。`Ctrl+s  r` 或重启 Ghostty。
- 如果你加了透传（`ctrl+s>ctrl+s=text:\x13`），那就是发了字面 XOFF。在受影响 shell 里跑 `stty -ixon` 关流控，或删掉透传。

**字体发虚 / 有缝**
- `ghostty +list-fonts | grep "^Maple Mono NF CN$"` —— 空就是 cask 没装成。`chezmoi apply`（触发 brew bundle）或直接 `brew install --cask font-maple-mono-nf-cn`。
- 字体列出来了但 Ghostty 渲染错位：`atsutil databases -remove`（清 macOS 字体缓存），重启 Ghostty。

**Quick-terminal 全局热键不响应**
- 系统设置 → 隐私与安全 → 辅助功能 → 允许 Ghostty（全局热键捕获需要）。
- 被其他 app 占用 `⌘ + \``：改配置里 `keybind = global:cmd+grave_accent=...`。

**yazi 图像预览显示占位符而非图像**
- 看 `TERM`：`echo $TERM` 应该是 `xterm-ghostty`。如果是 `xterm-256color`（我们强制的值），yazi 会 sniff `TERM_PROGRAM=ghostty` 来判定 Kitty 协议，看 `echo $TERM_PROGRAM`。
- 经 `ssh` / `tmux` 转发的话，两层都不原生透传 Kitty 图像协议。图像预览请在本地 Ghostty 里用。

**Chezmoi apply 没更新在开的 Ghostty**
- Ghostty 不主动 watch 配置文件：下次启动或 `Ctrl+s  r` 才重读。`chezmoi apply` 只是改文件。

## 踩坑

- **这里没有 tmux** —— 肌肉记忆 `Ctrl+b c` 开新 window 会毫无反应。前缀是 `Ctrl+s`。
- **`Ctrl+s` 前缀只在绕过 Ghostty 时才触发字面 XOFF** —— `ssh` 到服务器时会发生（服务器端在 PTY 前看到 `Ctrl+s` 冻住），本地 Ghostty 分屏里不会。远程 session 里，要么登录后跑 `stty -ixon`，要么远程工作用 `Cmd+s`-形状的绑定。
- **Tab 号 `1..9` 只覆盖 1-9** —— 没有 `0` 到第 10 个 tab。≥10 个 tab 用 `Ctrl+s  n/p` 走。
- **均分分屏（`Ctrl+s  =`）均整棵树而非当前层** —— 嵌套分屏树里，`=` 把所有尺寸重置为均等，不只当前层。
- **`copy-on-select = clipboard` 每次鼠标拖选都覆盖剪贴板** —— macOS 上没有独立的 selection buffer，所以如果你拖选一下只是想重读一遍，剪贴板里之前的东西就没了。重要内容用 `Cmd+c` 主动留。

## 从零重建

全新 Mac 或空 `~/.config`：

```bash
# 1. cask 安装（brew bundle 通过 Brewfile 覆盖）
brew install --cask ghostty font-maple-mono-nf-cn

# 2. 配置到位
chezmoi apply   # 从 dot_config/ghostty/config 写到 ~/.config/ghostty/config

# 3. 启动一次让 macOS 登记
open -a Ghostty

# 4. 首次辅助功能权限（quick-terminal 全局热键）
#    系统设置 → 隐私与安全 → 辅助功能 → 勾选 Ghostty

# 5. 验证
bash tests/ghostty.sh
```

`tests/ghostty.sh` 通过后，再走一遍手动 checklist 确认视觉保真 —— 自动测试看不见颜色/模糊/透明度。
