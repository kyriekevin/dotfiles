# Neovim

> [English](nvim.md) · 中文

Kickstart 风的**单文件** nvim 配置。整份 config 都在一个 `init.lua` 里——从上读到底，没有插件树，不套发行版。本文覆盖 Phase 7a（骨架：options + keymaps + autocmds + 4 个基础插件）。7b–7d 分别加导航 / LSP / 打磨，都走独立 branch。

## 工作原理

| 对象 | 位置 | 说明 |
|---|---|---|
| 配置 | `~/.config/nvim/init.lua` ← 源 `dot_config/nvim/init.lua` | 单文件。`vim.g.mapleader = " "` 是最先执行的那行。 |
| 插件锁 | `~/.config/nvim/lazy-lock.json` ← 源 `dot_config/nvim/lazy-lock.json` | 每插件一个 commit hash — **跟进 repo**，两台 Mac 锁同版本。 |
| 插件缓存 | `~/.local/share/nvim/lazy/<name>` | `lazy.nvim` 首次启动时写入。**不**在源里。 |
| 撤销目录 | `~/.local/state/nvim/undo/` | `opt.undofile = true`。不在源里。 |
| 安装 | `brew install neovim`（Brewfile） | 没有单独安装步骤——`chezmoi apply` → `init.lua` → 下次 `nvim` 启动时自动 bootstrap lazy。 |

## 概念

**Kickstart 风。** 整份配置一文件读完。参考 [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)。等 `init.lua` 超过 ~400 行或 LSP 配置需要自己的空间时，再拆 `lua/` 子模块——不提前拆。

**lazy.nvim。** 插件管理器，干两件事：
1. **Bootstrap**：`init.lua` 靠下的那段代码首次启动时把 lazy.nvim clone 到 `~/.local/share/nvim/lazy/lazy.nvim`。没有 submodule、不走 brew。
2. **Spec → install**：`require("lazy").setup({…})` 收一个插件 spec 列表（`"author/repo"` + `opts` / `event` / `keys`）。lazy 按需懒加载，并写 `lazy-lock.json`。

**`lazy-lock.json` 要跟进 repo。** 它锁每个插件的 commit SHA。另一台 Mac `chezmoi apply` + `nvim` 时，lazy 读锁文件、checkout 相同 commit → 两机插件状态完全一致。更新方式：nvim 里 `:Lazy sync`，然后 `chezmoi add ~/.config/nvim/lazy-lock.json`。

**Karabiner 约束。** 本机 Karabiner 在 OS 层把 **Caps→Ctrl**、**Ctrl+hjkl→方向键**。后果：`<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` **到不了 nvim**——它们变成 `<Left>` / `<Down>` / `<Up>` / `<Right>`。不要绑它们。安全 Ctrl 组合：`<C-w>…`（窗口操作）、`<C-d>` / `<C-u>`（半页翻）、`<C-o>` / `<C-i>`（跳转列表）。

**配色。** Catppuccin Mocha——和 starship、ghostty、fastfetch、yazi 同 flavor。整个终端一套配色。

**透明**需要 catppuccin 的两个独立开关 + 一个 `opt`：

- `transparent_background = true` → 不画 `Normal / NormalNC / SignColumn / EndOfBuffer`（编辑区）。
- `float = { transparent = true }` → 不画 `NormalFloat` 及其 link（which-key、telescope、blink.cmp、LSP hover 等浮窗）。
- `opt.winblend = 0`（+ `opt.pumblend = 0`）→ catppuccin 只在 winblend=0 时才把浮窗 bg 设为 NONE（`editor.lua:40`：`bg = (float.transparent and winblend == 0) ? none : mantle`）。

换到非透明终端时，三项都去掉。

## 按键参考（Phase 7a）

`<leader>` 是 `<Space>`。按住 `<leader>` 不动 → 弹 which-key。

### 通用

| 键 | 模式 | 动作 |
|---|---|---|
| `<Esc>` | normal | 清搜索高亮 |
| `<leader>w` | normal | 写入 buffer |
| `<leader>e` | normal | 弹 diagnostic float |
| `<leader>?` | normal | 列 buffer-local keymap（which-key） |
| `[d` / `]d` | normal | 上/下个 diagnostic |

### 行内跳转 —— `H` / `L` 覆盖 vim 默认

绑在 `{ n, x, o }`（normal + visual + operator-pending），所以 `dL` / `yH` / `vL` 都能用。

| 键 | 动作 | 被替换的 vim 默认 |
|---|---|---|
| `H` | 跳到行首非空白（`^`） | 视口顶部 —— 改用 `zt` / `<C-u>` |
| `L` | 跳到行尾（`$`） | 视口底部 —— 改用 `zb` / `<C-d>` |

normal 模式的 `K` 7a 故意没绑；7c 会接到 `vim.lsp.buf.hover()`。

### Visual

| 键 | 动作 |
|---|---|
| `<` / `>` | 左/右缩进，保持选中 |

