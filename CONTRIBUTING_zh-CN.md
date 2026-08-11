# 贡献指南

> [English](CONTRIBUTING.md) · 中文

这份文件只定义 Git 与 PR 协作契约。Source 位置、apply 行为、package 检查和回滚方式见
[维护与修改流程](docs/maintenance_zh-CN.md)。

## 一次性设置

```bash
brew install chezmoi gitleaks uv
uv tool install pre-commit
pre-commit install
```

仓库配置会同时安装 `pre-commit` 和 `commit-msg` hooks。任何时候都可以用 `make verify` 执行完整
交付门禁。

## 分支

`main` 受保护并且必须始终可部署。每次改动建立一个聚焦的类型分支：

| 前缀 | 用途 |
|---|---|
| `feat/<name>` | 新 package 或新行为 |
| `fix/<name>` | Bug 修复 |
| `docs/<name>` | 纯文档修改 |
| `chore/<name>` | CI、hooks、依赖或仓库维护 |

不要直接 commit 或 push `main`。

## Commits 与 PR 标题

遵循 [Conventional Commits](https://www.conventionalcommits.org)：

```text
<type>(<scope>?): <subject>
```

允许的 type：`feat`、`fix`、`chore`、`docs`、`refactor`、`test`、`perf`、`ci`、`build`、
`style`。Scope 优先使用 package 名，例如 `zsh`、`nvim`、`karabiner`、`maintenance` 或
`automation`。Subject 使用祈使语气、小写开头，不加结尾句号。

本地 hooks 校验 commits；`checks` job 另外校验 PR 标题，因为 squash merge 会把它作为最终 commit
subject。

## 开 PR 前

```bash
make verify
chezmoi --source="$PWD" diff
make health PACKAGE=<name>   # 在真实 Mac apply 受影响的 package 后运行
```

如果涉及 GUI 或 TTY，再完成对应 package 文档里的手工 checklist。面向用户的中英文文档要保持
语义一致。

## PR 流程

1. 从类型分支向 `main` 开 PR，填写 PR 模板。
2. 等待 required `checks`，解决所有 review 对话。
3. 默认使用 **Squash merge**。只有保留不同作者或相互独立的 commits 能明显改善历史时才用 rebase。
4. 合并后更新本地 `main`；确认 squash 文件树一致后再删除 feature branch。

Branch protection 要求基于最新 `main` 的 `checks` 成功，管理员也受同一规则约束。`main` 禁止
force-push 和删除。

## Issues 与 labels

使用 bug 或 feature request 模板；空白 issue 已禁用。每个 PR 至少有一个与主要 Conventional
Commit type 对应的 label；`build` 和 `style` 统一归入 `chore`。

## Secrets

永远不要提交明文凭据或 age identity。Gitleaks 和 ignore 只是保险绳，不能代替 review。新增或轮换
按 [Secrets 手册](docs/secrets_zh-CN.md)操作。
