# dotfiles

Personal macOS dotfiles managed with [chezmoi](https://www.chezmoi.io) + [age](https://github.com/FiloSottile/age).

## Quickstart (fresh Mac)

```bash
# 1. Install Homebrew: https://brew.sh

# 2. Put the age private key in place (transfer from existing Mac via iCloud Drive / USB)
mkdir -p ~/.config/chezmoi && chmod 700 ~/.config/chezmoi
cp /path/to/key.txt ~/.config/chezmoi/key.txt && chmod 600 ~/.config/chezmoi/key.txt

# 3. Bootstrap
sh -c "$(curl -fsSL https://raw.githubusercontent.com/kyriekevin/dotfiles/main/bootstrap.sh)"
```

On first run, chezmoi will prompt for:
- `git_email` — the email to put in `~/.gitconfig`
- `is_work` — true on the work Mac, false on the personal one

## Source dir

This repo lives at `~/.dotfiles` instead of chezmoi's default `~/.local/share/chezmoi`. All `chezmoi` commands therefore need `--source=$HOME/.dotfiles`, or set `sourceDir = "~/.dotfiles"` in `~/.config/chezmoi/chezmoi.toml`.

## Layout

- `dot_*` / `private_*` / `encrypted_*` / `*.tmpl` — chezmoi [source state attributes](https://www.chezmoi.io/reference/source-state-attributes/)
- `run_once_before_*` / `run_onchange_after_*` — apply-time hooks
- `Brewfile` — declared packages (applied via a `run_onchange_after_*` hook)

## Related repos (selectively useful; not required)

- <https://github.com/nousresearch/hermes-agent>
- _(future: self-authored Claude agents / skills)_

## License

MIT — see [LICENSE](LICENSE).
