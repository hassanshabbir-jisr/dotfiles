# dotfiles

Personal macOS development environment. One script sets up everything from a clean macOS install.

## What's included

### Shell
| Tool | Purpose |
|------|---------|
| [zsh](https://www.zsh.org/) | Default shell (built into macOS) |
| [Starship](https://starship.rs/) | Fast, customisable prompt with git, cloud, k8s and GitHub metadata |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder — history search, file picker, directory jump |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Replaces zsh tab completion with fzf popup |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` with frecency tracking (aliased to `cd`) |

### File & text tools
| Tool | Purpose |
|------|---------|
| [eza](https://github.com/eza-community/eza) | Modern `ls` with icons, git status, sorted by modified date |
| [bat](https://github.com/sharkdp/bat) | Modern `cat` with syntax highlighting (Catppuccin Mocha theme) |
| [fd](https://github.com/sharkdp/fd) | Fast `find` replacement, respects `.gitignore` |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast `grep` replacement |
| [tree](https://oldmanprogrammer.net/source.php?dir=projects/tree) | Directory tree listing |
| [btop](https://github.com/aristocratos/btop) | Resource monitor |

### Cloud & Kubernetes
| Tool | Purpose |
|------|---------|
| [gcloud CLI](https://cloud.google.com/sdk/gcloud) | Google Cloud Platform |
| [AWS CLI](https://aws.amazon.com/cli/) | Amazon Web Services |
| [kubectl](https://kubernetes.io/docs/reference/kubectl/) | Kubernetes CLI (via the `kubernetes-cli` formula) |
| [kubectx / kubens](https://github.com/ahmetb/kubectx) | Fast context and namespace switching |
| [helm](https://helm.sh/) | Kubernetes package manager |

> **kubectl note:** OrbStack symlinks its own, older `kubectl` into `/usr/local/bin`. `~/.zprofile` runs `brew shellenv`, which puts Homebrew's `bin` **ahead** of `/usr/local/bin`, so the Homebrew copy (which tracks upstream releases) wins.

### AI CLIs
| Tool | Command | Installed via |
|------|---------|---------------|
| [Claude Code](https://claude.com/claude-code) | `claude` | Official installer (self-updating) |
| [OpenAI Codex](https://openai.com/codex/) | `codex` (`cx`) | Homebrew cask |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | `gemini` (`gm`) | Homebrew formula `gemini-cli` |
| [Antigravity CLI](https://antigravity.google/) | `agy` (`ag`) | Official installer, `agy update` |
| [opencode](https://opencode.ai/) | `opencode` (`oc`) | Homebrew, `anomalyco/tap` |
| [Ollama](https://ollama.com/) | `ollama` (`ol`) | Homebrew formula |

> The `gemini` **cask** is the Gemini desktop app, not the CLI — the Brewfile deliberately uses the `gemini-cli` **formula**. Likewise `codex` exists only as a cask, with no formula.

### Editor
| Tool | Purpose |
|------|---------|
| [Neovim](https://neovim.io/) | Editor, configured via [LazyVim](https://www.lazyvim.org/) |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal git UI, embedded in Neovim |

### Apps (casks)
| App | Purpose |
|-----|---------|
| [Ghostty](https://ghostty.org/) | Terminal emulator |
| [OrbStack](https://orbstack.dev/) | Containers and Linux VMs |
| [VSCodium](https://vscodium.com/) | GUI editor |
| [mkcert](https://github.com/FiloSottile/mkcert) | Locally-trusted development certificates |
| [mole](https://mole.fit/) | macOS deep clean and optimisation |

### Shell helpers
| Command | Purpose |
|---------|---------|
| `awsp [profile]` | Fuzzy-switch `AWS_PROFILE` |
| `ghp [account]` | Fuzzy-switch the active `gh` account, then re-run `gh auth setup-git` |
| `gitfindclone <query>` | Search GitHub, pick with fzf, clone to `~/git-repos` or `$PWD` |

### Prompt features
- **Left side:** directory → git branch/status → command duration → exit code
- **Right side:** ⎈ Kubernetes context (namespace) · ☁ AWS profile (region) ·  GitHub account · GCP project
- The GitHub segment reads `$GITHUB_PROFILE`, exported by `~/.zshrc` and updated by `ghp`
- Exit code shown in red only on non-zero; `❯` turns red on failure, green on success
- Long cluster names are aliased automatically (e.g. `arn:aws:eks:.../prod` → `eks:prod`)

---

## Installation

### Option A — Git clone (recommended)

> On a fresh Mac, running `git` for the first time will prompt you to install Xcode Command Line Tools. Accept it and wait for it to finish before continuing — `install.sh` will handle everything else.

```zsh
git clone https://github.com/hassanshabbir-jisr/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

### Option B — Download ZIP (no git required)

1. Go to https://github.com/hassanshabbir-jisr/dotfiles
2. Click **Code → Download ZIP**
3. Open **Finder → Downloads** and double-click the ZIP to extract it
4. Open **Terminal** (press `Cmd+Space`, type `Terminal`, hit Enter)
5. Run:

```zsh
bash ~/Downloads/dotfiles-main/install.sh
```

> **Note:** GitHub names the extracted folder `dotfiles-main`, not `dotfiles`. The script works from either location — it detects its own directory automatically.

---

## What `install.sh` does

The script is fully idempotent — safe to run multiple times. Each run only changes what is missing or outdated.

| Step | Action |
|------|--------|
| 1 | Checks for Xcode Command Line Tools, installs if missing |
| 2 | Checks for Homebrew, installs if missing (supports Apple Silicon and Intel) |
| 3 | Taps and **trusts** `anomalyco/tap`, then runs `brew bundle install` for everything in `Brewfile` |
| 3b | Installs the AI CLIs that ship their own installers (`claude`, `agy`) |
| 4 | Clones fzf-tab plugin, or `git pull`s it if already present |
| 5 | Creates symlinks (see table below) |
| 5b | Seeds an empty `~/.gitconfig.local` for machine-local git settings |
| 6 | Ensures zsh is the default shell |

> Homebrew refuses to load formulae from untrusted third-party taps, so step 3 must run `brew trust anomalyco/tap` before `brew bundle` — otherwise the `opencode` entry fails the whole bundle.

### Symlinks created

| Link | Target |
|------|--------|
| `~/.zprofile` | `zprofile` |
| `~/.zshrc` | `zshrc` |
| `~/.gitconfig` | `gitconfig` |
| `~/.zsh_completions` | `zsh_completions/` |
| `~/.config/starship.toml` | `starship.toml` |
| `~/.config/nvim` | `nvim/` |

### Why both `zprofile` and `zshrc`

`~/.zprofile` runs once per login shell and builds the environment — `brew shellenv` (which sets `PATH` and `HOMEBREW_PREFIX`) and OrbStack's integration. `~/.zshrc` runs for every interactive shell and holds aliases, completions, functions and the prompt. Keeping `brew shellenv` in `zprofile` is what makes Homebrew's binaries take precedence over `/usr/local/bin`.

### Machine-local git config

`gitconfig` ends with:

```gitconfig
[include]
    path = ~/.gitconfig.local
```

`~/.gitconfig.local` is **not** tracked. Put per-machine identities or credential overrides there; entries in it win over the tracked defaults. This keeps machine-specific state out of the repo while the shared identity, aliases and `gh` credential helpers stay version-controlled.

### Backups

Before replacing any existing file, the script backs it up to:

```
~/.dotfiles-backup/YYYYMMDD-HHMMSS/
```

Each run gets its own timestamped directory so nothing is ever lost. To restore a backup:

```zsh
# List available backups
ls ~/.dotfiles-backup/

# Restore a specific file, e.g. .zshrc from a backup
cp ~/.dotfiles-backup/20260315-143000/.zshrc ~/
```

---

## Post-install

Open a new terminal window, then launch Neovim:

```zsh
nvim
```

Plugin revisions are pinned in `nvim/lazy-lock.json`, which **is** tracked — a fresh machine installs exactly the versions recorded there. To bump them, run `:Lazy update` inside nvim and commit the resulting change.

Sign in to the tools that need it:

```zsh
gh auth login
claude
```

---

## Keeping dotfiles up to date

Because `install.sh` sets up symlinks, any edits made directly to `~/.zshrc`, `~/.zprofile`, `~/.gitconfig`, `~/.config/starship.toml`, or files under `~/.config/nvim/` are **immediately reflected** in `~/dotfiles/` — no copying needed.

To save changes:

```zsh
cd ~/dotfiles
git add -p          # review changes interactively
git commit -m "..."
git push
```

To pull updates on another machine:

```zsh
cd ~/dotfiles
./update.sh
```

`update.sh` pulls, re-syncs the `Brewfile`, updates fzf-tab, and runs `agy update`. Config changes are live immediately via symlinks; re-run `install.sh` only when new symlinks or install steps are added.

### Never commit credentials

`.gitignore` blocks `.npmrc`, `*.pem`, SSH private keys and `.gitconfig.local`. `~/.npmrc` in particular holds registry auth tokens and is intentionally **not** managed by this repo.

---

## Repo structure

```
dotfiles/
├── install.sh          # Bootstrap script
├── update.sh           # Pull + re-sync packages
├── Brewfile            # All Homebrew taps, formulae and casks
├── zprofile            # ~/.zprofile   (login shell environment)
├── zshrc               # ~/.zshrc      (interactive shell)
├── gitconfig           # ~/.gitconfig  (includes ~/.gitconfig.local)
├── starship.toml       # ~/.config/starship.toml
├── zsh_completions/    # ~/.zsh_completions/ (hand-maintained completions)
│   └── _ollama
└── nvim/               # ~/.config/nvim/
    ├── init.lua
    ├── lazyvim.json
    ├── lazy-lock.json  # tracked: pins plugin revisions
    └── lua/
        ├── config/     # keymaps, options, autocmds
        └── plugins/    # plugin overrides (colorscheme etc.)
```