### Window / split（vim 内置；`<C-w>` 没被 Karabiner 吃掉）

| 键 | 动作 |
|---|---|
| `<C-w>s` / `<C-w>v` | 水平 / 垂直分屏 |
| `<C-w>h/j/k/l` | 切换到左/下/上/右 window |
| `<C-w>c` / `<C-w>o` | 关本窗 / 只留本窗 |
| `<C-w>=` | 等分窗口 |

### mini.surround（Phase 7a 插件，LazyVim `gs` 前缀）

| 键 | 动作 |
|---|---|
| `gsa{motion}{char}` | 加 surround：`gsaiw)` → 当前词包 `()` |
| `gsd{char}` | 删 surround：`gsd"` → 去除外层 `""` |
| `gsr{old}{new}` | 换 surround：`gsr([` → `()` → `[]` |
| `gsf{char}` / `gsF{char}` | 下/上一个 surround |
| `gsh{char}` | 高亮 surround |
| `gsn` | 更新 `n_lines`（mini.surround 向外搜多少行） |

## 插件（Phase 7a）

四个。`init.lua` 里每一行一个。后续 phase 往同一个 `require("lazy").setup({…})` 追加。

| 插件 | 角色 | 加载 | 备注 |
|---|---|---|---|
| `catppuccin/nvim` | 配色（Mocha flavor） | 立即加载，`priority = 1000` | 先加载，其他插件才能拿到 catppuccin 高亮组。`vim.g.colors_name` = `catppuccin-mocha`。 |
| `folke/which-key.nvim` | keymap 提示弹窗 | `event = "VeryLazy"` | Preset `classic` → 底部全宽无边框条（`width = math.huge`、`col = 0`、`row = -1`）。自动显示 `vim.keymap.set(..., { desc = "..." })` 里的 `desc`。其他 preset：`helix` = 右下 30–60 列小框、`modern` = 居中 90% 圆角浮窗。 |
| `echasnovski/mini.pairs` | `() [] {} '' "" \`\`` 自动闭合 | `event = "InsertEnter"` | 退格删一个会联动删对侧。 |
| `echasnovski/mini.surround` | `gsa/gsd/gsr/gsf/gsF/gsh/gsn` surround 操作 | `event = "VeryLazy"` | LazyVim 风 `gs` 前缀。避开 `s`（7b 给 flash）、`ys/ds/cs`（vim-surround 风，撞 yank/change 动作）、`gd/gr/gI`（7c LSP 系列）。 |

## 改配置

1. 编辑 `dot_config/nvim/init.lua`。
2. `chezmoi diff ~/.config/nvim/init.lua` — 预览。
3. `chezmoi apply ~/.config/nvim/init.lua` — 写入。
4. 重载：nvim 里 `:source %`。插件/autocmd 结构改动需要重启。
5. 跑 `bash tests/nvim.sh` 防回归。

## 加插件

1. 在 `require("lazy").setup({…})` 里追加 spec：

    ```lua
    { "author/repo", event = "VeryLazy", opts = { … } },
    ```

2. 保存 `init.lua`，重启 `nvim`，lazy 启动时自动装。
3. nvim 里 `:Lazy sync` 刷新 `lazy-lock.json`。
4. `chezmoi add ~/.config/nvim/init.lua ~/.config/nvim/lazy-lock.json` — 两个都 vendor。

常用 spec 键：`event`（`InsertEnter` / `BufReadPre` / `VeryLazy` 等事件懒加载）、`keys`（按键触发懒加载）、`cmd`（`:Cmd` 触发）、`opts`（语法糖，lazy 帮你 `require(plugin).setup(opts)`）。

## Health check

### 自动

```bash
bash tests/nvim.sh
```

21 项检查：文件在位、nvim/git 在 PATH、headless `+qa` 启动、`Lazy! sync` 退出码、5 个插件目录（lazy.nvim + 4 个 7a）、`lazy-lock.json` 在位、runtime 探针（leader、colorscheme、number/relnum/expandtab/tabstop/shiftwidth/undofile/netrw-disabled）。

### 手动

真实终端里 `nvim some-file.lua`：

- [ ] splash 显示，无红字报错
- [ ] 背景是 catppuccin mocha 紫红系，不是默认深色
- [ ] `:echo mapleader` 返回 `' '`（一个空格）
- [ ] 行号可见，relativenumber 开启（光标外的行是相对数）
- [ ] 按 `<Space>` 不放 → **which-key 弹窗**列出 `w / q / Q / e / ?`
- [ ] `<Space>w` 写入 buffer（`:w` 执行，无 prompt）
- [ ] insert 模式输入 `(` → 自动补 `()` 光标夹中（**mini.pairs**）
- [ ] 退格删 `(` → `)` 联动删
- [ ] normal 模式 `gsaiw"` → 当前词被 `""` 包起（**mini.surround 加**）
- [ ] 在包好的词上 `gsd"` → 引号删掉（**mini.surround 删**）
- [ ] `gsr"'` → `""` 变 `''`（**mini.surround 换**）
- [ ] 行首有缩进时按 `H` → 光标跳到第一个非空白字符（不是 col 0）
- [ ] 按 `L` → 光标跳到行尾
- [ ] `dL` 删到行尾；`yH` yank 到行首非空白
- [ ] `yy` yank 文本 → 一瞬高亮闪烁（autocmd 生效）
- [ ] `:Lazy` 打开插件管理面板

