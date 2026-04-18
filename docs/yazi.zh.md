# Yazi

> [English](yazi.md) · 中文

Rust 写的高速 TUI 文件管理器。三栏布局（父目录 / 当前 / 预览）、vim 风键位、原生图片/视频/PDF 预览、内建 `fzf` / `zoxide` / `fd` / `rg` 集成。绑在 `y` 上（是 zsh 函数不是 alias —— 见下）—— 退出 yazi 后 shell 自动 cd 到你最后停留的目录。

## How it works

| 东西 | 位置 | 说明 |
|---|---|---|
| 配置 | `~/.config/yazi/yazi.toml` ← 源 `dot_config/yazi/yazi.toml` | 管理器/预览/opener。每次启动重读 —— 无 daemon |
| Keymap | `~/.config/yazi/keymap.toml` ← 源 `dot_config/yazi/keymap.toml` | `prepend_keymap` 叠在 yazi 默认键位上 |
| Theme | `~/.config/yazi/theme.toml` ← 源 `dot_config/yazi/theme.toml` | 启用 `catppuccin-mocha` flavor（UI 配色 + 预览语法高亮的 tmTheme）|
| Init | `~/.config/yazi/init.lua` ← 源 `dot_config/yazi/init.lua` | 插件 bootstrap（`full-border` + `git`）|
| 插件目录 | `~/.config/yazi/plugins/` | 由 `.chezmoiscripts/run_onchange_after_40-yazi-plugins.sh` 里的 `ya pkg add` 填充。**不入 source** —— 每次 apply 重新生成 |
| Flavor 目录 | `~/.config/yazi/flavors/` | 同上机制，存完整主题包（`catppuccin-mocha`）。**不入 source** |
| Shell wrapper | `~/.config/zsh/tools.zsh` → `y()` 函数 | 跑 `yazi --cwd-file=$tmp`，退出时父 shell cd 到 yazi 的最后 CWD |
| 缓存 | `~/.cache/yazi/` | 图片/视频缩略图。随便删 —— 下次预览自动重建 |

## 核心概念

动手之前理解这几个点能省事：

**两个 binary，一个 brew。** `brew install yazi` 同时安装 `yazi`（TUI）和 `ya`（控制通道 —— 给 `ya pkg` 装插件、`ya emit` 发脚本事件用）。手动调用 `ya` 的场景极少，插件管理会自动用。

**三栏，一组比例。** `[mgr] ratio = [1, 3, 4]` —— 父 / 当前 / 预览。预览最宽是因为图片/视频/代码高亮都在那。光标在预览栏时 `h`/`l` 调宽度。

**Opener 是规则匹配，不是硬编码。** "`<Enter>` 打开文件"不是写死某个命令 —— yazi 从上到下扫 `[open] prepend_rules`，第一个 `mime` / `name` 匹配的赢，它的 `use = [...]` 决定用 `[opener]` 里哪个块。所以我们能让 `.sh` 走 nvim，但其他二进制文件照样交给 macOS Launch Services。

**Plugin vs Flavor。** **Plugin** 加行为（新 previewer、键位、状态列）。**Flavor** 是完整主题包（UI 配色 + 语法高亮 tmTheme）。两者都走 `ya pkg add` 安装。我们装 3 个 plugin（`git` / `smart-enter` / `full-border`）+ 1 个 flavor（`catppuccin-mocha`）—— flavor 让 yazi 的预览语法色和 bat / starship / fastfetch 对齐，终端栈配色统一。

**终端图片协议。** yazi 通过 `$TERM` / `$TERM_PROGRAM` 决定图片渲染协议。Ghostty 原生支持 **Kitty graphics protocol** → 像素级 inline 图，零额外依赖。其他终端静默降级：iTerm2 → iTerm2 协议；tmux 无 passthrough → chafa fallback；Apple Terminal → 无图。

## 5 分钟上手

