
# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/hassanbaig/.lmstudio/bin"
# End of LM Studio CLI section

export PATH="$HOME/.local/bin:$PATH"

# Added by Antigravity
export PATH="/Users/hassanbaig/.antigravity/antigravity/bin:$PATH"

# Zsh completion system (required for fzf-tab)
autoload -U compinit && compinit

# fzf-tab: replace Tab completion UI with fzf (must load after compinit)
source ~/.config/fzf-tab/fzf-tab.plugin.zsh

# Google Cloud SDK
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"
source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc

# AWS CLI completion
complete -C '/opt/homebrew/bin/aws_completer' aws

# kubectl completion
source <(kubectl completion zsh)
# kubectx/kubens completions are auto-loaded via brew's zsh/site-functions

# helm completion
source <(helm completion zsh)

# kubectx / kubens aliases
alias kctx='kubectx'   # switch context (runs fzf picker if no arg given)
alias kns='kubens'     # switch namespace (runs fzf picker if no arg given)

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
