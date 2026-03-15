# dotfiles

Personal macOS development environment. One script sets up everything from a clean macOS install.

## What's included

### Shell
| Tool | Purpose |
|------|---------|
| [zsh](https://www.zsh.org/) | Default shell (built into macOS) |
| [Starship](https://starship.rs/) | Fast, customisable prompt with git, cloud and k8s metadata |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder — history search, file picker, directory jump |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Replaces zsh tab completion with fzf popup |

### File & text tools
| Tool | Purpose |
|------|---------|
| [eza](https://github.com/eza-community/eza) | Modern `ls` with icons, git status, sorted by modified date |
| [bat](https://github.com/sharkdp/bat) | Modern `cat` with syntax highlighting (Catppuccin Mocha theme) |
| [fd](https://github.com/sharkdp/fd) | Fast `find` replacement, respects `.gitignore` |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast `grep` replacement |

### Cloud & Kubernetes
| Tool | Purpose |
|------|---------|
| [gcloud CLI](https://cloud.google.com/sdk/gcloud) | Google Cloud Platform |
| [AWS CLI](https://aws.amazon.com/cli/) | Amazon Web Services |
| [kubectl](https://kubernetes.io/docs/reference/kubectl/) | Kubernetes CLI |
| [kubectx / kubens](https://github.com/ahmetb/kubectx) | Fast context and namespace switching |
| [helm](https://helm.sh/) | Kubernetes package manager |

### Editor
| Tool | Purpose |
|------|---------|
| [Neovim](https://neovim.io/) | Editor, configured via [LazyVim](https://www.lazyvim.org/) |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal git UI, embedded in Neovim |

### Prompt features
- **Left side:** directory → git branch/status → command duration → exit code
- **Right side:** ⎈ Kubernetes context (namespace) · ☁ AWS profile (region) · GCP project
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
| 3 | Runs `brew bundle` to install all packages from `Brewfile` |
| 4 | Clones fzf-tab plugin, or `git pull`s it if already present |
| 5 | Creates symlinks for `~/.zshrc`, `~/.config/starship.toml`, `~/.config/nvim` |
| 6 | Ensures zsh is the default shell |

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

On first launch, LazyVim will automatically download and install all plugins. Wait for it to finish — this only happens once.

---

## Keeping dotfiles up to date

Because `install.sh` sets up symlinks, any edits made directly to `~/.zshrc`, `~/.config/starship.toml`, or files under `~/.config/nvim/` are **immediately reflected** in `~/dotfiles/` — no copying needed.

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
git pull
# Changes are live immediately via symlinks — no re-running install.sh needed
# unless new tools were added to the Brewfile
```

If new tools were added to `Brewfile`, re-run:

```zsh
bash ~/dotfiles/install.sh
```

---

## Repo structure

```
dotfiles/
├── install.sh        # Bootstrap script
├── Brewfile          # All Homebrew packages and casks
├── zshrc             # ~/.zshrc
├── starship.toml     # ~/.config/starship.toml
└── nvim/             # ~/.config/nvim/
    ├── init.lua
    ├── lazyvim.json
    └── lua/
        ├── config/   # keymaps, options, autocmds
        └── plugins/  # plugin overrides (colorscheme etc.)
```
