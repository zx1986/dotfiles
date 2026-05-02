# xProfile — Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/). Supports macOS and Ubuntu 22.04, featuring NvChad v2.5 integration and full offline installation support.

---

## 🚀 Quick Start

Initialize your environment with a single command. The installer auto-detects your OS, installs dependencies (Homebrew/chezmoi), and applies your dotfiles.

```sh
git clone https://github.com/zx1986/xProfile.git ~/xProfile
cd ~/xProfile
make init
```

### Common Commands

| Command | Description |
|---|---|
| `make init`   | **Initialize**: Install dependencies, setup chezmoi, and apply dotfiles. |
| `make update` | **Update (Main Workflow)**: Sync current directory changes to your system. |
| `make clean`  | **Cleanup**: Remove chezmoi managed links and third-party tool directories. |

---

## 🛠️ Major Components

- **Neovim**: Powered by [NvChad v2.5](https://nvchad.com/).
    - **Flash.nvim**: Modern, lightning-fast jump motion.
    - **EasyAlign**: Powerful text alignment tool.
    - **LSP**: Configured for Lua, HTML, CSS, Prettier, etc.
- **Zsh**: Based on the [Prezto](https://github.com/sorin-ionescu/prezto) framework.
- **Tmux**: User-friendly configuration via [Oh My Tmux](https://github.com/gpakosz/.tmux).
- **DevOps**: Pre-configured support for Terraform, Ansible, and Kubernetes (krew/helm).

---

## 📁 Project Layout

```text
xProfile/
├── Makefile                     # Entry point for init and updates
├── dot_*                        # Dotfiles managed by chezmoi
├── dot_zshrc.tmpl               # OS-aware zsh configuration
├── dot_gitconfig.tmpl           # OS-aware Git configuration
├── dot_tmux.conf.local          # Oh My Tmux customizations
├── dot_config/nvim/             # NvChad v2.5 overrides (lua/...)
├── .chezmoitemplates/           # Shared zsh setup fragments
├── run_once_before_00_...sh     # Install packages (git, neovim, etc.)
├── run_once_before_10_...sh     # NvChad starter clone
├── run_once_before_20_...sh     # Prezto installation
├── run_once_before_30_...sh     # Oh My Tmux installation
├── scripts/
│   └── prepare_offline_bundle.sh # Script to bundle all assets for offline use
└── docker/ubuntu/               # Verification environment
```

---

## 📶 Offline Installation (Ubuntu 22.04)

**1. On a machine with internet:**

```sh
./scripts/prepare_offline_bundle.sh
```

**2. Transfer to target:**

```sh
scp -r offline-packages/ user@host:~/.local/share/offline-packages
scp -r xProfile/         user@host:~/xProfile
```

**3. On the offline target:**

```sh
cd ~/xProfile
make init
```

---

## 🧪 Docker Verification

```sh
cd docker/ubuntu
docker compose build
docker compose up -d

# Online verification
docker exec dotfiles_ubuntu_verify bash ~/xProfile/docker/ubuntu/verify.sh

# Offline verification (requires bundle mounted)
docker exec dotfiles_ubuntu_verify bash ~/xProfile/docker/ubuntu/verify.sh --offline
```

---

## Reference

- [chezmoi](https://www.chezmoi.io/)
- [NvChad](https://nvchad.com/)
- [Prezto](https://github.com/sorin-ionescu/prezto)
- [Oh My Tmux](https://github.com/gpakosz/.tmux)
