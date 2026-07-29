# Brewfile — managed by dotfiles
# Install everything with: brew bundle --file=Brewfile

# ── Taps ──────────────────────────────────────────────────────────────
# Third-party tap providing opencode. Homebrew refuses to load formulae
# from untrusted taps, so install.sh runs `brew trust` on it before
# `brew bundle`.
tap "anomalyco/tap"

# ── Shell ─────────────────────────────────────────────────────────────
brew "starship"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"

# ── File & text tools ─────────────────────────────────────────────────
brew "bat"
brew "btop"
brew "eza"
brew "fd"
brew "fzf"
brew "ripgrep"
brew "tree"
brew "zoxide"

# ── Dev tooling ───────────────────────────────────────────────────────
brew "gh"
brew "lazygit"
brew "mkcert"
brew "neovim"
brew "node"

# ── Cloud & Kubernetes ────────────────────────────────────────────────
brew "awscli"
brew "helm"
brew "kubectx"
brew "kubernetes-cli"   # provides kubectl; ~/.zprofile puts it ahead of OrbStack's older copy

# ── AI CLIs ───────────────────────────────────────────────────────────
brew "gemini-cli"                 # `gemini` — the `gemini` cask is the desktop app, not the CLI
brew "ollama"
brew "anomalyco/tap/opencode"

# ── macOS maintenance ─────────────────────────────────────────────────
brew "mole"

# ── Casks ─────────────────────────────────────────────────────────────
cask "codex"            # OpenAI Codex CLI (cask-only; no formula exists)
cask "gcloud-cli"
cask "ghostty"
cask "orbstack"
cask "vscodium"
