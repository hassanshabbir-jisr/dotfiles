# ~/.zshrc — interactive shell configuration (managed by dotfiles)
#
# Homebrew's environment (PATH, HOMEBREW_PREFIX) is set in ~/.zprofile.
# HOMEBREW_PREFIX is used throughout so this file works on both Apple
# Silicon (/opt/homebrew) and Intel (/usr/local).
BREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# ── PATH ──────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"                    # claude, agy, uv tools
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"  # Antigravity
export PATH="$PATH:$HOME/.lmstudio/bin"                 # LM Studio CLI (lms)

# ── Completion system (required for fzf-tab) ──────────────────────────
# Homebrew's site-functions must be on fpath *before* compinit, otherwise
# completions shipped by formulae (kubectx, kubens, codex, ...) never load.
# ~/.zsh_completions holds hand-maintained completions (see dotfiles/zsh_completions).
fpath=("$BREW_PREFIX/share/zsh/site-functions" "$HOME/.zsh_completions" $fpath)
autoload -U compinit && compinit

# zsh-autosuggestions: grey ghost text as you type, accept with → or End
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# fzf-tab: replace Tab completion UI with fzf (must load after compinit)
source "$HOME/.config/fzf-tab/fzf-tab.plugin.zsh"

# ── Google Cloud SDK ──────────────────────────────────────────────────
export PATH="$BREW_PREFIX/share/google-cloud-sdk/bin:$PATH"
source "$BREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"

# ── AWS ───────────────────────────────────────────────────────────────
complete -C "$BREW_PREFIX/bin/aws_completer" aws

# awsp: fuzzy-switch AWS profile
awsp() {
  local profile
  profile=$(aws configure list-profiles | fzf --height 40% --prompt "AWS Profile: ")
  [[ -n "$profile" ]] && export AWS_PROFILE="$profile" && echo "Switched to: $profile"
}

# ── GitHub ────────────────────────────────────────────────────────────
# GITHUB_PROFILE is read by starship's custom.github_profile module so the
# active gh account shows in the prompt.
_gh_active_profile() {
  command -v gh >/dev/null 2>&1 || return
  gh auth status --active --hostname github.com 2>&1 |
    awk '/Logged in to .* account / {
      account = $0
      sub(/^.* account /, "", account)
      sub(/ .*/, "", account)
      print account
      exit
    }'
}

export GITHUB_PROFILE="$(_gh_active_profile)"

# ghp: fuzzy-switch GitHub profile
ghp() {
  local profile

  if [[ -n "$1" ]]; then
    profile="$1"
  else
    profile=$(
      gh auth status 2>&1 |
        awk '
          /Logged in to .* account / {
            if (account != "") print account active
            account = $0
            sub(/^.* account /, "", account)
            sub(/ .*/, "", account)
            active = ""
          }
          /Active account: true/ { active = " (active)" }
          END { if (account != "") print account active }
        ' |
        fzf --height 40% --prompt "GitHub Profile: "
    )
    profile="${profile%% *}"
  fi

  [[ -z "$profile" ]] && return

  gh auth switch --hostname github.com --user "$profile" &&
    gh auth setup-git --hostname github.com >/dev/null &&
    export GITHUB_PROFILE="$profile" &&
    echo "Switched to: $profile"
}

# ── Kubernetes ────────────────────────────────────────────────────────
source <(kubectl completion zsh)
source <(helm completion zsh)
# kubectx/kubens completions load from Homebrew's site-functions (see fpath above)
alias kctx='kubectx'   # switch context (runs fzf picker if no arg given)
alias kns='kubens'     # switch namespace (runs fzf picker if no arg given)
alias kc='kubectl'

# ── Editor ────────────────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim
alias vim='nvim'
alias vi='nvim'

# ── Modern CLI replacements ───────────────────────────────────────────
# bat (modern cat)
alias cat='bat --paging=never'
export BAT_THEME="Catppuccin Mocha"

# eza (modern ls)
alias ls='eza --icons'
alias ll='eza --icons -l --git --sort=modified --reverse'
alias la='eza --icons -la --git --sort=modified --reverse'
alias lt='eza --icons --tree --level=2'

# ── AI CLI aliases ────────────────────────────────────────────────────
alias oc='opencode'
alias ol='ollama'
alias cx='codex'
alias gm='gemini'
alias ag='agy'
compdef _ollama ol

# ── Starship prompt ───────────────────────────────────────────────────
eval "$(starship init zsh)"

# ── fzf ───────────────────────────────────────────────────────────────
# shell integration (Ctrl+R history, Ctrl+T file search, Alt+C cd)
source <(fzf --zsh)
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"

# Use fd for fzf file listing if available (faster, respects .gitignore)
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# ── gitfindclone: search GitHub, pick with fzf, clone to ~/git-repos or $PWD ──
gitfindclone() {
  if [[ -z "$1" ]]; then
    echo "Usage: gitfindclone <search query>"
    return 1
  fi

  local repo
  repo=$(gh search repos "$1" --limit 20 | fzf | awk '{print $1}')
  [[ -z "$repo" ]] && echo "Aborted." && return

  local clone_dir="$PWD"
  if [[ -d "$HOME/git-repos" ]]; then
    echo -n "Found $HOME/git-repos. Clone there instead of $PWD? [y/N]: "
    read -r answer
    [[ "$answer" =~ ^[Yy]$ ]] && clone_dir="$HOME/git-repos"
  fi

  echo "Cloning $repo into $clone_dir..."
  gh repo clone "$repo" "$clone_dir/${repo#*/}"
}

# ── mole (macOS cleanup) completion ───────────────────────────────────
if output="$(mole completion zsh 2>/dev/null)"; then eval "$output"; fi

# ── Rust (only present if a toolchain is installed) ───────────────────
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# ── zoxide: smarter cd with frecency tracking ─────────────────────────
# zoxide asks to be initialised last, but zsh-syntax-highlighting genuinely
# must be sourced last to work. zoxide's doctor flags that as a problem and
# prints a warning on every shell start; it is a false positive here, so the
# check is disabled rather than reordering and breaking highlighting.
export _ZO_DOCTOR=0
eval "$(zoxide init zsh)"
alias cd='z'

# ── zsh-syntax-highlighting: must be sourced last ─────────────────────
source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
