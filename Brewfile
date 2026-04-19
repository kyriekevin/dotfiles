# Brewfile — declarative Homebrew manifest.
#
# Applied on every content change via run_onchange_after_20-brew-bundle.sh.tmpl.
# Baseline check:  brew bundle check --verbose --file=Brewfile

# ---- Core: chezmoi + secrets + GitHub --------------------------------------
# Also installed by bootstrap.sh (chicken-and-egg). Listed here so Brewfile is
# the single source of truth; `brew bundle` is idempotent, no double-install.
brew "chezmoi"
brew "age"
brew "gh"
brew "gitleaks"

# ---- Shell utilities -------------------------------------------------------
brew "bat"
brew "eza"
brew "fd"
brew "ripgrep"
brew "fzf"
brew "zoxide"
brew "starship"
brew "fastfetch"
brew "tealdeer"   # provides `tldr` (Rust implementation)

# ---- Git -------------------------------------------------------------------
brew "lazygit"
brew "git-delta"  # binary is `delta`

# ---- Editor ----------------------------------------------------------------
brew "neovim"

# ---- File manager (yazi) ---------------------------------------------------
# yazi auto-detects these on PATH for previewers; no yazi.toml wiring needed.
#   ffmpegthumbnailer → video first-frame thumbs
#   imagemagick       → HEIC/RAW and other non-native image formats
#   poppler           → PDF page preview via `pdftoppm`
#   sevenzip          → archive listing (zip/7z/rar)
brew "yazi"
brew "ffmpegthumbnailer"
brew "imagemagick"
brew "poppler"
brew "sevenzip"

# ---- Python ----------------------------------------------------------------
brew "uv"

# ---- Node.js ---------------------------------------------------------------
# Required by Claude Code plugins that ship .mjs hooks (e.g. openai-codex's
# SessionStart/SessionEnd/Stop lifecycle hooks) and by the PreToolUse guard
# `npx block-no-verify@1.1.2`. `bun` is not a drop-in replacement here — the
# hooks rely on Node's native ESM/stream semantics.
brew "node"

# ---- Claude Code companion CLIs --------------------------------------------
# ccusage: reads ~/.claude/projects/**/*.jsonl transcripts and reports token
# usage by day/week/month/session/block — `/stats`-style numbers without
# launching Claude, and a stable input any skill/script that needs usage
# data can shell out to. Deps: node only.
brew "ccusage"

# ---- Mac App Store CLI -----------------------------------------------------
brew "mas"

# ---- Fonts -----------------------------------------------------------------
# NF variant is required by starship (powerline triangles + MDI glyphs like
# the mac icon); CN variant covers CJK comments/messages. Terminal's
# font-family needs to point at "Maple Mono NF CN".
cask "font-maple-mono-nf-cn"

# ---- GUI apps --------------------------------------------------------------
cask "ghostty"
cask "karabiner-elements"