1. 启动：任意 shell 里打 `y`。
2. 导航：`j`/`k` 上下，`h` 退出目录，`l` 进目录或打开文件（`smart-enter` 插件）。
3. 看到一堆目录飞过：`.` 切换隐藏文件显示。
4. 多选：`space` 单个切换；`v` visual 区间选。
5. 复制+粘贴：定位到源，`y`，定位到目标，`p`。
6. 单个 rename：`r`，改名，Enter。
7. **批量 rename**：多选（`space`）→ `r` → yazi 把所有选中的文件名写进 `$EDITOR` → 逐行改 → 保存 → yazi 按 diff 改名。
8. 搜索：`/` 当前目录 filename grep；`s` 用 fd 全盘找；`S` 用 rg 全文搜。
9. 跳转：`z` zoxide（按访问频次）；`Z` fzf（所有目录模糊）。
10. 用 fzf 找文件并打开：`Z` → 输片段 → Enter → `l`。
11. 退出：`q` → shell cd 到 yazi 最后停留的目录。`Q` 退出但不 cd。

第 1 步如果报 `command not found`，跑 `chezmoi apply` —— Brewfile + 插件安装都在那一步。

## Keymap 全集

我们的 `keymap.toml` 只覆盖了 `l` / `<Enter>`（交给 `smart-enter`），其余全是 yazi 默认。在 yazi 里按 `~` 可以看实时 help。

### 导航

| 键 | 动作 |
|---|---|
| `h` / `j` / `k` / `l` | 左/下/上/右（l = smart-enter） |
| `gg` / `G` | 顶/底 |
| `Ctrl+u` / `Ctrl+d` | 半页上/下 |
| `H` / `L` | 历史后退/前进 |
| `Tab` | 切到下一 tab |
| `t` | 在光标位置新开 tab |
| `1`..`9` | 跳到第 N tab |
| `[` / `]` | 上/下一个 tab |

### 选择

| 键 | 动作 |
|---|---|
| `space` | 光标处切换选中 |
| `v` | 进入 visual 选择模式 |
| `Ctrl+a` | 全选当前目录 |
| `Ctrl+r` | 反选 |
| `Esc` | 清空选择 |

### 文件操作

| 键 | 动作 |
|---|---|
| `y` | 复制（yank）所选 |
| `x` | 剪切所选 |
| `p` | 粘贴到当前目录 |
| `P` | 粘贴并覆盖 |
| `d` | 移动到回收站 |
| `D` | 永久删除（不进回收站）|
| `a` | 新建；末尾 `/` = 新建目录 |
| `r` | rename（多选 → 批量 rename via `$EDITOR`）|
| `c` | 复制完整路径到剪贴板（子菜单）|

### 搜索 / 跳转

| 键 | 动作 |
|---|---|
| `/` | 当前目录过滤（文件名子串）|
| `?` | 反向过滤 |
| `n` / `N` | 下/上一匹配 |
| `s` | 按文件名搜索（走 `fd`）|
| `S` | 按内容搜索（走 `rg`）|
| `z` | zoxide 跳转（需装 zoxide）|
| `Z` | fzf 跳转（需装 fzf）|
| `f` / `F` | 当前目录找下/上一个 |

### 预览 / 布局

| 键 | 动作 |
|---|---|
| `K` / `J` | 预览栏滚上/下 |
| `T` | 切换预览栏 |
| `,` | 排序子菜单（a/c/m/s/e，`r` 反向）|
| `M` | linemode 子菜单（size / ctime / mtime / 权限 / owner / none）|
| `.` | 切换隐藏文件 |

### 任务 / shell

| 键 | 动作 |
|---|---|
| `w` | 任务管理器（后台拷贝、解压）|
| `:` | 命令面板（跑 yazi 内部命令）|
| `!` | 跑 shell 命令，阻塞 yazi |
| `Shift+!` | 在当前目录开 shell |
| `Esc` | 关菜单 / 退出模式 |
| `q` | 退出；shell cd 到 yazi 最后目录 |
| `Q` | 退出但不 cd |

### Spot（文件元信息面板）

| 键 | 动作 |
|---|---|
| （光标对准文件）+ `Tab` | 循环元信息面板（file / EXIF / 链接目标）|

## Shell wrapper `y()`

yazi 作为 "cd 器" 的标准模式。没这个 wrapper，`yazi` 就只是跑起来看看然后退出，你还在原来的目录。有了它：

