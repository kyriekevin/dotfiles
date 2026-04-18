<!--
Title should follow Conventional Commits: `<type>(<scope>?): <subject>`
e.g. `feat(zsh): add zinit turbo plugin loader`
-->

## Summary

<!-- 1–2 sentences: what changed and why -->

## Change type

<!-- Primary Conventional-Commit type -->

- [ ] `feat` — new package / functionality
- [ ] `fix` — bug fix
- [ ] `chore` — infrastructure, hooks, CI, dependency bumps
- [ ] `docs` — documentation only
- [ ] `refactor` — no behavior change

## Checklist

- [ ] Commit messages follow Conventional Commits (validated by the `commit-msg` hook)
- [ ] `pre-commit run --all-files` passes locally
- [ ] `chezmoi diff` reviewed; no unexpected deletions or permission changes
- [ ] If a new package: entry added to the `Layout` section of `README.md`
- [ ] If a new CLI tool: added to `Brewfile` and verified with `brew bundle check`
- [ ] Tested on:
  - [ ] work Mac
  - [ ] personal Mac
  - [ ] fresh bootstrap (VM or new user)

## Notes for reviewer

<!-- Subtle things, tradeoffs considered, things explicitly out of scope -->
