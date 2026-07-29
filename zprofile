# ~/.zprofile — login shell environment (managed by dotfiles)
#
# Runs once per login shell, before ~/.zshrc. Everything here is about
# building PATH and exporting environment; interactive niceties (aliases,
# completions, prompt) belong in ~/.zshrc.

# ── Homebrew ──────────────────────────────────────────────────────────
# `brew shellenv` exports HOMEBREW_PREFIX and prepends Homebrew's bin to
# PATH. Prepending matters: it puts brew's kubectl ahead of the older copy
# OrbStack symlinks into /usr/local/bin.
# Supports both Apple Silicon (/opt/homebrew) and Intel (/usr/local).
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ── OrbStack ──────────────────────────────────────────────────────────
# Container/VM CLI integration. OrbStack rewrites this block in ~/.zprofile
# on install; it is kept here so a fresh machine has it from the start.
[ -f "$HOME/.orbstack/shell/init.zsh" ] && . "$HOME/.orbstack/shell/init.zsh" 2>/dev/null

: # ensure a zero exit status regardless of the guards above
