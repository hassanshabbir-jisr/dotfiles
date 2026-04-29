
# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/hassanbaig/.lmstudio/bin"
# End of LM Studio CLI section

export PATH="$HOME/.local/bin:$PATH"

# Added by Antigravity
export PATH="/Users/hassanbaig/.antigravity/antigravity/bin:$PATH"

# Zsh completion system (required for fzf-tab)
autoload -U compinit && compinit

# zsh-autosuggestions: grey ghost text as you type, accept with → or End
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf-tab: replace Tab completion UI with fzf (must load after compinit)
source ~/.config/fzf-tab/fzf-tab.plugin.zsh

# Google Cloud SDK
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"
source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc

# AWS CLI completion
complete -C '/opt/homebrew/bin/aws_completer' aws

# awsp: fuzzy-switch AWS profile
awsp() {
  local profile
  profile=$(aws configure list-profiles | fzf --height 40% --prompt "AWS Profile: ")
  [[ -n "$profile" ]] && export AWS_PROFILE="$profile" && echo "Switched to: $profile"
}

# kubectl completion
source <(kubectl completion zsh)
# kubectx/kubens completions are auto-loaded via brew's zsh/site-functions

# helm completion
source <(helm completion zsh)

# kubectx / kubens aliases
alias kctx='kubectx'   # switch context (runs fzf picker if no arg given)
alias kns='kubens'     # switch namespace (runs fzf picker if no arg given)
alias kc='kubectl'

# Neovim as default editor
export EDITOR=nvim
export VISUAL=nvim
alias vim='nvim'
alias vi='nvim'

# bat (modern cat replacement)
alias cat='bat --paging=never'
export BAT_THEME="Catppuccin Mocha"

# eza (modern ls replacement)
alias ls='eza --icons'
alias ll='eza --icons -l --git --sort=modified --reverse'
alias la='eza --icons -la --git --sort=modified --reverse'
alias lt='eza --icons --tree --level=2'

# Starship prompt
eval "$(starship init zsh)"

# fzf shell integration (Ctrl+R history, Ctrl+T file search, Alt+C cd)
source <(fzf --zsh)

# fzf options: show 20 lines, preview files, use fd if available
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"

# Use fd for fzf file listing if available (faster, respects .gitignore)
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# zoxide: smarter cd with frecency tracking
eval "$(zoxide init zsh)"
alias cd='z'

# gitfindclone: search GitHub, pick with fzf, clone to ~/git-repos or $PWD
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

# prompt-engineer (alias: pe): transform raw instructions into a polished LLM prompt
# Uses the first available CLI: gemini → codex → claude
# Copies result to clipboard (macOS) and displays with bat or plain echo
prompt-engineer() {
  local raw_input="$*"
  if [[ -z "$raw_input" ]]; then
    echo "Usage: prompt-engineer <raw instructions>"
    return 1
  fi

  local meta_prompt="You are an expert prompt engineer. Transform the following raw instructions into a high-quality, structured, and effective prompt for a large language model. Focus on clarity, context, and specific constraints to ensure the best possible output. Return ONLY the final prompt, nothing else. Raw instructions: "
  local result=""

  if command -v gemini &>/dev/null; then
    echo "Engineering your prompt using gemini..." >&2
    result=$(gemini -p "${meta_prompt}${raw_input}" -o text 2>/dev/null)
  elif command -v codex &>/dev/null; then
    echo "Engineering your prompt using codex..." >&2
    result=$(codex exec "${meta_prompt}${raw_input}" 2>/dev/null)
  elif command -v claude &>/dev/null; then
    echo "Engineering your prompt using claude..." >&2
    result=$(claude --print "${meta_prompt}${raw_input}" 2>/dev/null)
  else
    echo "Error: No supported LLM CLI (gemini, codex, or claude) found in PATH." >&2
    return 1
  fi

  if [[ -z "$result" ]]; then
    echo "Error: Failed to generate a prompt." >&2
    return 1
  fi

  command -v pbcopy &>/dev/null && echo -n "$result" | pbcopy && echo "✓ Prompt copied to clipboard." >&2

  echo "" >&2
  if command -v bat &>/dev/null; then
    echo "$result" | bat --language=markdown --style=grid --paging=never
  else
    echo "-------------------------------------------"
    echo "$result"
    echo "-------------------------------------------"
  fi
}

alias pe='prompt-engineer'

# zsh-syntax-highlighting: must be sourced last
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

. "$HOME/.cargo/env"
