# Karabiner-Elements —— 键位重映射 + 语义 sublayer

基于 Karabiner-Elements 的键盘重映射和语义化 sublayer（分层快捷键）。只版本化 `complex_modifications/*.json`；主 `karabiner.json`（设备选择、profile 状态）变动频繁，不跟踪。

## How it works

Karabiner-Elements 跑在系统内核扩展 + 用户态守护进程两层。它在**任何 app（包括终端模拟器）看到键事件之前**拦截、重写、重新注入。因为运行层级低于 app 层，这里的规则**压倒任何 app 级快捷键**。

`assets/complex_modifications/` 下两个规则文件：

- `caps.json` —— 基础层（常驻）：caps↔ctrl↔escape 重映射 + `ctrl+hjkl` → 方向键
- `sublayers.json` —— 由 `ctrl+w` / `ctrl+r` / `ctrl+x` 前缀触发的语义 sublayer

chezmoi 把两个文件写到 `~/.config/karabiner/assets/complex_modifications/`。Karabiner GUI 自动识别文件变化；但首次**导入 + 启用**必须手动走一次 GUI（`Preferences → Complex Modifications → Add rule` —— 这是 Karabiner 的激活模型决定的）。

## Why these choices

### 为什么 caps→ctrl（tap→escape）
用户在 HHKB（caps 位置 = ctrl）和 MacBook 自带键盘（ctrl 在左下角）之间切换。caps→ctrl 让 MacBook 键盘也获得 HHKB 的按位。单击→escape 复用同一个键，因为 vim/shell 用户基本用不到原生的 CAPS 切换行为。

### 为什么 ctrl+hjkl → 方向键（全局）
HHKB 没有独立方向键；笔记本上按方向键要离开 home row。`ctrl+hjkl` 在 **Karabiner 层**把 vim 式移动映射成真箭头事件——**任何 app 都能收到真箭头**，不需要 app 原生支持 vim 绑定。这条同时也是 Ghostty chord 前缀的前提（见 `docs/ghostty.zh.md`）。

### 为什么用语义 sublayer，不用单一扁平前缀
tmux 式扁平 `prefix → letter` 很快就把助记字母用完。语义 sublayer（`w` = window / `r` = raycast / `x` = system）按域分组，**每个 sublayer 的命名空间很小，字母可以跨域复用**（比如 `m` 在 `w` 里是 maximize，在 `x` 里是 mute）。

### 为什么 `ctrl` 当 leader（而不是 hyper / caps 双击 / 右 cmd）
1. caps 已被占用（→ ctrl/escape）。
2. Hyper（cmd+ctrl+opt+shift）被 Raycast 内置 Hyper Key 功能占用——保留它，让用户原有的 `hyper+space → AI Chat` 直接绑定继续工作。
3. HHKB 和笔记本上右 cmd 按起来都别扭。
4. 实际 workflow 里，大部分 `ctrl+letter` 是空的（zsh vi-mode + nvim space-leader，意味着 `ctrl+w / ctrl+r / ctrl+x / ctrl+hjkl` 除箭头映射外全部可用）。

### 为什么用 Raycast deeplink（而不是发 hotkey 组合让 Raycast 反接）
所有 Raycast 动作通过 `open -g raycast://extensions/...` 触发。这样 **Karabiner 和 Raycast 的 hotkey 注册解耦**：换成 Rectangle、Aerospace 或任意 shell 命令，只改一行 `shell_command` 字符串。`-g` flag 是**必须**的——没有它，Raycast 会抢焦点，被 resize 的窗口就不是你原来想要的那个。

### 为什么 AI Chat 保留直接 `hyper+space`（在 sublayer 之外）
AI Chat 是高频命令。走 `ctrl+r space`（两次按键）会增加用户不需要的摩擦。Raycast 内置 Hyper Key 功能**保持开启**，Raycast Extensions 里原有的 `hyper+space` 热键保留。

## Keymap 速查

### 基础层（常驻）

| 键 | 动作 |
|---|---|
| `caps_lock`（单击） | `escape` |
| `caps_lock`（按住） | `left_control` 修饰 |
| `left_control`（单击） | `escape` |
| `left_control`（按住） | `left_control` 修饰（不变） |
| `ctrl+h` | `←` |
| `ctrl+j` | `↓` |
| `ctrl+k` | `↑` |
| `ctrl+l` | `→` |

### `ctrl+w` sublayer —— 窗口管理（Raycast）

