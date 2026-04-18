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

# ---- Python ----------------------------------------------------------------
brew "uv"

# ---- Mac App Store CLI -----------------------------------------------------
brew "mas"

# ---- GUI apps --------------------------------------------------------------
cask "ghostty"
cask "karabiner-elements"
