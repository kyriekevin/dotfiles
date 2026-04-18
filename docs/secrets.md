# Secrets runbook

Secrets are age-encrypted at rest in this repo and decrypted transparently on `chezmoi apply`. This doc is the operator's manual — bootstrap a new Mac, add a secret, edit an existing one, rotate the key.

## How it works

| Piece | Location | Committed? |
|---|---|---|
| Age **private key** (identity) | `~/.config/chezmoi/key.txt`, chmod `600` | **Never** — blocked by `.gitignore` + `gitleaks` |
| Age **public key** (recipient) | `.chezmoi.toml.tmpl` → `[age].recipient` | Yes — public keys are safe to publish |
| Encrypted secret file | `<source>/encrypted_private_<name>.age` | Yes — ciphertext only |
| Plaintext target | `~/.config/.../<name>` (e.g. `~/.config/zsh/secrets.zsh`) | Blocked by `.gitignore` (`**/secrets.zsh`) |

## New-Mac bootstrap (before `chezmoi init --apply`)

Encrypted files can only be decrypted on a machine that holds the private key. Transfer it out-of-band:

```bash
mkdir -p ~/.config/chezmoi && chmod 700 ~/.config/chezmoi
cp /path/to/key.txt ~/.config/chezmoi/key.txt && chmod 600 ~/.config/chezmoi/key.txt
```

Transfer channels: iCloud Drive, AirDrop, USB. **Never** email, Slack, or anything indexed.

## Add a new encrypted secret

The easy path — when the plaintext already exists at the target:

```bash
chezmoi add --encrypt ~/.config/zsh/secrets.zsh
```

The from-scratch path — when you're authoring content fresh and don't want a plaintext file on disk first:

```bash
# 1. Compose plaintext in a throwaway temp file
vim /tmp/secrets_plain.zsh

# 2. Encrypt directly into the source tree (note the filename prefix — see Gotchas)
age -r "$(awk -F' = ' '/^\s*recipient/ {gsub(/"/, "", $2); print $2}' \
    ~/.config/chezmoi/chezmoi.toml)" \
    -o ~/.dotfiles/dot_config/zsh/encrypted_private_secrets.zsh.age \
    /tmp/secrets_plain.zsh

# 3. Wipe the plaintext
shred -u /tmp/secrets_plain.zsh 2>/dev/null || rm -f /tmp/secrets_plain.zsh

# 4. Verify chezmoi resolves it correctly
chezmoi --source=$HOME/.dotfiles managed | grep secrets.zsh
chezmoi --source=$HOME/.dotfiles cat ~/.config/zsh/secrets.zsh
```

## Edit an existing secret

Opens `$EDITOR` on decrypted content, re-encrypts on save:

```bash
chezmoi edit ~/.config/zsh/secrets.zsh
chezmoi apply                 # or: chezmoi apply ~/.config/zsh/secrets.zsh
```

## Rotate the age key

1. `age-keygen -o ~/.config/chezmoi/key-new.txt && chmod 600 ~/.config/chezmoi/key-new.txt` — generate new pair
2. For every `encrypted_*.age` file in source: decrypt with old key, re-encrypt with new public key
   ```bash
   age -d -i ~/.config/chezmoi/key.txt <file> \
     | age -r <new-pub> -o <file>
   ```
3. Update `[age].recipient` in `.chezmoi.toml.tmpl` **and** `~/.config/chezmoi/chezmoi.toml`
4. Swap: `mv key-new.txt key.txt` — **distribute the new private key to every Mac that needs it**
5. Commit the re-encrypted files + recipient change in one atomic PR

## Gotchas (learned the hard way)

**Filename prefix order matters.** chezmoi parses source attributes left-to-right but some combinations short-circuit. Confirmed-working order: `encrypted_private_<name>.age`. The reverse (`private_encrypted_<name>.age`) leaves `encrypted_` in the target filename and `chezmoi cat` reports the path as "not managed".

**`encryption = "age"` must be a top-level key in `chezmoi.toml`.** Placing it after `[data]` makes TOML parse it as `data.encryption`, and chezmoi silently falls back with a warning (`'encryption' not set, using age configuration. Check if 'encryption' is correctly set as the top-level key.`). Put it above every `[section]` header.

**`chezmoi init --promptString key=value` does NOT pre-populate `promptStringOnce`.** The "once" variants always attempt to read from TTY on first run. In practice this only bites non-interactive init (CI, scripts) — on a real Mac bootstrap it prompts normally and works fine. For non-interactive setups, write `~/.config/chezmoi/chezmoi.toml` by hand (that's what the template renders to anyway).

**`.gitignore` safety net.** `**/secrets.zsh` blocks any accidental plaintext leak into the source tree. If you rename the target or add a new secret with a different name, add the new plaintext pattern to `.gitignore` too — don't rely on gitleaks alone.