| 键 | 动作 |
|---|---|
| `h` | 左半屏 |
| `l` | 右半屏 |
| `k` | 上半屏 |
| `j` | 下半屏 |
| `m` | 最大化 |
| `n` | 下一个显示器 |
| `p` | 上一个显示器 |

### `ctrl+r` sublayer —— Raycast 命令

| 键 | 动作 |
|---|---|
| `s` | 剪贴板历史 |
| `f` | 搜索文件 |
| `;` | 翻译 |
| `e` | emoji 选择器 |

> AI Chat 有意不放在这一层——用直接的 `hyper+space` Raycast 热键。

### `ctrl+x` sublayer —— macOS 系统动作（osascript，不依赖 Raycast）

| 键 | 动作 | 重复模式 |
|---|---|---|
| `m` | 静音切换 | 单击（防止超时窗口内误按 m 双触发） |
| `=` | 音量 +10 | Sticky（`ctrl+x ==== ` → 一次 chord +40%） |
| `-` | 音量 −10 | Sticky（最后一次按键后 500ms 收层） |

## 功能细节

### Sublayer 时序模型（500ms）
按下 leader（`ctrl+w` / `ctrl+r` / `ctrl+x`）会通过 Karabiner 变量把 `layer_{w,r,x}` 置为 1。动作规则只在变量为 1 时触发——匹配 layer + 触发后把变量清零。500ms 内没后续按键，`to_delayed_action.to_if_invoked` 清零变量——**不会出现层卡住**。超时可在 `sublayers.json` → `parameters["basic.to_delayed_action_delay_milliseconds"]` 里调。

### Raycast deeplink 的 `-g` flag
Raycast 的 Window Management 扩展要求**目标 app 处于焦点状态**——不是 Raycast 自己。`open raycast://...`（无 `-g`）会短暂聚焦 Raycast，扩展看到的 frontmost 是 Raycast 本身，resize 就打到错误的窗口上。`open -g` 在"后台"打开 URL 不激活 Raycast，原焦点 app 保持焦点被正确 resize。

### 和 Ghostty `ctrl+s` chord 的共存
Ghostty 有自己的 `ctrl+s` chord 前缀（见 `docs/ghostty.zh.md`）。Karabiner sublayer 用 `ctrl+w / ctrl+r / ctrl+x`——字母完全不同，**无冲突**。在 Ghostty 里：`ctrl+s` → Ghostty chord；`ctrl+w` → Karabiner 窗口层（全局触发，不看 frontmost 是谁）。

### 和 Raycast Hyper Key 的共存
Raycast 的 Hyper Key 功能把左 option 映射成 `cmd+ctrl+opt+shift`。我们保留启用，好让用户历史上的 `hyper+space` 绑定继续给 AI Chat 用。代价：**左 option 被 Raycast 吃掉，打不出 option 修饰的字符**。右 option 不受影响。

## 改配置

1. 编辑 `dot_config/karabiner/assets/complex_modifications/*.json`
2. `chezmoi diff` → `chezmoi apply`
3. Karabiner GUI 自动识别文件变化；已启用的规则立即生效
4. 如果**新加**了规则：需要 `Preferences → Complex Modifications → Add rule` 再启用一次

## 加一个新 sublayer 动作

例子：给 `ctrl+r` 层加 `c` → 打开 Calendar。

```json
{
    "type": "basic",
    "from": { "key_code": "c", "modifiers": { "optional": ["any"] } },
    "to": [
        { "shell_command": "open -g 'raycast://extensions/raycast/calendar/my-schedule'" },
        { "set_variable": { "name": "layer_r", "value": 0 } }
    ],
    "conditions": [
        { "type": "variable_if", "name": "layer_r", "value": 1 }
    ]
}
```

追加到对应 `ctrl+r layer:` 规则的 `manipulators` 数组里。用 `karabiner_cli --lint-complex-modifications sublayers.json` 校验。

## 健康检查

### 自动化（`tests/karabiner.sh`）

```bash
bash ~/.dotfiles/tests/karabiner.sh
```

覆盖：

- Karabiner-Elements 已装 + `karabiner_cli` 在 PATH
- 两个 JSON 文件存在、`jq` 可解析、Karabiner 官方 linter 通过
- 基础层和 sublayer 的每条绑定都指向预期动作（回归护栏）
- 三个 leader 都有 `to_delayed_action` 且超时都是 500ms
- AI Chat **不**在 `ctrl+r` 层（按设计保留为直接 hyper+space）

### 手动（Manual）—— 首次安装必须走

