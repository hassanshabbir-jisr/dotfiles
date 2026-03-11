#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Starting dotfiles install"

# ── 1. Homebrew ──────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for Apple Silicon
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "==> Homebrew already installed"
fi

# ── 2. Brew packages ─────────────────────────────────────────────────
echo "==> Installing packages from Brewfile"
brew bundle --file="$DOTFILES_DIR/Brewfile"

# ── 3. fzf-tab ───────────────────────────────────────────────────────
if [ ! -d "$HOME/.config/fzf-tab" ]; then
  echo "==> Cloning fzf-tab"
  git clone https://github.com/Aloxaf/fzf-tab "$HOME/.config/fzf-tab"
else
  echo "==> fzf-tab already installed"
fi

# ── 4. Symlinks ───────────────────────────────────────────────────────
symlink() {
  local src="$1"
  local dest="$2"
  local dest_dir
  dest_dir="$(dirname "$dest")"

  mkdir -p "$dest_dir"

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "  Backing up existing $dest → $dest.bak"
    mv "$dest" "$dest.bak"
  fi

  if [ ! -L "$dest" ]; then
    ln -s "$src" "$dest"
    echo "  Linked $dest → $src"
  else
    echo "  Already linked: $dest"
  fi
}

echo "==> Creating symlinks"
symlink "$DOTFILES_DIR/zshrc"        "$HOME/.zshrc"
symlink "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
symlink "$DOTFILES_DIR/nvim"          "$HOME/.config/nvim"

# ── 5. Set zsh as default shell ───────────────────────────────────────
if [ "$SHELL" != "/bin/zsh" ]; then
  echo "==> Setting zsh as default shell"
  chsh -s /bin/zsh
fi

echo ""
echo "==> Done! Open a new terminal to apply changes."
echo "    First run of nvim will auto-install all plugins."
