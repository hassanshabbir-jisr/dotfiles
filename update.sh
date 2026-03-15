#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()    { echo "  [info]  $*"; }
success() { echo "  [ok]    $*"; }
step()    { echo ""; echo "==> $*"; }

# ── 1. Pull latest changes ────────────────────────────────────────────
step "Pulling latest dotfiles"
git -C "$DOTFILES_DIR" pull --ff-only

# ── 2. Sync new Homebrew packages ─────────────────────────────────────
step "Syncing Homebrew packages"
brew bundle --file="$DOTFILES_DIR/Brewfile" --no-lock
success "Brewfile packages up to date"

# ── 3. Update fzf-tab ─────────────────────────────────────────────────
step "Updating fzf-tab"
if [ -d "$HOME/.config/fzf-tab" ]; then
  git -C "$HOME/.config/fzf-tab" pull --ff-only
  success "fzf-tab updated"
else
  info "fzf-tab not found, run install.sh first"
fi

# ── Done ──────────────────────────────────────────────────────────────
echo ""
echo "==> Done! Open a new terminal for shell changes to take effect."
echo "    If Neovim plugins changed, run :Lazy sync inside nvim."
