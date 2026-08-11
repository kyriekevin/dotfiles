<!--
Title should follow Conventional Commits: `<type>(<scope>?): <subject>`
e.g. `feat(zsh): add zinit turbo plugin loader`

标题遵循 Conventional Commits：`<type>(<scope>?): <subject>`
例：`feat(zsh): add zinit turbo plugin loader`
-->

## Summary / 概述

<!-- 1–2 sentences: what changed and why / 一两句：改了什么、为什么 -->

## Change type / 变更类型

<!-- Primary Conventional-Commit type / 主要的 Conventional-Commit 类型 -->

- [ ] `feat` — new package / functionality · 新包或新功能
- [ ] `fix` — bug fix · bug 修复
- [ ] `chore` — infrastructure, hooks, dependency bumps · 基础设施 / hooks / 依赖升级
- [ ] `docs` — documentation only · 纯文档
- [ ] `refactor` — no behavior change · 纯重构（无行为变化）

## Checklist / 检查清单

<!-- Tick what applies; skip what doesn't. / 勾选适用项；不适用的跳过。 -->

- [ ] Commit messages follow Conventional Commits · Commit 信息符合 Conventional Commits
- [ ] `make verify` passes locally · 本地 `make verify` 全绿
- [ ] `chezmoi diff` reviewed; no surprising deletions or permission changes · 已 review `chezmoi diff`，没有意外的删除或权限变化
- [ ] English and Chinese docs stay semantically aligned · 中英文文档保持语义一致

If relevant to this PR / 与本 PR 相关时：

- [ ] New package → entry added to the `Layout` section of `README.md` · 新包已加入 `README.md` 的 `Layout` 小节
- [ ] New CLI tool → added to `Brewfile` · 新 CLI 工具已加入 `Brewfile`
- [ ] Applied only the intended targets and ran `make health PACKAGE=<name>` · 只 apply 预期目标，并运行了对应 package 的 live health
- [ ] Completed the package's manual GUI / TTY checklist · 完成了对应 package 的 GUI / TTY 手工检查

## Notes for reviewer / 给 reviewer 的说明

<!-- Subtle things, tradeoffs considered, things explicitly out of scope / 微妙之处、权衡、明确不在本 PR 范围内的事项 -->