## Troubleshooting

| 症状 | 原因 | 修 |
|---|---|---|
| `nvim: command not found` | neovim 没装 | `brew bundle` — Brewfile 已声明 `neovim`。 |
| 插件没装 / UI 默认样 | 首次 lazy bootstrap 中断 | `nvim --headless '+Lazy! sync' +qa` — 或直接重启 nvim。 |
| 启动 `E5113: Error while calling lua chunk` | `init.lua` 语法错 | `bash tests/nvim.sh` — Headless 那段会打错。 |
| 颜色是默认深色（非 catppuccin） | catppuccin 加载失败 | `:Lazy` → 找 `catppuccin` → `L` 看 log。多半 git clone 失败 → `:Lazy restore`。 |
| which-key 弹窗不出现 | `timeoutlen` 太短或插件没加载 | `:echo &timeoutlen` 应 ≥ 300。`:Lazy show which-key.nvim`。 |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` 神秘地当方向键 | Karabiner 做的——**故意** | 见概念 → Karabiner 约束。改绑 `<leader>…` 或用 `<C-w>…` 管窗口。 |
| `gsaiw)` 不 surround | mini.surround 的 `gs` 被其他插件抢了 | `:verbose map gsa` — 找到冲突后解绑，或改 mini.surround 的 `opts.mappings`。 |
| `H` / `L` 跳转不对 | 其他插件（多半 7b 加入时）重绑了 | `:verbose map H` / `:verbose map L` — 找到来源、改掉或解绑。 |
| `lazy-lock.json` `:Lazy sync` 后 diff 很大 | 正常——上游动了 | commit 更新：`chezmoi add ~/.config/nvim/lazy-lock.json`。 |

## Gotchas

- **单文件，顺序严格。** `vim.g.mapleader` 必须在 lazy 块**之前**——插件在加载时注册 keymap，用的是那一刻的 `mapleader` 值。不要调序。
- **`<C-h>` 家族在本机废了。** Karabiner 吃掉了。仓库里所有 keymap 都按此约束写；新绑键避开。
- **Chezmoi 只管两个文件**（7a）：`init.lua` 和 `lazy-lock.json`。`~/.local/share/nvim/lazy/` 是**目标端运行时**——不要 `chezmoi add`（会把几十 MB 插件源码拖进 repo）。
- **undo 持久化。** `opt.undofile = true` 写到 `~/.local/state/nvim/undo/`。nvim 关了再开还能撤销——但也意味着删过的文件的 undo 历史留在盘上。
- **`mini.pairs` 在 `InsertEnter` 加载。** 启动后第一次进 insert 模式有 ~ms 延迟加载。故意的——保冷启动快。
- **`H` / `L` 覆盖 vim 视口跳转。** vim 默认 `H` = 视口顶、`L` = 视口底。这里换成行首/行尾（VS Code / 多数 IDE 的肌肉记忆）。需要视口顶 → `zt` / `<C-u>`；视口底 → `zb` / `<C-d>`。
- **mini.surround 用 `gs` 而非 `s`。** `s` 留给 7b 的 flash。vim 默认 `gs` 是 "gotoSleep"（按计数秒睡眠），覆盖无损。

## 从零重建

```bash
# 清插件缓存 + undo 历史 + lazy state。保留 init.lua 和 lazy-lock。
rm -rf ~/.local/share/nvim ~/.local/state/nvim

# 重新 apply + bootstrap：
chezmoi apply ~/.config/nvim/
nvim --headless '+Lazy! sync' '+qa'
```

若 `init.lua` 本机烂了：

```bash
chezmoi apply ~/.config/nvim/init.lua
```

## Roadmap

后续 phase——计划文档：`/Users/bytedance/.claude/plans/0-1-dotfiles-stow-dotfiles-bk-jolly-boole.md`：

- **7b nav**：telescope.nvim / oil.nvim / flash.nvim / gitsigns / lazygit.nvim
- **7c lsp**：mason + mason-tool-installer / nvim-lspconfig（basedpyright + clangd + lua_ls）/ blink.cmp / conform.nvim
- **7d polish**：nvim-treesitter / lualine / Comment / indent-blankline / todo-comments / undotree

每个一个 `feat/nvim-*` branch + PR；都往同一个 `init.lua` 追加（超过 ~400 行或 LSP 需要独立文件时再拆 `lua/`）。