```zsh
y() {
    local tmp cwd
    tmp="$(mktemp -t 'yazi-cwd.XXXXXX')"
    yazi "$@" --cwd-file="$tmp"           # yazi 退出时把最后 CWD 写进这个文件
    if cwd="$(command cat -- "$tmp")" && [[ -n $cwd && $cwd != "$PWD" ]]; then
        builtin cd -- "$cwd"              # 父 shell 跟过去
    fi
    rm -f -- "$tmp"
}
```

为什么 `command cat` 和 `builtin cd`：我们 `aliases.zsh` 把 `cat` 绑成 `bat`（带色），zsh 也可能被用户 patch 掉 `cd`。绕开 alias 和函数重载，wrapper 在被别人魔改的环境里也稳。

## 插件 + Flavor

列在 `.chezmoiscripts/run_onchange_after_40-yazi-plugins.sh` 里。加/删一行 → 脚本内容 hash 变 → chezmoi 下次 apply 重跑 → 调 `ya pkg add`。`ya pkg add` 幂等：已装的包静默 skip，重跑成本 ~0。

| 包 | 类型 | 作用 | 怎么接上的 |
|---|---|---|---|
| `yazi-rs/plugins:git` | plugin | 文件列表左侧显示 git 状态字符（`M` 改过、`A` 新增、`?` 未跟踪、`!` ignored）| `yazi.toml [plugin.prepend_fetchers]` 注册 fetcher；`init.lua` 调 `require("git"):setup({ order = 1500 })` |
| `yazi-rs/plugins:smart-enter` | plugin | 统一 `l` + `<Enter>`：目录就 cd 进去，文件就触发 opener。不用再想"这里该按 `l` 还是 `<Enter>`" | `keymap.toml [mgr] prepend_keymap` 把两个键都绑到 `plugin smart-enter` |
| `yazi-rs/plugins:full-border` | plugin | 三栏外圈加圆角边框。纯视觉 polish | `init.lua` 调 `require("full-border"):setup()`。删掉这一行边框立刻消失 |
| `yazi-rs/flavors:catppuccin-mocha` | flavor | 完整 UI 配色 + syntect 预览的 tmTheme —— 和 bat（`$BAT_THEME`）、starship、fastfetch 对齐，终端栈整体一套色 | `theme.toml [flavor] dark = "catppuccin-mocha"` |

### git fetcher 语法陷阱

git 插件的 fetcher key 是 `url`，**不是** `name`。yazi 静默接受 `name`，但 fetcher 永远不触发，git glyph 就悄悄没了。如果你发现 gutter 里没 `M`/`A`/`?`，先查 `yazi.toml`：

```toml
# 正确写法 —— yazi ≥26
[[plugin.prepend_fetchers]]
id    = "git"       # yazi > 26.1.22 可省（见插件 README）
url   = "*"         # ← 是 url，不是 name
run   = "git"
group = "git"
```

`tests/yazi.sh` 的 `fetcher uses url= (not name=)` 回归保护就是针对这个 —— 因为我们第一次上线就踩过。

## 预览后端

yazi 在渲染时按 `$PATH` 探测这些工具。都走 Brewfile 装 —— 缺哪个就该文件类型静默降级成纯文本（或二进制文件根本没预览）。

| 文件类型 | 后端 | Brewfile |
|---|---|---|
| 图片 (PNG/JPG/GIF/WebP) | Kitty graphics protocol（built-in）| — |
| 图片 (HEIC/RAW/冷门格式) | `magick` 转换 → Kitty | `imagemagick` |
| 视频 (MP4/MOV/MKV) | `ffmpegthumbnailer` 抽首帧 → Kitty | `ffmpegthumbnailer` |
| PDF | `pdftoppm` 渲首页 → Kitty | `poppler` |
| 归档 (zip/7z/tar/rar) | `7z l` 列目录 | `sevenzip` |
| 代码 / 文本 | yazi 内建 syntect —— 按激活的 flavor 的 tmTheme 上色 → 和 bat 一致 | — |
| JSON | `jq` 美化（yazi built-in）| — |
| 符号链接 | 目标路径 + 跟穿后预览 | — |

## 改一项

1. 编 `dot_config/yazi/yazi.toml`（或 `keymap.toml` / `init.lua`）。
2. 无需 reload —— yazi 每次启动重读三个文件。退出 yazi 再 `y` 就好。
3. 结构性改动（新 section、改 fetcher id），跑 `tests/yazi.sh` 捕捉静默 breakage。