自动化测试只验证 JSON。真正的运行时效果要求 Karabiner **导入 + 启用**了规则：

1. `chezmoi apply` 把 JSON 写到 `~/.config/karabiner/assets/complex_modifications/`
2. 打开 Karabiner-Elements → **Preferences → Complex Modifications → Add rule**
3. 每组（caps / sublayers）下点 **Enable All**
4. 走一遍 checklist：

- [ ] 单击 `caps_lock` → `escape` 触发（Notes 里验证：caps 不该切换 CAPS）
- [ ] 按住 `caps_lock` + `a` → `ctrl+a` 触发（终端里：跳到行首）
- [ ] `ctrl+h/j/k/l` → 方向键（任何文本框）
- [ ] `ctrl+w h` → 窗口左半屏（Raycast 首次弹确认 → 点 "Always Allow"）
- [ ] `ctrl+w l/k/j/m/n/p` → 右/上/下/最大/下一显示器/上一显示器
- [ ] `ctrl+r s` → 剪贴板历史打开
- [ ] `ctrl+r f/;/e` → 搜索文件 / 翻译 / emoji 选择器
- [ ] `ctrl+x m` → 静音切换（菜单栏图标变化）
- [ ] `ctrl+x = / -` → 音量 +10 / −10
- [ ] 按 `ctrl+w` 单独，等 1s，再按 `h` → 无反应（超时清层）
- [ ] AI Chat 仍然靠 `hyper+space` 触发（直接，不走 sublayer）

### Raycast 首次确认

每个 Raycast deeplink 首次触发都会弹一次确认框。每一个（clipboard / search-files / translate / emoji / 7 个 window 动作）都点 **Always Allow**——设置持久化到 Raycast 的 `alwaysAllowCommandDeeplinking` plist 里。勾一次之后后续静默运行。

## 排障

**`chezmoi apply` 之后规则没生效。**
Karabiner 的导入是一次性的。`chezmoi apply` 写文件，但不会自动启用。打开 Karabiner GUI → Complex Modifications → Add rule → Enable。

**`ctrl+w h` 触发了，但 resize 了错误的窗口。**
`open` 命令漏了 `-g` flag。检查 `sublayers.json`——每个 `window-management` deeplink 的 `shell_command` 都必须是 `open -g 'raycast://...'`。

**Sublayer 键"卡住"——下一个按键还在层模式里。**
要么 leader 规则漏了 `to_delayed_action`，要么动作规则的 `to` 数组里漏了 `{"set_variable": {"name": "layer_X", "value": 0}}`。跑 `bash tests/karabiner.sh`——`timeout = 500ms` 检查就是抓这个的。

**`ctrl+hjkl` 不发箭头了。**
Karabiner 守护进程可能没跑。`pgrep -f karabiner_console_user_server`——输出为空就去启动 Karabiner.app。

**AI Chat 的 `hyper+space` 失效了。**
检查 Raycast → Preferences → Advanced → Hyper Key 是否仍为开启。本 phase 有意保留 Raycast Hyper Key。

## Gotchas

- **主 `karabiner.json` 不跟踪。** 设备选择、profile 名、per-device 微调都在那里，变动太频繁。只版本化 `complex_modifications/*.json`。
- **每台机器都要手动导入一次。** Karabiner 的激活模型不会自动启用 assets 目录里的规则——必须手动点一次 GUI。
- **Raycast 首次确认。** 每个 deeplink 第一次触发要点一次确认框。fresh install 大概 ~12 次点击。
- **左 option 被 Raycast 吃掉。** 因为 Raycast Hyper Key 保持开启，左 option 不能输出 option 修饰的字符。右 option 不受影响。
- **Karabiner 内核扩展需要授权。** macOS 新装时 System Settings → Privacy & Security → Input Monitoring + Accessibility 都要授予 Karabiner 权限。

## 从零重建

```bash
# 1. Brewfile 里装 Karabiner（已列）
brew bundle --file=~/.dotfiles/Brewfile

# 2. System Settings → Privacy & Security 授权
#    - Input Monitoring → Karabiner-Elements
#    - Accessibility → Karabiner-Elements

# 3. 应用 dotfiles
chezmoi apply

# 4. 打开 Karabiner-Elements GUI → Complex Modifications → Add rule
#    把 "Base layer" 和 "Sublayers" 下所有规则启用

# 5. 验证
bash ~/.dotfiles/tests/karabiner.sh        # 静态：37 项检查
# 之后走 docs/karabiner.zh.md → 健康检查 → Manual
```
