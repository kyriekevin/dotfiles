# Neovim

> [English](nvim.md) · 中文

Kickstart 风的**单文件** nvim 配置。整份 config 都在一个 `init.lua` 里——从上读到底，没有插件树，不套发行版。覆盖 **Phase 7a（骨架）** + **Phase 7b（导航）**：options、keymaps、autocmds 和 12 个插件（配色/picker/文件树/跳转/git/textobj/注释/状态栏/tab）。7c–7d 分别加 LSP / 打磨，走独立 branch。

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

## 按键参考

`<leader>` 是 `<Space>`。按住 `<leader>` 不动 → 弹 which-key。

### 通用

| 键 | 模式 | 动作 |
|---|---|---|
| `<Esc>` | normal | 清搜索高亮 |
| `<leader>w` | normal | 写入 buffer |
| `<leader>cd` | normal | 弹 diagnostic float（7b 从 `<leader>e` 挪来，把 `e` 让给 neo-tree） |
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

### snacks.picker —— `<leader>f*` 统一前缀（Phase 7b）

文件和搜索都在 `<leader>f*`（kickstart 风统一前缀 + LazyVim 风键名）。不拆 `<leader>s*`——单字母记忆 `f`。

| 键 | 动作 |
|---|---|
| `<leader>ff` | 当前目录找文件 |
| `<leader><space>` | 当前 buffer 列表 |
| `<leader>fr` | 最近打开 |
| `<leader>fg` | 项目全文 live grep |
| `<leader>fw` | 光标下词 grep（normal + visual 选区） |
| `<leader>fh` | 帮助 tags |
| `<leader>fk` | keymaps |
| `<leader>fd` | 诊断列表（workspace） |
| `<leader>fn` | 新空 buffer（`:enew`） |

buffer 内 grep 用 vim 原生 `/` + `n`/`N`——没套 picker。

### neo-tree（Phase 7b）

| 键 | 动作 |
|---|---|
| `<leader>e` | 开关 neo-tree 侧边栏 |

树内：`?` 看帮助。`<space>` 被我们主动解绑——neo-tree 默认 `<space>` = "toggle 节点"，会吃掉 leader。

### flash.nvim（Phase 7b，无 leader）

| 键 | 模式 | 动作 | 被替换的 vim 默认 |
|---|---|---|---|
| `s` | n/x/o | Flash 跳转（敲 2 字符 → 高亮提示） | `s` = substitute-char，改用 `cl` |
| `r` | o | Remote flash（`yr` 远端 yank 再回来） | normal 的 `r{char}` 不受影响（flash 只绑 `o`） |

`S`（treesitter select）和 `R`（treesitter search）需要 nvim-treesitter，7c 再装。

### gitsigns（Phase 7b —— `<leader>gh*` hunk 簇）

全部 keymap 走 `on_attach`，只在 git 跟踪的 buffer 里绑（buffer-local）。

