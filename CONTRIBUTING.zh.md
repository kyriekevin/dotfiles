# 贡献指南

> [English](CONTRIBUTING.md) · 中文

本 repo 是个人 dotfiles 脚手架，但从设计上就打算让同事也能复用。下面这些约定让 git 历史保持可读、让 review 更轻。

## 分支

- `main` —— 永远可部署；不要直接 commit
- `feat/<name>` —— 新包 / 新功能（如 `feat/zsh`、`feat/nvim`）
- `fix/<name>` —— bug 修复
- `chore/<name>` —— 杂活（CI、hooks、基础设施、README 润色）
- `docs/<name>` —— 纯文档变更

## Commits

遵循 [Conventional Commits](https://www.conventionalcommits.org)：

```
<type>(<scope>?): <subject>
```

- **type**：`feat`、`fix`、`chore`、`docs`、`refactor`、`test`、`perf`、`ci`、`build`、`style`
- **scope**（可选）：包名 —— `feat(zsh): …`、`fix(karabiner): …`
- **subject**：祈使句、小写开头、无结尾句号

body 和 footer 可选。Breaking change 写在 footer：`BREAKING CHANGE: ...`。

commit 信息由 `commit-msg` pre-commit hook 校验 —— 不符合规范的消息会在本地被拒绝。

## Pull Request

1. 从 `feat/<name>` 分支对 `main` 开 PR —— [PR 模板](.github/pull_request_template.md) 提供了 checklist
2. 通过 **GitHub Web UI** 合并。**默认用 Squash** —— phase PR 通常带 3–5 个 atomic commits，它们的细颗粒度只在 review 阶段有用，合并后 squash 能让 `main` 的 log 保持可扫读。仅当 commits 来自多个作者、或单个 PR 确实跨越了多个独立 feature 且需要保留历史时，才使用 **Rebase**

## Issues

使用提供的模板：

- **Bug**：某份配置（zsh / nvim / karabiner / ...）行为异常
- **Feature request**：新工具、新配置、新自动化

空白 issue 已被禁用 —— 模板让 triage 更快。

## Pre-commit hooks

### 安装 pre-commit（一次性、全局）

推荐路径 —— 通过 [uv](https://github.com/astral-sh/uv)（与其他 Python 工具链一致）：

```bash
# 如果还没装 uv
brew install uv
# …或用官方安装脚本（不依赖 Homebrew）
# curl -LsSf https://astral.sh/uv/install.sh | sh

# 把 pre-commit 作为隔离的全局工具安装
uv tool install pre-commit
```

不想用 uv 的备选：

```bash
brew install pre-commit     # Homebrew 管理
# …或
pipx install pre-commit     # 经典 pipx
```

### 为本 repo 注册 hooks（每次 clone 一次）

```bash
cd ~/.dotfiles
pre-commit install
```

这一条命令会同时注册 `pre-commit` 和 `commit-msg` 两个 hook（配置里有 `default_install_hook_types: [pre-commit, commit-msg]`）。

### 手动跑一遍

```bash
pre-commit run --all-files
```

### 升级 hook 版本

```bash
pre-commit autoupdate
```

### 当前启用的 hooks

| Hook | 作用 |
|---|---|
| `trailing-whitespace`、`end-of-file-fixer`、`mixed-line-ending` | 空白符卫生 |
| `check-added-large-files` | 拦截意外的大二进制 |
| `check-json` / `check-toml` / `check-yaml` | 语法检查 |
| `check-merge-conflict` | 捕捉残留的 conflict 标记 |
| [`gitleaks`](https://github.com/gitleaks/gitleaks) | 扫描已提交的密钥（age key、token） |
| [`conventional-pre-commit`](https://github.com/compilerla/conventional-pre-commit) | 在 commit-msg 阶段强制 Conventional Commits |

## Secrets

永远不要提交明文 secret —— `.gitignore` + `gitleaks` 双重强制。新增 / 编辑 / 轮换流程与常见陷阱见 [docs/secrets.zh.md](docs/secrets.zh.md)。
