# 维护与修改流程

> [English](maintenance.md) · 中文

这份文档回答“如何安全地修改这个仓库”。安装和日常使用见根目录 README；各工具的具体行为与
手工验证见对应的 `docs/<package>.zh.md`。

## 文档职责

每类信息只放在最窄且有用的位置：

| 文档 | 负责内容 |
|---|---|
| `README.zh.md` | 项目定位、安装/更新、组件地图和文档导航 |
| `docs/maintenance.zh.md` | Source/apply 流程、仓库约束和回滚 |
| `CONTRIBUTING.zh.md` | 分支、commit、review 和合并规范 |
| `docs/<package>.zh.md` | 受管行为、修改方式、健康检查和排障 |
| `tests/README.md` | Apply 后在真实 Mac 上运行的 live checks 契约 |

不要把 package 细节复制回 README；链接到对应手册即可。

## 两层验证

仓库刻意区分两类检查：

| 层级 | 入口 | 检查对象 | 是否用于 CI |
|---|---|---|---|
| Source verify | `make verify` | Git 中的源码、模板、格式、链接和仓库约束 | 是 |
| Live health | `make health PACKAGE=<name>` | `chezmoi apply` 后的真实 HOME、CLI、缓存和运行时 | 否，在真实 Mac 上运行 |

Source verify 不读取解密后的 secret，不要求 GUI，不安装插件，也不假设 HOME 已经配置好。Live
health 可以读取目标配置并启动程序，因此可能依赖网络或填充本机缓存。

## Source 与目标文件

仓库是 chezmoi source of truth。常见映射如下：

| Source | 写入目标 | 备注 |
|---|---|---|
| `dot_zshrc` | `~/.zshrc` | `dot_` 表示目标文件名前的 `.` |
| `dot_config/zsh/aliases.zsh` | `~/.config/zsh/aliases.zsh` | 普通配置文件 |
| `dot_gitconfig.tmpl` | `~/.gitconfig` | 先经过 Go template 渲染 |
| `encrypted_private_*.age` | 权限为 0600 的明文目标 | 仓库中永远只保存 age 密文 |
| `.chezmoiscripts/run_*` | 不直接写成文件 | 在 apply 前后按文件名契约执行 |

直接修改仓库 source，或使用 `chezmoi edit <target>`。如果在目标文件中临时试验，确认后必须用
`chezmoi add <target>` 收回 source，并立即检查 diff；不要让 HOME 和仓库长期分叉。

## 标准修改流程

```sh
# 1. 从最新 main 建符合类型的分支
git switch main
git pull --ff-only
git switch -c feat/<name>       # 也可以是 fix/、docs/、chore/

# 2. 修改 source 后，跑与 CI 完全相同的检查
make verify

# 3. 审核渲染结果，只 apply 本次目标
chezmoi --source="$PWD" diff
chezmoi --source="$PWD" apply ~/.config/<package>/...

# 4. 在真实 Mac 验证该 package，再走对应文档里的手工 checklist
make health PACKAGE=<package>
```

最后检查 `git diff --check` 和 `git status --short`，确认没有 HOME 缓存、明文 secret 或无关文件，
再开 PR。PR 标题必须遵循 Conventional Commits；GitHub 的 `checks` job 会运行 `make verify`。

## 变更矩阵

| 变更 | 通常修改 | 必跑 | Apply 后验证 |
|---|---|---|---|
| Zsh alias / 环境变量 | `dot_config/zsh/*.zsh` | `make verify` | `make health PACKAGE=zsh` |
| Git 设置 | `dot_gitconfig.tmpl`、`dot_gitignore_global` | `make verify` | `make health PACKAGE=git` |
| Homebrew package | `Brewfile` | `make verify` | `brew bundle check --file=Brewfile` |
| Neovim 配置 / plugin | `dot_config/nvim/` | `make verify` | `make health PACKAGE=nvim` + UI checklist |
| Karabiner 规则 | `dot_config/karabiner/` | `make verify` | `make health PACKAGE=karabiner` + GUI checklist |
| chezmoi hook | `.chezmoiscripts/`，必要时连同依赖文件 hash | `make verify` | 在可恢复环境中执行两次，确认幂等 |
| Secret | age 密文、必要时 `.gitignore` / recipient | `make verify` | 按 `docs/secrets.zh.md` 操作，不在 PR 输出明文 |
| 用户文档 | 同一主题的英文与中文文件 | `make verify` | 检查语义一致、链接有效 |

## 新增一个 package

一个有运行时行为的新 package 通常包含：

1. chezmoi source 配置；
2. `Brewfile` 中的安装声明（如果需要 binary）；
3. `docs/<package>.md` 与 `docs/<package>.zh.md`；
4. 可自动验证时增加 `tests/<package>.sh`，并把 GUI / TTY 行为留在文档手工 checklist；
5. README 工具栈或目录说明中的入口。

不要为了形式创建空测试。无法稳定自动验证的行为，明确记录手工步骤和预期结果即可。

## 修改 chezmoi scripts

文件名同时定义运行时机和重跑策略：`before/after` 决定相对写文件的顺序，`once/onchange`
决定执行频率。修改时遵守：

- `run_onchange_*` 必须可重复执行，不应因第二次运行破坏状态；
- 脚本依赖 `Brewfile` 等外部 source 时，把依赖内容 hash 嵌入模板；
- 明确脚本是否联网、安装软件或修改系统状态，并让失败以非零状态退出；
- 不在脚本中写入仓库本身，也不把机器身份或 secret 输出到日志；
- 先用 `chezmoi --source="$PWD" diff` 审核，再在可恢复的真实 Mac 上 apply。

## CI 的边界

`.github/workflows/verify.yml` 在 PR、`main` push 和手动触发时运行 `make verify`。它不尝试还原
个人电脑：不会解密 secret、启动 GUI、验证真实按键或长期缓存。Branch protection 要求所有改动
通过 PR，且基于最新 `main` 的 `checks` 成功后才能合并；管理员也遵循同一规则。

## 回滚

- Apply 前发现问题：修改 source，重新运行 `make verify` 和
  `chezmoi --source="$PWD" diff`。
- Apply 后发现问题：先回退 source 变更，再带显式 source path 重新 apply 受影响目标。
- 已合入 `main`：使用新的 revert PR，不重写共享历史。
- Secret 或 age key：只按 `docs/secrets.zh.md` 的轮换流程操作；不要删除唯一可用的 identity。
