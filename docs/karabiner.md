# Karabiner-Elements — key-remapping + sublayer actions

Keyboard key remapping and semantic sublayers built on top of Karabiner-Elements. Only `complex_modifications/*.json` is versioned; the main `karabiner.json` (device selection, profile state) changes too often and stays untracked.

## How it works

Karabiner-Elements runs as a system-level kernel extension + userspace daemon. It intercepts key events before any app (including terminal emulators) sees them, rewrites them per rule, and re-injects the result. Because it runs below the app layer, rules here beat any app-level keybinding.

Two rule files in `assets/complex_modifications/`:

- `caps.json` — base layer (always active): caps↔ctrl↔escape remaps + `ctrl+hjkl` → arrows
- `sublayers.json` — semantic sublayers gated by `ctrl+w` / `ctrl+r` / `ctrl+x` prefix

Chezmoi writes both files to `~/.config/karabiner/assets/complex_modifications/`. Karabiner GUI picks them up automatically; one-time import via `Preferences → Complex Modifications → Add rule` is still required (Karabiner's activation model).

## Why these choices

### Why caps→ctrl (with tap→escape)
User alternates between HHKB (ctrl at caps position) and MacBook built-in keyboard (ctrl at bottom-left). Caps→ctrl makes the MacBook keyboard behave like HHKB. Tap→escape piggybacks on the same key since the plain caps-lock behavior (CAPS toggle) is rarely wanted by vim/shell users.

### Why ctrl+hjkl → arrows (global)
HHKB has no dedicated arrow keys; reaching for arrows on the laptop breaks home-row flow. `ctrl+hjkl` maps vim-style motion to arrows *at Karabiner layer*, so every app receives real arrow events — including apps that don't natively support vim bindings. The mapping is also the foundation the Ghostty chord prefix depends on (see `docs/ghostty.md`).

### Why semantic sublayers, not a single flat prefix
Tmux-style flat `prefix → letter` runs out of mnemonic space fast. Semantic sublayers (`w` = window, `r` = raycast, `x` = system) group actions by domain, so each sublayer's namespace stays small and letters can repeat across domains (e.g., `m` = maximize in `w`, `m` = mute in `x`).

### Why `ctrl` as leader (not hyper / caps-double-tap / right-cmd)
1. Caps is already occupied (→ ctrl/escape).
2. Hyper (cmd+ctrl+opt+shift) is consumed by Raycast's built-in Hyper Key feature — we leave that alone so the user's direct `hyper+space → AI Chat` binding stays working.
3. Right-cmd is uncomfortable for standard fingering on both HHKB and laptop.
4. Most `ctrl+letter` combinations are unused in the user's actual workflow (vi-mode zsh with space-leader nvim means `ctrl+w`, `ctrl+r`, `ctrl+x`, `ctrl+hjkl` are free apart from the arrow mapping).

### Why Raycast deeplinks (not hotkey passthrough)
Every Raycast action is invoked via `open -g raycast://extensions/...`. This decouples Karabiner from Raycast's hotkey registration: swap in Rectangle, Aerospace, or any shell command by editing one `shell_command` string. The `-g` flag is required — without it Raycast steals focus and the target window isn't the one you intended to move.

### Why AI Chat stays as direct `hyper+space` (outside sublayer)
AI Chat is high-frequency. Routing it through `ctrl+r space` (two separate keypresses) adds friction the user didn't want. Raycast's built-in Hyper Key feature stays ON, and the original `hyper+space` hotkey stays in Raycast Extensions.

## Keymap reference

### Base layer (always active)

| Key | Action |
|---|---|
| `caps_lock` (tap) | `escape` |
| `caps_lock` (hold) | `left_control` modifier |
| `left_control` (tap) | `escape` |
| `left_control` (hold) | `left_control` modifier (unchanged) |
| `ctrl+h` | `←` |
| `ctrl+j` | `↓` |
| `ctrl+k` | `↑` |
| `ctrl+l` | `→` |

### `ctrl+w` sublayer — window management (Raycast)

| Key | Action |
|---|---|
| `h` | Left half |
| `l` | Right half |
| `k` | Top half |
| `j` | Bottom half |
| `m` | Maximize |
| `n` | Next display |
| `p` | Previous display |

### `ctrl+r` sublayer — Raycast commands

| Key | Action |
|---|---|
| `s` | Clipboard history |
| `f` | Search files |
| `;` | Translate |
| `e` | Emoji picker |

> AI Chat is deliberately outside this layer — use the direct `hyper+space` Raycast hotkey.

### `ctrl+x` sublayer — macOS system actions (osascript, no Raycast dependency)

| Key | Action | Repeat mode |
|---|---|---|
| `m` | Toggle mute | One-shot (prevents double-toggle on accidental repeat) |
| `=` | Volume +10 | Sticky (`ctrl+x ==== ` → +40% in one chord) |
| `-` | Volume −10 | Sticky (timeout 500ms after last press) |

## Feature deep-dives

### Sublayer timing model (500ms)
Pressing a leader key (`ctrl+w` / `ctrl+r` / `ctrl+x`) sets `layer_{w,r,x} = 1` via Karabiner variables. The action rules fire only when that variable is 1 — matching the layer AND clearing the variable after firing. If no follow-up key arrives within 500ms, `to_delayed_action.to_if_invoked` clears the variable — no stuck-layer state. Adjust the timeout in `sublayers.json` → `parameters["basic.to_delayed_action_delay_milliseconds"]`.

### The `-g` flag on Raycast deeplinks
Raycast's Window Management extension requires the *target app* to be focused when the command runs — not Raycast itself. Using `open raycast://...` without `-g` briefly focuses Raycast, so the extension sees Raycast as the frontmost window and the resize misfires. `open -g` opens the URL "in the background" without activating Raycast, so the previously focused app stays focused and gets resized correctly.

### Coexistence with Ghostty's `ctrl+s` chord prefix
Ghostty has its own `ctrl+s` chord prefix (see `docs/ghostty.md`). Karabiner's sublayers use `ctrl+w / ctrl+r / ctrl+x` — all different letters — so there is no collision. Inside Ghostty: `ctrl+s` → Ghostty chord; `ctrl+w` → Karabiner window layer (fires globally regardless of frontmost app).

### Coexistence with Raycast's Hyper Key
Raycast's Hyper Key feature maps left-option → `cmd+ctrl+opt+shift`. We keep this enabled so the user's historical `hyper+space` binding for AI Chat still works. The tradeoff: left-option is consumed by Raycast and can't be used for typing option-modifier characters. Right-option is untouched.

## Change a setting

1. Edit `dot_config/karabiner/assets/complex_modifications/*.json`
2. `chezmoi diff` → `chezmoi apply`
3. Karabiner GUI picks up file changes automatically; for already-enabled rules, changes take effect immediately
4. If you *added* a new rule: `Preferences → Complex Modifications → Add rule` → enable it once

## Add a new sublayer action

Example: add `ctrl+r c` → open Calendar.

```json
{
    "type": "basic",
    "from": { "key_code": "c", "modifiers": { "optional": ["any"] } },
    "to": [
        { "shell_command": "open -g 'raycast://extensions/raycast/calendar/my-schedule'" },
        { "set_variable": { "name": "layer_r", "value": 0 } }
    ],
    "conditions": [
        { "type": "variable_if", "name": "layer_r", "value": 1 }
    ]
}
```

Append inside the appropriate `ctrl+r layer:` rule's `manipulators` array. Validate with `karabiner_cli --lint-complex-modifications sublayers.json`.

## Health check

### Automated (`tests/karabiner.sh`)

```bash
bash ~/.dotfiles/tests/karabiner.sh
```

Covers:

- Karabiner-Elements installed + `karabiner_cli` on PATH
- Both JSON files present, parse via `jq`, lint-clean per Karabiner's own validator
- Every base-layer and sublayer binding resolves to the expected action (regression guard)
- All three leaders have `to_delayed_action` with 500ms timeout
- AI Chat is *not* in the `ctrl+r` layer (stays as direct hyper+space by design)

### Manual — required after first install

Automated tests only verify the JSON. Runtime behavior requires Karabiner to have *imported + enabled* the rules:

1. `chezmoi apply` writes JSON to `~/.config/karabiner/assets/complex_modifications/`
2. Open Karabiner-Elements → **Preferences → Complex Modifications → Add rule**
3. Under each group (caps / sublayers), click **Enable All**
4. Walk this checklist:

- [ ] Tap `caps_lock` alone → `escape` fires (check: Notes app, caps should not toggle)
- [ ] Hold `caps_lock` + `a` → `ctrl+a` fires (check in terminal: jumps to line start)
- [ ] `ctrl+h/j/k/l` → arrow keys (check in any text field)
- [ ] `ctrl+w h` → window snaps left half (Raycast confirms deeplink first time — click "Always Allow")
- [ ] `ctrl+w l/k/j/m/n/p` → right/top/bottom/max/next-display/prev-display
- [ ] `ctrl+r s` → clipboard history opens
- [ ] `ctrl+r f/;/e` → search files / translate / emoji picker
- [ ] `ctrl+x m` → system mute toggles (menu-bar icon updates)
- [ ] `ctrl+x = / -` → volume +10 / −10
- [ ] Press `ctrl+w` alone, wait 1s, press `h` → nothing happens (timeout cleared layer)
- [ ] AI Chat still fires on `hyper+space` (direct, not via sublayer)

### First-run Raycast approval

Each Raycast deeplink triggers a one-time confirmation dialog the first time it runs. Click **Always Allow** on each (clipboard / search-files / translate / emoji / each window command) — the setting persists in Raycast's `alwaysAllowCommandDeeplinking` plist. Once approved, subsequent runs are silent.

## Troubleshooting

**Rules not taking effect after `chezmoi apply`.**
Karabiner imports are one-time. `chezmoi apply` writes the file but doesn't auto-enable. Open Karabiner GUI → Complex Modifications → Add rule → Enable.

**`ctrl+w h` opens a window but the wrong one got resized.**
Missing `-g` flag on the `open` command. Check `sublayers.json` — every `shell_command` for a `window-management` deeplink must be `open -g 'raycast://...'`.

**Sublayer key "sticks" — next keystroke is still in layer mode.**
Either `to_delayed_action` is missing from the leader rule, or the action rule didn't include `{"set_variable": {"name": "layer_X", "value": 0}}` in its `to` array. Run `bash tests/karabiner.sh` — the `timeout = 500ms` check catches this.

**`ctrl+hjkl` no longer emit arrows.**
Karabiner-Elements daemon might not be running. `pgrep -f karabiner_console_user_server` — if empty, launch Karabiner.app.

**AI Chat stopped firing on `hyper+space`.**
Check Raycast → Preferences → Advanced → Hyper Key is still enabled. This phase intentionally leaves Raycast's Hyper Key ON.

## Gotchas

- **Main `karabiner.json` not tracked.** Device selections, profile names, and per-device tweaks live there and change too often. Only `complex_modifications/*.json` is versioned.
- **Manual import required per machine.** Karabiner's activation model doesn't auto-enable rules found in the assets directory — user must click through the GUI once.
- **Raycast first-run confirmations.** Each deeplink asks for approval the first time it fires. Plan for ~12 clicks on fresh install.
- **Left-option consumed by Raycast.** Because Raycast Hyper Key stays enabled, left-option can't produce option-modifier characters. Right-option still works.
- **Karabiner's kernel extension needs approval.** On a fresh macOS install, System Settings → Privacy & Security → Input Monitoring + Accessibility must both grant Karabiner permission.

## Rebuild from scratch

```bash
# 1. Install Karabiner via Brewfile (already listed)
brew bundle --file=~/.dotfiles/Brewfile

# 2. Grant permissions in System Settings → Privacy & Security
#    - Input Monitoring → Karabiner-Elements
#    - Accessibility → Karabiner-Elements

# 3. Apply dotfiles
chezmoi apply

# 4. Open Karabiner-Elements GUI → Complex Modifications → Add rule
#    Enable all rules under "Base layer" and "Sublayers"

# 5. Verify
bash ~/.dotfiles/tests/karabiner.sh        # static: 37 checks
# Then walk docs/karabiner.md → Health check → Manual
```
