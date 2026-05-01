# Design: NvChad v2.5 Integration

This document outlines the strategy for integrating the NvChad v2.5 Neovim framework into the `xProfile` dotfiles managed by `chezmoi`.

## 1. Goal
Provide a modern, fast, and highly customizable Neovim environment based on NvChad v2.5, while maintaining version control of personal configurations via `chezmoi`.

## 2. Architecture

### 2.1 Bootstrapping Process
The integration uses a two-stage bootstrapping process:
1.  **System Dependencies:** Managed via `run_once_install_packages.sh.tmpl`.
2.  **NvChad Framework:** Managed via `run_once_install_nvchad.sh.tmpl`, which clones the official NvChad starter repository.

### 2.2 Directory Structure
The files will be organized as follows in the `xProfile` repository:

```text
/
├── run_once_install_packages.sh.tmpl (Updated)
├── run_once_install_nvchad.sh.tmpl   (New)
└── dot_config/
    └── nvim/
        └── lua/
            ├── chadrc.lua            (Managed Overwrite)
            ├── options.lua           (Managed Overwrite)
            ├── mappings.lua          (Managed Overwrite)
            └── plugins/
                └── init.lua          (Managed Overwrite)
```

## 3. Implementation Details

### 3.1 Package Installation (`run_once_install_packages.sh.tmpl`)
Add the following packages for macOS (via Homebrew):
- `neovim` (ensuring v0.10+)
- `ripgrep`
- `fd`
- `gcc` (for Treesitter)

### 3.2 NvChad Installation (`run_once_install_nvchad.sh.tmpl`)
This script will:
- Check if `~/.config/nvim` exists.
- If it **does not** exist, clone `https://github.com/NvChad/starter` into `~/.config/nvim`.
- If it **does** exist, skip the installation (per user preference).

### 3.3 Configuration Overwrites
Chezmoi will manage and overwrite the default files in the starter repo:
- **`chadrc.lua`**: The main configuration file for NvChad v2.5.
- **`options.lua`**: For custom Vim settings (e.g., relative line numbers).
- **`mappings.lua`**: For custom keybindings.
- **`plugins/init.lua`**: For adding or overriding plugins via Lazy.nvim.

## 4. Testing & Validation

### 4.1 Success Criteria
- `chezmoi apply` completes without errors.
- `~/.config/nvim` is a valid Git repository tracking NvChad starter.
- `nvim` launches with the NvChad dashboard.
- `:checkhealth` shows all core dependencies (rg, fd, git) are met.
- Personal configurations (e.g., a test mapping) are active.

### 4.2 Manual Verification Steps
1. Run `chezmoi apply`.
2. Open `nvim`.
3. Wait for Lazy.nvim to finish initial plugin synchronization.
4. Verify NvChad version using `:NvChadUpdate` or checking the dashboard.

## 5. Security & Safety
- The installation script uses standard Git cloning over HTTPS.
- No sensitive information (API keys, etc.) will be included in the Neovim configuration files.
