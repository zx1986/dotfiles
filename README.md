# xProfile — Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/). Supports macOS and Ubuntu 22.04, featuring NvChad v2.5 integration.

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
└── tests/                       # Lightweight OS simulation tests

---

## 🧪 Testing

The project uses a lightweight simulation framework to verify template rendering across different OSes without needing Docker. This is significantly faster and allows testing macOS logic on macOS and Linux logic on Linux (or any OS supported by chezmoi).

```sh
make test         # Run all tests (Linux + macOS)
make test-linux   # Test Linux rendering simulation
make test-macos   # Test macOS rendering simulation
```

---

## Reference

- [chezmoi](https://www.chezmoi.io/)
- [NvChad](https://nvchad.com/)
- [Prezto](https://github.com/sorin-ionescu/prezto)
- [Oh My Tmux](https://github.com/gpakosz/.tmux)