| 键 | 动作 |
|---|---|
| `]h` / `[h` | 下/上个 hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghu` | Undo stage hunk |
| `<leader>ghp` | Preview hunk（inline float） |
| `<leader>ghb` | Blame 当前行（完整 commit + body） |
| `<leader>ghd` | 当前文件 diff HEAD |

### snacks.lazygit（Phase 7b）

| 键 | 动作 |
|---|---|
| `<leader>gg` | 浮窗开 lazygit（cwd） |

file history / log / branches 都在 lazygit TUI 内部完成——我们主动砍掉 `<leader>gf/gl` 保持 surface 小。

### bufferline（Phase 7b）

| 键 | 动作 |
|---|---|
| `]b` / `[b` | 下/上个 buffer |
| `<leader>bd` | 关当前 buffer（`:bdelete`） |

### mini.comment（Phase 7b，无 leader）

| 键 | 模式 | 动作 |
|---|---|---|
| `gcc` | normal | Toggle 行注释 |
| `gc{motion}` | normal | Toggle motion 范围注释（`gcap` 段落、`gc5j` 下 5 行） |
| `gc` | visual | Toggle 选区注释 |

按 filetype 自动识别 `commentstring`：Python `#`、C/C++ `//`、Lua `--`……

### mini.ai（Phase 7b，textobject）

作为 vim operator（`d`/`c`/`y`/`v`）的目标。形式 `{operator}{a|i}{target}`：

| target | 含义 | 例 |
|---|---|---|
| `ab` / `ib` | 括号块（自动识别 `()` / `[]` / `{}`） | `dab` 删整个块、`cib` 改块内 |
| `a(` `i(` `a[` `i[` `a{` `i{` | 具体括号种类 | `ci{` 改 `{}` 内 |
| `a"` `i"` `a'` `i'` `` a` `` `` i` `` | 引号 | `di"` 删 `""` 内 |
| `aa` / `ia` | 函数参数 | `daa` 删整个参数（含逗号） |
| `at` / `it` | HTML 风 tag | `cit` 改 `<tag>…</tag>` 内 |

`af`/`if`（函数）和 `ac`/`ic`（类）需要 treesitter，7c 再装。

## 插件

`init.lua` 里每一行一个。7c/7d 继续追加到同一个 `require("lazy").setup({…})`。

### Phase 7a（骨架）

| 插件 | 角色 | 加载 | 备注 |
|---|---|---|---|
| `catppuccin/nvim` | 配色（Mocha flavor） | 立即加载，`priority = 1000` | 先加载，其他插件才能拿到 catppuccin 高亮组。`vim.g.colors_name` = `catppuccin-mocha`。7b 扩展了 integrations：`gitsigns`、`neotree`、`flash`、`snacks`。 |
| `folke/which-key.nvim` | keymap 提示弹窗 | `event = "VeryLazy"` | Preset `classic` → 底部全宽无边框条。自动显示 `vim.keymap.set(..., { desc = "..." })` 里的 `desc`。 |
| `echasnovski/mini.pairs` | `() [] {} '' "" \`\`` 自动闭合 | `event = "InsertEnter"` | 退格删一个会联动删对侧。 |
| `echasnovski/mini.surround` | `gsa/gsd/gsr/gsf/gsF/gsh/gsn` surround 操作 | `event = "VeryLazy"` | LazyVim 风 `gs` 前缀。避开 `s`（7b 给 flash）、`ys/ds/cs`（vim-surround 风，撞 yank/change 动作）、`gd/gr/gI`（7c LSP 系列）。 |

### Phase 7b（导航）

| 插件 | 角色 | 加载 | 备注 |
|---|---|---|---|
| `nvim-tree/nvim-web-devicons` | Nerd Font 图标提供者 | 懒加载（被 require 时） | neo-tree / lualine / bufferline / snacks 的公共 dep。终端层需要 Nerd Font——Ghostty 是 Maple Mono NF。 |
| `folke/snacks.nvim` | umbrella：picker + lazygit + notifier + bigfile + quickfile + indent + input + statuscolumn | 立即加载，`priority = 900` | keymap 调 `Snacks.picker.files()` 等，走启动时注入的 `Snacks` 全局。`priority = 900` → catppuccin（1000）之后立即加载，高亮集成干净。 |
| `nvim-neo-tree/neo-tree.nvim` | 侧边文件树（`v3.x` 分支） | `cmd = "Neotree"` + `<leader>e` | 依赖 `plenary.nvim`、`nui.nvim`、devicons。`bind_to_cwd = false` → `:cd` 时树不跳。`follow_current_file = { enabled = true }` 开关时自动定位到当前 buffer。`window.mappings["<space>"] = "none"` 让树内 `<space>` 不吃 leader（neo-tree 默认 `<space>` = "toggle 节点"）。 |
| `folke/flash.nvim` | 双字符跳转 | `event = "VeryLazy"` + `s`/`r` | 7b 只绑 `s`/`r`；`S`/`R`（treesitter）留 7c。 |
| `lewis6991/gitsigns.nvim` | gutter +/−/~ 符号 + hunk 操作 + blame | `event = { "BufReadPre", "BufNewFile" }` | keybind 在 `on_attach` 里 → buffer-local，非 git buffer 零污染。用新 API `nav_hunk("next"/"prev")`，`next_hunk`/`prev_hunk` 是 deprecated alias。 |
| `echasnovski/mini.ai` | 扩展 `a`/`i` textobject | `event = "VeryLazy"` | 默认：bracket / quote / arg / tag。`af`/`ic` 需要 nvim-treesitter → 7c。 |
| `echasnovski/mini.comment` | `gcc` / `gc{motion}` / visual `gc` 注释 toggle | `event = "VeryLazy"` | 按 filetype 自动识别 `commentstring`。 |
| `nvim-lualine/lualine.nvim` | 状态栏 | `event = "VeryLazy"` | `globalstatus = true` → 所有分屏共享一条。Theme = `catppuccin`。 |
| `akinsho/bufferline.nvim` | 顶部 buffer tab 栏 | `event = "VeryLazy"` | `opts = function()` 让 `catppuccin.special.bufferline` 在插件加载时才 require（跑在 catppuccin 之后）。`offsets` 让 neo-tree 侧边栏不覆盖 tab 栏。 |

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

34 项检查：文件在位、nvim/git 在 PATH、headless `+qa` 启动、`Lazy! sync` 退出码、16 个插件目录（lazy.nvim + 4 个 7a + 8 个 7b + 3 个 dep：`nvim-web-devicons`/`nui.nvim`/`plenary.nvim`）、`lazy-lock.json` 在位、runtime 探针（leader、colorscheme、number/relnum/expandtab/tabstop/shiftwidth/undofile/netrw-disabled、`Snacks` 全局是否已加载、`<leader>cd` 是否已绑 diagnostic float）。

### 手动

真实终端里 `nvim some-file.lua`：

**Phase 7a（骨架）：**
- [ ] splash 显示，无红字报错
- [ ] 背景是 catppuccin mocha 紫红系，不是默认深色
- [ ] `:echo mapleader` 返回 `' '`（一个空格）
- [ ] 行号可见，relativenumber 开启（光标外的行是相对数）
- [ ] 按 `<Space>` 不放 → **which-key 弹窗**（底部全宽条）
- [ ] `<Space>w` 写入 buffer（`:w` 执行，无 prompt）
- [ ] insert 模式输入 `(` → 自动补 `()` 光标夹中（**mini.pairs**）
- [ ] 退格删 `(` → `)` 联动删
- [ ] normal 模式 `gsaiw"` → 当前词被 `""` 包起（**mini.surround 加**）
- [ ] 在包好的词上 `gsd"` → 引号删掉（**mini.surround 删**）
- [ ] 行首有缩进时按 `H` → 光标跳到第一个非空白字符
- [ ] 按 `L` → 光标跳到行尾
- [ ] `yy` yank 文本 → 一瞬高亮闪烁（autocmd 生效）

**Phase 7b（导航）：**
- [ ] `<Space>ff` 打开 **snacks.picker** 找文件；打字缩小候选
- [ ] `<Space><space>` 打开 **buffers picker**；`<Enter>` 切换
- [ ] `<Space>fg` 打开 **live grep**；打 pattern → 项目全文匹配列出
- [ ] 光标停在某个词上 `<Space>fw` → grep 预填该词
- [ ] `<Space>fh` / `<Space>fk` / `<Space>fd` → help / keymaps / diagnostics picker
- [ ] `<Space>e` 开关 **neo-tree** 侧边栏；自动定位到当前 buffer
- [ ] normal 模式按 `s` → **flash** 可见匹配处出现提示字符；打两字符 → 光标跳过去
- [ ] 编辑一个 git 跟踪的文件，改一行 → **gitsigns** 在 gutter 显 `~`
- [ ] `]h` / `[h` 在 hunk 间跳；`<Space>ghp` 预览；`<Space>ghb` 看完整 blame
- [ ] `<Space>gg` 浮窗开 **lazygit**
- [ ] `]b` / `[b` 在 **bufferline** tab 间循环（需 ≥2 个 buffer）
- [ ] `<Space>bd` 关当前 buffer
- [ ] `gcc` toggle 行注释；Python buffer 前缀 `# `、Lua `-- `
- [ ] 光标在 `{}` 内 `va{` → 选中整个块（**mini.ai**）
- [ ] 底部 **lualine** 条：mode / branch / diagnostic count / filename
- [ ] 顶部 **bufferline** tab：每个 buffer 一格带图标
- [ ] 当前行有诊断时 `<Space>cd` 弹 float

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
| `<leader>e` 开了文件树而不是诊断 float | 刻意——7b 把诊断 float 挪到 `<leader>cd`，把 `e` 让给 neo-tree | 用 `<leader>cd`。 |
| 按 `s` 删了一个字符还进了 insert 模式，没 Flash 跳转 | flash.nvim 没加载（VeryLazy autocmd 没触发或插件报错） | `:Lazy load flash.nvim` 重试。`:Lazy` 面板看错误。 |
| `<leader>ff` 报 `attempt to index nil with 'picker'` | snacks.nvim 没加载或 `Snacks` 全局缺失 | `:Lazy load snacks.nvim`。spec 里要同时设 `priority` + `lazy = false`，`Snacks` 全局才会在按键触发时已在。 |
| neo-tree 的图标显示方块 | 终端字体没 Nerd Font 字形 | 确认 Ghostty 在用 Nerd Font（按 ghostty 配置是 `Maple Mono NF`）。非 Nerd Font → 方块。 |
| 树内按 `<space>` 没反应 / 吃了 leader | neo-tree 默认 `<space>` = "toggle 节点" 和我们 leader 冲突 | spec 里 `window.mappings["<space>"] = "none"` 已覆盖。如果失效，核对 `init.lua` 的 neo-tree 块。 |
| lualine 不显示 | 插件懒加载太晚（还没触发 VeryLazy） | `:Lazy load lualine.nvim`。或直接打开文件——`event = "VeryLazy"` 启动后不久就会触发。 |
| bufferline 颜色不对 / 看着像默认 | catppuccin 在 bufferline 之后加载（race） | 我们用 `opts = function() ... require("catppuccin.special.bufferline").get_theme() ... end` 保证 require 在插件 load 时执行（catppuccin 之后）。如果坏了，核对 `opts` 是 function 而不是 table。 |
| gitsigns gutter 不显 | 文件不在 git 跟踪里，或在 `.git/info/exclude` 里 | `:Gitsigns attach` 强挂。未跟踪文件没 hunk —— 预期行为。 |

## Gotchas

- **单文件，顺序严格。** `vim.g.mapleader` 必须在 lazy 块**之前**——插件在加载时注册 keymap，用的是那一刻的 `mapleader` 值。不要调序。
- **`<C-h>` 家族在本机废了。** Karabiner 吃掉了。仓库里所有 keymap 都按此约束写；新绑键避开。
- **Chezmoi 只管两个文件**（7a）：`init.lua` 和 `lazy-lock.json`。`~/.local/share/nvim/lazy/` 是**目标端运行时**——不要 `chezmoi add`（会把几十 MB 插件源码拖进 repo）。
- **undo 持久化。** `opt.undofile = true` 写到 `~/.local/state/nvim/undo/`。nvim 关了再开还能撤销——但也意味着删过的文件的 undo 历史留在盘上。
- **`mini.pairs` 在 `InsertEnter` 加载。** 启动后第一次进 insert 模式有 ~ms 延迟加载。故意的——保冷启动快。
- **`H` / `L` 覆盖 vim 视口跳转。** vim 默认 `H` = 视口顶、`L` = 视口底。这里换成行首/行尾（VS Code / 多数 IDE 的肌肉记忆）。需要视口顶 → `zt` / `<C-u>`；视口底 → `zb` / `<C-d>`。
- **mini.surround 用 `gs` 而非 `s`。** `s` 留给 7b 的 flash。vim 默认 `gs` 是 "gotoSleep"（按计数秒睡眠），覆盖无损。
- **`<leader>` 前缀分类（taxonomy）。** 7b 锁定：`<leader>f*` picker（files + search，不拆 `<leader>s*`）、`<leader>g*` git（lazygit `gg`、gitsigns `gh*`）、`<leader>b*` buffer、`<leader>c*` code（目前只有 `cd` 诊断；7c 填 `ca`/`cr`）、`<leader>e` explorer。新 keymap 往这些簇里塞。
- **flash 的 `s` 覆盖了 vim substitute-char。** 替代用 `cl`。`r{char}` 的 normal-mode 替换不受影响——flash 只在 operator-pending 模式绑 `r`。
- **snacks 有 `Snacks` 全局。** 启动时由 snacks.nvim 注入（`lazy=false` + `priority=900`）。所有 picker 键调 `Snacks.picker.files()` 等——全局不存在，所有 picker 键失效。`bash tests/nvim.sh` 会检查 `_G.Snacks ~= nil`。
- **neo-tree 在自己窗口里吃 `<space>`。** 默认映射是 "toggle 节点"；我们覆盖为 `"none"` 保 leader 可用。以后给 neo-tree 加功能时，保留这一条。
- **bufferline 用 `opts = function()`。** `highlights = require("catppuccin.special.bufferline").get_theme()` 必须在 catppuccin 加载**之后**解析。table 形式（`opts = {...}`）会在读 spec 时求值，race。
- **7b 刻意不装 treesitter。** 7c 再装。后果：flash 的 `S`/`R`（treesitter jump/search）未绑；mini.ai 的函数/类 textobject（`af`/`ac`）退回默认。语法高亮还是 vim legacy regex，直到 7c。

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

- **7b nav** ✓ 已落地：snacks（picker+lazygit+notifier+bigfile+…）/ neo-tree / flash / gitsigns / mini.ai / mini.comment / lualine / bufferline
- **7c lsp**：mason + mason-tool-installer / nvim-lspconfig（basedpyright + clangd + lua_ls）/ blink.cmp / conform.nvim + **nvim-treesitter**（解锁 flash `S`/`R` + mini.ai `af`/`ic`）+ todo-comments + trouble
- **7d polish**：indent-blankline / undotree / 其余 TBD

每个一个 `feat/nvim-*` branch + PR；都往同一个 `init.lua` 追加（超过 ~400 行或 LSP 需要独立文件时再拆 `lua/`）。
