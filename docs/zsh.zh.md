# Zsh 操作手册

> [English](zsh.md) · 中文

zsh + zinit Turbo。目标：启动快（插件缓存后 critical path 约 70-100ms）、加载顺序可预测、模块职责单一 —— 每个文件只做一件事。本文是操作员手册：如何扩展、debug、重建。

## How it works

### 入口

| 文件 | 被哪种 zsh 读 | 职责 |
|---|---|---|
| `~/.zshenv` | 任何 zsh（login、interactive、subshell、script） | PATH baseline、EDITOR、LANG |
| `~/.zshrc` | 仅交互式 zsh | orchestrator —— 按顺序 source 模块，不做别的 |

### 模块（`~/.config/zsh/*.zsh`）

每个模块只做一类动作 —— 加 feature 或 debug 时只动一个文件。

| 文件 | 内容 | 规则 |
|---|---|---|
| `env.zsh` | `export` + `brew shellenv` | 只放 env vars，不放 tool init、不放 alias |
| `plugins.zsh` | zinit bootstrap + 所有 plugin 声明 | 所有 `zinit` 调用集中一处 |
| `tools.zsh` | CLI 工具运行时激活（`fzf --zsh`、`zoxide init`） | 必须在 plugins 之后加载 —— fzf-tab 依赖 fzf 的 widget |
| `aliases.zsh` | 按 `# ─── 主题 ───` 分组的 alias | 只写 `alias` 行，其他一律不放 |
| `keybinds.zsh` | `bindkey` 覆盖 | 预留槽位（Phase 3 暂空） |
| `secrets.zsh` | 由 `encrypted_private_secrets.zsh.age` 解密而来 | age + chezmoi 管理，见 [secrets.zh.md](secrets.zh.md) |

### 加载顺序

`.zshrc` 按下面这个固定顺序 source：

    env → plugins → tools → aliases → keybinds → secrets

换顺序会断：

- `tools` 在 `plugins` 之前 → fzf-tab 没 compinit 状态可 hook。
- `aliases` 在 `plugins` 之前 → 插件设的 alias 反过来盖了你的。

## 加一个 plugin

改 `plugins.zsh`，在 `zinit wait lucid for` 块里加一行：

```zsh
# 大多数情况 —— 异步加载，不需要额外配置
zinit wait lucid for \
    ...existing... \
    author/plugin-name

# 注册 completions 的 plugin —— 需要 `blockf` 保护 fpath
zinit wait lucid for \
    ...existing... \
    blockf \
        author/completion-plugin

# 需要 post-load callback 的 plugin
zinit wait lucid for \
    ...existing... \
    atload'_plugin_init_fn' \
        author/needs-init
```

不需要 `chezmoi apply`；下次打开 `zsh` 时 zinit 自动 clone 进来。

## 加一个 alias

改 `aliases.zsh`。文件按 `# ─── 主题 ───` 注释分组 —— 挑对应组加进去，或主题全新就另起一组。

## 加一个 CLI 工具集成

- 需要运行时激活（键绑定、prompt hook、auto-cd）→ `tools.zsh`
- 只是 export env var → `env.zsh`

判断小窍门：工具文档写 `eval "$(tool init)"` 或 `source <(tool)` 的，都属于 `tools.zsh`。

## Health check

### 自动化

```bash
bash tests/zsh.sh
```

49 项检查，覆盖：文件存在、`zsh -n` 语法、env vars、aliases、zinit + plugin 缓存、CLI 工具是否在 PATH。退出码 0 = 全绿。

### 手动（需要真实 TTY）

Turbo 插件靠 `precmd` hook 触发，`zsh -i -c '...'` 或 script 子进程压根跑不到 prompt，所以插件永远不 fire。必须在真实终端里开一个新 tab，用眼睛验证：

