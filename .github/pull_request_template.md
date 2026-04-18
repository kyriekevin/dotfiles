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
- [ ] `chore` — infrastructure, hooks, dependency bumps
- [ ] `docs` — documentation only
- [ ] `refactor` — no behavior change

## Checklist

<!-- Tick what applies; skip what doesn't. -->

- [ ] Commit messages follow Conventional Commits
- [ ] `pre-commit run --all-files` passes locally
- [ ] `chezmoi diff` reviewed; no surprising deletions or permission changes

If relevant to this PR:

- [ ] New package → entry added to the `Layout` section of `README.md`
- [ ] New CLI tool → added to `Brewfile`
- [ ] Smoke-tested end-to-end on at least one Mac

## Notes for reviewer

<!-- Subtle things, tradeoffs considered, things explicitly out of scope -->
