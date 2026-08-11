# Repository guidance

- Treat this repository as the chezmoi source of truth. Edit source files here; do not hand-edit
  rendered files in `$HOME` and then forget to bring them back with `chezmoi add`.
- Never commit plaintext secrets, age identities, usernames, hostnames, machine-local paths,
  sessions, caches, or generated plugin directories.
- Keep English and Chinese user-facing documentation semantically aligned in the same change.
- Before handing off a change, run `make verify`. This is the same deterministic source check used
  by CI and must not depend on an already-configured HOME.
- After applying a package on a real Mac, run `make health PACKAGE=<name>` and the manual checklist
  in `docs/<name>.md` or `docs/<name>_zh-CN.md`. Live health checks are not CI checks.
- Review `chezmoi diff` before applying. Prefer a target-scoped `chezmoi apply <target>` while
  iterating; reserve a full apply for changes that intentionally cross packages.
- New `run_onchange_*` scripts must be idempotent. If they depend on another source file, embed that
  file's hash in the template so chezmoi can detect the dependency change.
- Do not vendor runtime caches or generated plugin trees. Preserve the exclusions in
  `.chezmoiignore` unless the ownership model is deliberately changing.
- Use Conventional Commits and land changes through a pull request. Do not commit or push directly
  to `main`.
