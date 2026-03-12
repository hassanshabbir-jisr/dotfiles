#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# ── Logging ───────────────────────────────────────────────────────────
info()    { echo "  [info]  $*"; }
success() { echo "  [ok]    $*"; }
warning() { echo "  [warn]  $*"; }
step()    { echo ""; echo "==> $*"; }

# ── Backup helper ────────────────────────────────────────────────────
# Moves a file/dir to the timestamped backup directory, preserving
# its relative path under $HOME so restoring is straightforward.
backup() {
  local target="$1"
  local relative="${target#"$HOME/"}"
  local backup_dest="$BACKUP_DIR/$relative"

  mkdir -p "$(dirname "$backup_dest")"
  mv "$target" "$backup_dest"
  warning "Backed up $target → $backup_dest"
}

# ── Symlink helper ────────────────────────────────────────────────────
# Usage: symlink <source> <destination>
# - Destination already points to source → skip (idempotent)
# - Destination is a symlink to somewhere else → backup target, re-link
# - Destination is a real file/dir → backup it, then link
# - Destination doesn't exist → just link
symlink() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    local current_target
    current_target="$(readlink "$dest")"
    if [ "$current_target" = "$src" ]; then
      success "Already linked: $dest"
      return
    else
      warning "Symlink $dest points to $current_target, updating"
      rm "$dest"
    fi
  elif [ -e "$dest" ]; then
    backup "$dest"
  fi

  ln -s "$src" "$dest"
  success "Linked $dest → $src"
}

# ─────────────────────────────────────────────────────────────────────
step "Starting dotfiles install (backups → $BACKUP_DIR)"

# ── 1. Xcode Command Line Tools ───────────────────────────────────────
step "Checking Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools (follow the prompt)"
  xcode-select --install
  # Wait for installation to complete
  until xcode-select -p &>/dev/null; do sleep 5; done
  success "Xcode Command Line Tools installed"
else
  success "Xcode Command Line Tools already installed"
fi

# ── 2. Homebrew ───────────────────────────────────────────────────────
step "Checking Homebrew"
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Support both Apple Silicon (/opt/homebrew) and Intel (/usr/local)
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
success "Homebrew $(brew --version | head -1)"

# ── 3. Brew packages ──────────────────────────────────────────────────
step "Installing packages from Brewfile"
brew bundle --file="$DOTFILES_DIR/Brewfile" --no-lock
success "Brewfile packages installed"

# ── 4. fzf-tab ────────────────────────────────────────────────────────
step "Checking fzf-tab"
if [ ! -d "$HOME/.config/fzf-tab" ]; then
  info "Cloning fzf-tab"
  git clone https://github.com/Aloxaf/fzf-tab "$HOME/.config/fzf-tab"
  success "fzf-tab installed"
else
  info "Updating fzf-tab"
  git -C "$HOME/.config/fzf-tab" pull --ff-only
  success "fzf-tab up to date"
fi

# ── 5. Symlinks ───────────────────────────────────────────────────────
step "Creating symlinks"
symlink "$DOTFILES_DIR/zshrc"         "$HOME/.zshrc"
symlink "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
symlink "$DOTFILES_DIR/nvim"          "$HOME/.config/nvim"

# ── 6. Default shell ──────────────────────────────────────────────────
step "Checking default shell"
if [ "$SHELL" != "/bin/zsh" ]; then
  info "Setting zsh as default shell"
  chsh -s /bin/zsh
  success "Default shell set to zsh"
else
  success "Default shell is already zsh"
fi

# ── Done ──────────────────────────────────────────────────────────────
echo ""
echo "==> All done!"
echo "    Open a new terminal to apply changes."
echo "    First run of nvim will auto-install all plugins."
if [ -d "$BACKUP_DIR" ]; then
  echo "    Backups saved to: $BACKUP_DIR"
fi
