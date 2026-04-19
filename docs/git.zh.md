# Git

极简全局 git 配置 + 短短一份全局 ignore。身份按 `is_work` chezmoi prompt 切机器 —— 不用 `includeIf`，不按目录切。

---

## 工作方式

| Source（repo） | Target（`$HOME`） | 行为 |
|---|---|---|
| `dot_gitconfig.tmpl` | `~/.gitconfig` | 身份由 `is_work` 切；共享项（delta、rebase、conflict style…）所有机器一致 |
| `dot_gitignore_global` | `~/.gitignore_global` | 通过 `core.excludesFile` 引用 |

chezmoi 在每次 `chezmoi apply` 时渲染模板 —— 不需要 hook 脚本。

---

## 为什么这么选

1. **身份按机器切，不按目录切。** 历史 plan 里写过 `includeIf "gitdir:~/personal/"`；后来删掉，因为用户的实际习惯是"人在哪台 Mac 上就用哪台的身份"。同一个 repo 在两台 Mac 上 clone 会自动用不同身份 author。
2. **`delta` 作为 pager + `interactive.diffFilter`。** 双栏、行号、n/N hunk 导航 —— Phase 2 Brewfile 里装的 `git-delta`。在脚本里需要覆盖成 `-c core.pager=cat`。
3. **`merge.conflictstyle = zdiff3`。** 冲突标记里显示公共祖先 —— 比默认 `merge` 风格好解得多。要求 git ≥ 2.35（Brewfile 拉最新）。
4. **`rebase.autoStash = true`。** 工作区脏时 `git pull --rebase` 自动 stash 而不是报错，免去每次手动 `git stash` / `git stash pop`。
5. **不钉 `pull.rebase`。** zsh `OMZP::git` plugin 提供了 `gl`/`gp`；pull 策略留给各 repo 自己决定。Git 默认（merge）保留。
6. **Alias 极简。** `OMZP::git` 已经提供 `gst` / `gco` / `gcb` / … —— `~/.gitconfig` 里只留 `lg`（因为这个命令长到 shell alias 不好写）。
7. **`credential.helper = osxkeychain`。** macOS Keychain 存 HTTPS 凭据。GitHub 上 `gh auth login` 会装自己的 helper 顶在前面 —— 两个共存不冲突。

---

## 机器与身份对应

| 机器 | `is_work` | `user.name` | `user.email` |
|---|---|---|---|
| 公司 Mac | `true` | `zyz` | `zhongyuzhe@bytedance.com` |
| 个人 Mac | `false` | `Kyrie` | `yuzhezhong0117@qq.com` |

值写在 `dot_gitconfig.tmpl` 里，`{{ if .is_work }} … {{ else }} … {{ end }}` 守护。`is_work` 在 `chezmoi init` 时询问一次，存到 `~/.config/chezmoi/chezmoi.toml`。要切的话 —— 重跑 `chezmoi init`，或者直接改 toml + `chezmoi apply`。

---

## Alias 清单

`~/.gitconfig` 里的 git alias：

| Alias | 展开为 |
|---|---|
| `git lg` | `log --graph --pretty=format:'%C(auto)%h%d %s %C(blue)(%cr) %C(bold blue)<%an>' --abbrev-commit` |

shell 层的 git alias 在 `dot_config/zsh/aliases.zsh`（Phase 3）：`gst`、`gco`、`gcb`、`gcm`、`ga`、`gaa`、`gd`、`gl`、`gp`。完整列表见那个文件。

---

## 全局 ignore

`~/.gitignore_global` 只盖 OS + 编辑器临时文件 —— **不包括** `.env` / `.idea/` / `.vscode/`，这些是 per-project 决策：

- macOS Finder 元数据：`.DS_Store`、`.AppleDouble`、`.LSOverride`
- 编辑器 swap / 临时：`.*.swp`、`.*.swo`、`*~`
- 本地 env 覆盖：`.env.local`、`.envrc.local`（项目级 `.env` / `.env.example` 仍跟踪）

---

## 改 / 加一项设置

1. 改 `dot_gitconfig.tmpl`（或 `dot_gitignore_global`）。
2. `chezmoi diff` —— 对比 `~/.gitconfig` 看渲染后的 diff。
3. `chezmoi apply`。
4. 如果这项值得长期钉住，在 `tests/git.sh` **Active global config** 段加一条 regression guard。

---

## 健康检查

### 自动

```bash
bash tests/git.sh
```

覆盖：二进制存在、目标文件存在、每个钉住的 `[core] [init] [push] [fetch] [rebase] [merge] [interactive] [delta] [commit] [credential] [alias]` 设置、以及模板里两份身份都存在的 regression guard。

### 手动

- [ ] `git config --global user.email` 跟当前机器身份一致
- [ ] `git diff <有改动的文件>` 经 delta 渲染（双栏、行号可见）
- [ ] `git lg -5` 出彩色 graph
- [ ] 全新 HTTPS repo clone 第一次问凭据，之后走 Keychain 缓存
- [ ] 在**另一台** Mac 上 `chezmoi apply` 后，`user.email` 是另一个身份

---

## 疑难排查

| 现象 | 可能原因 | 修法 |
|---|---|---|
| `fatal: bad config line N in file ~/.gitconfig` | 模板没渲好 | `chezmoi diff` / `chezmoi execute-template < dot_gitconfig.tmpl` 复现 |
| 切机器后身份错 | `is_work` 没重问 | 改 `~/.config/chezmoi/chezmoi.toml` 里的 `is_work` → `chezmoi apply` |
| `fatal: unknown style 'zdiff3'` | git < 2.35 | `brew upgrade git` |
| `git diff` 没走 delta | PATH 里没 `delta` | `brew install git-delta` |
| 非 tty 输出夹杂 `interactive.diffFilter` 噪声 | 预期：只在交互式触发 | 不是 bug |

---

## 注意

- **解析 `git diff` 输出的脚本**必须带 `-c core.pager=cat` —— 不然 delta 的彩色分页会搞坏解析。
- **没有全局 `.idea/` / `.vscode/` ignore** —— 这是 per-project 决策，需要的话加到 repo 本地 `.gitignore`。
- **`gh` credential helper** 在 `gh auth login` 之后会顶在 `osxkeychain` 之前处理 GitHub URL。这是故意的；删一个不影响另一个。
- **repo 本地 override 优先。** `~/.dotfiles/.git/config` 目前钉着 `user.email = yuzhezhong0117@qq.com`（历史遗留；Phase 6a 合并后、个人 Mac 上 global 默认切到 personal 之后，可以删掉）。

---

## 从零重建

如果 `~/.gitconfig` / `~/.gitignore_global` 被覆盖：

```bash
chezmoi apply ~/.gitconfig ~/.gitignore_global
```

不用重装 —— chezmoi 根据当前 `is_work` 重新渲染模板。