1. 敲 `git sta` —— "tus" 应以灰色行内建议出现（autosuggestions）。
2. 敲 `ls` —— 命令本身应着色（绿/青），而非纯白（syntax-highlighting）。
3. 在空 `git ` 后按 Tab —— 应弹出 fzf 风格菜单（fzf-tab）。
4. 按 Esc —— 右侧 prompt 应显示 `[NORMAL]`。*Phase 3 局限：需要 prompt theme 调用 `vi_mode_prompt_info`，等 Phase 4 Starship 落地才能看到；Phase 3 内键绑定能用但指示器隐形。*

## 启动性能

| 状态 | `time zsh -i -c exit` |
|---|---|
| 冷启（插件未缓存） | 30-60s —— zinit 从 GitHub 下载 4 个 plugin |
| 热启（插件已缓存） | 60-100ms |

Turbo（`wait lucid`）把 plugin 加载**移出** critical path：plugin 在第一次 prompt 渲染之后异步接上。`zsh -i -c exit` 看起来过快（没 prompt = Turbo 不 fire），但交互体验真正重要的点是 —— prompt 立刻出，插件在 ~50ms 内补齐。

测：

```bash
time zsh -i -c exit
```

Profile：

```bash
zsh -xvis 2>&1 | ts -i "%.s" | head -200
```

查特定 plugin 是否走 Turbo：

```zsh
zinit report author/plugin-name
```

## Troubleshooting

**`tests/zsh.sh` 报 plugin "downloaded: FAIL"** —— `chezmoi apply` 没跑到 install hook，或 zinit clone 失败。`rm -rf ~/.local/share/zinit && zsh` —— `plugins.zsh` 的 self-install 回退会在第一次 prompt 时重 clone。

**Tab 只插字面 Tab，补全没了** —— `compinit` 没跑。查 `plugins.zsh` 里 fzf-tab 上那行 `atinit"zicompinit; zicdreplay"` 还在不在，这是 compinit 唯一触发的地方。

**脚本里出现 `(eval):1: can't change option: zle`** —— OMZP::vi-mode 要切换 `setopt zle`，非交互 shell 拒绝。无害；别因此去掉 vi-mode。

**启动突然变慢** —— 新加的 plugin 很可能没进 `zinit wait lucid for` 块，变成同步加载。查 `plugins.zsh`。

**语法高亮悄悄失效** —— 你在 `zsh-syntax-highlighting` **之后** 加了东西。highlighting 只能包住加载时已在的 widget。把新 plugin 挪到 for 块前面。

## Gotchas

**`zsh-syntax-highlighting` 必须最后一个。** 在它之后声明的 plugin 全部在它 wrap 范围外。这是 zinit 最常见的坑。

**`COLUMNS` 小技巧。** `env.zsh` 里那行 `export COLUMNS=$(tput cols 2>/dev/null || echo 200)` 是因为 claude-hud 的 statusLine 子进程继承到 `COLUMNS=0` 后回退到 40 字符 —— "compact" 模式会被挤成 5+ 行。见 [claude-hud#408](https://github.com/jarrodwatts/claude-hud/issues/408)。

**首次 `chezmoi apply` 下载所有 plugin 30-60s 属正常。** 之后都是秒级。看起来卡住是在从 GitHub 拉。

**Phase 4 之前 prompt 没 vi-mode 指示器。** OMZP::vi-mode 定义 `vi_mode_prompt_info` 但依赖 prompt theme 调用它。键绑定现在可用；`[NORMAL]` 要等 Starship。

## 彻底重建

```bash
# 清空 zinit 所有状态（保留你的配置文件）
rm -rf ~/.local/share/zinit

# 打开新的 `zsh` —— plugins.zsh 里的 self-install 会重 clone zinit，
# Turbo 会在第一次 prompt 时重下所有 plugin。
```

chezmoi 安装 hook（`run_once_after_30-zinit-install.sh`）是 bootstrap 兜底；`plugins.zsh` 自己也能 self-install，所以仅删 `~/.local/share/zinit` 就够了。