## 加一个插件

1. `.chezmoiscripts/run_onchange_after_40-yazi-plugins.sh` 里加一行：

    ```bash
    plugins=(
        "yazi-rs/plugins:git"
        "yazi-rs/plugins:smart-enter"
        "yazi-rs/plugins:full-border"
        "your-user/your-plugin:name"    # ← 新的
    )
    ```

2. 如果是 **previewer / fetcher / preloader**，在 `yazi.toml` 里接：

    ```toml
    [plugin]
    prepend_previewers = [
      { mime = "image/*", run = "your-plugin" },
    ]
    ```

3. 如果是 **可绑键的命令**，在 `keymap.toml`：

    ```toml
    [[mgr.prepend_keymap]]
    on  = "X"
    run = "plugin your-plugin"
    ```

4. 如果需要 **启动时 setup**，`init.lua` 里加 `require("your-plugin"):setup()`。
5. `chezmoi apply` —— `run_onchange` hook 触发，`ya pkg add` 把它装上。

## 健康检查

### 自动化

```bash
bash tests/yazi.sh
```

~24 条检查：binary 在 PATH（`yazi`、`ya`）、配置 + keymap + init.lua 存在、TOML 能 parse（python3 ≥ 3.11 时）、关键 section / key 齐全、预览后端可用（`ffmpegthumbnailer`、`magick`、`pdftoppm`、`7z`）、插件目录 `~/.config/yazi/plugins/` 下有货（没 apply 过会 skip 并提示）、Ghostty 检测提示。

### 手动（需要真实 TTY）

1. 新 Ghostty tab 里：`y`。
2. 三栏布局，带**圆角边框**（`full-border` 插件起效）。
3. 在 git repo 里逛 —— 修改过的文件左侧挂彩色 `M` / `A` / `?` 字符（`git` 插件）。
4. `l` 在目录上 → 进入；`l` 在文本文件上 → 打开 nvim（`smart-enter` 插件）。退出 nvim → 回 yazi。
5. 光标移到 PNG / JPG → 预览显示**真实图片**，不是 ASCII 或 `□`（Kitty 图形协议 OK）。
6. MP4 → 预览首帧缩略图（ffmpegthumbnailer → Kitty）。
7. PDF → 预览渲染过的首页（poppler → Kitty）。
8. 按 `s` 输片段 → fd 实时匹配。
9. 按 `Z` 输片段 → fzf 全目录模糊。Enter → yazi 跳过去。
10. `q` 退出 → 外壳 cd 到 yazi 最后目录（`y()` wrapper 起效）。

## Troubleshooting

**`y: command not found`** —— 当前 shell 没 source `tools.zsh`。开新 tab 或 `source ~/.zshrc`。`type y` 应返回函数定义。

**图片预览空白 / `□` / 问号** —— Ghostty Kitty 协议没送到 yazi。检查 `echo $TERM_PROGRAM` 是否 `ghostty`。在 tmux/screen 里没 passthrough 也不会渲染（已知限制 —— yazi 静默不画）。Ghostty 之外需要 chafa 或 sixel 终端，我们没装。

**PDF 预览显示文本 dump** —— `pdftoppm` 缺失。`command -v pdftoppm` 必须有。`brew bundle` 或 `brew install poppler` 补上。

**视频预览空白** —— `ffmpegthumbnailer` 缺失。`brew install ffmpegthumbnailer`。注意：DRM 视频抽不出帧，这类文件本来就不渲。

**Git 状态字符没出来** —— 两种根因：
  1. 插件没装。查 `ls ~/.config/yazi/plugins/git.yazi` 存在。没有就 `chezmoi apply`。
  2. fetcher key 写错。`yazi.toml [[plugin.prepend_fetchers]]` 要用 `url = "*"` **不是** `name = "*"` —— yazi ≥26 会静默吃掉 `name`-keyed fetcher。`tests/yazi.sh` 有回归保护；编辑后 glyph 没了就跑一下。

**预览语法色和 bat 不一致** —— flavor 没激活。查 `theme.toml` 有 `[flavor] dark = "catppuccin-mocha"`、`ls ~/.config/yazi/flavors/catppuccin-mocha.yazi` 存在。没 flavor 时 yazi 内建 syntect 走通用深色主题，和 bat 的 Mocha 配色冲突。

**`smart-enter` 不生效** —— 插件没装。查 `~/.config/yazi/plugins/smart-enter.yazi`。没有的话 `chezmoi apply` 触发 `ya pkg add`。

**边框没圆角** —— `full-border` 没装，或 `init.lua` 漏了 `setup()`。确认 `~/.config/yazi/plugins/full-border.yazi` 存在 + `init.lua` 有 `require("full-border"):setup()`。

**`ya pkg add` 第一次 apply 就挂** —— `ya` 在 `yazi` 这个 brew 里。如果 brew install 还没完成，插件 hook 会打印提示并 skip。解法：`brew bundle` → 再 apply。注：yazi ≤0.4 版本的子命令是 `ya pack -a`，本脚本针对 ≥26.x。

**打开 `.sh`/`.py` 蹦出 `Terminal.app` 不是 nvim** —— `[open] prepend_rules` 被跳过。确认 `application/x-shellscript` 那条在 `{ name = "*" }` catch-all 之前。我们 yazi.toml 顺序是对的，改的时候注意别挪到 catch-all 下面。

**批量 rename 打开了奇怪的编辑器** —— yazi 吃 `$EDITOR`。查 `echo $EDITOR` 应是 `nvim`。为空的话批量 rename UI 不弹。

**`y` wrapper 退出后不 cd** —— wrapper 只在 `$cwd` ≠ `$PWD` 时才 cd。如果你在 yazi 里没挪窝直接退出，不 cd 是预期行为。

## Gotchas

**插件安装在 chezmoi 而非 brew 里。** 只跑 `brew bundle` 不会填 `~/.config/yazi/plugins/`。要完整的 `chezmoi apply` 才会触发 `run_onchange_after_40-yazi-plugins.sh` 调 `ya pkg`。

**`run_onchange` hash 的是脚本内容不是插件列表。** 你编辑插件数组 → 脚本体变 → 重跑。但如果你绕过脚本手动 `ya pkg delete <plugin>` 卸了，chezmoi 不知道，下次 apply 不会重装。改脚本（哪怕动个注释）强制重跑。

**`$EDITOR` 必须设了批量 rename 才能用。** yazi 批量 rename 走 `$EDITOR`。我们 `env.zsh` 设了 `EDITOR=nvim` —— 如果丢了（比如 remote session 没传 env），批量 rename 静默 fallback 到坏默认。

**大图预览会爆内存。** `[tasks] image_alloc = 512 MiB` 是硬上限。100MP 以上的图超标，yazi 直接放弃渲染而不是 OOM。调这个值在"安全"和"覆盖面"之间 trade。

**Ghostty 图像协议快速滚动会丢帧。** `[preview] image_delay = 30` ms 是 debounce。调小 → 滚动更跟手；机器慢就调大避免撕裂。

**TOML 解析错误基本上是静默的。** yazi 用坏 config 照样启动，只是忽略崩的 section。`tests/yazi.sh` 在 python3 ≥ 3.11 的机器上做 TOML parse 校验，老 python 只做结构性 grep，留个心眼。

**`plugins/` 不入 chezmoi source。** 插件只在 destination 里。新 Mac clone 这个 repo 跑 `chezmoi apply` 时，`run_onchange` hook 会把它填上。别 `chezmoi add ~/.config/yazi/plugins` —— 会把几 MB 插件源码 vendored 进 repo。

## 从零重建

```bash
# 删插件缓存 + 缩略图缓存 —— yazi 下次启动自动重建：
rm -rf ~/.config/yazi/plugins ~/.config/yazi/package.toml ~/.cache/yazi ~/.local/state/yazi

# 再跑一次 apply（或者手动触发 hook）：
chezmoi apply
```

`y` 跑起来但没预览？检查：(1) `yazi` 在 PATH（`brew install yazi`），(2) `$TERM_PROGRAM=ghostty`，(3) 预览后端（`ffmpegthumbnailer`、`magick`、`pdftoppm`、`7z`）在 PATH，(4) `~/.config/yazi/plugins/` 下有插件。
