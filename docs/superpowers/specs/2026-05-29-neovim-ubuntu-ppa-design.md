# Neovim Ubuntu PPA Installation Design

This document outlines the design for upgrading the Neovim installation on Ubuntu to use the `neovim-ppa/unstable` repository, ensuring compatibility with NvChad v2.5.

## 1. Problem Statement
The current Ubuntu installation script does not include Neovim. While the NvChad setup script is present, it requires Neovim to be installed on the system. Default Ubuntu repositories often provide older versions of Neovim that are incompatible with modern NvChad configurations.

## 2. Proposed Changes

### 2.1 Update Linux Package Installation
Modify the Linux-specific section of the package installation script to include the Neovim PPA.

**Files to Modify:**
- `run_once_before_00_install_packages.sh.tmpl`

**Logic:**
1. Check if the operating system is Linux and `apt-get` is available.
2. Add the `ppa:neovim-ppa/unstable` repository.
3. Update package lists.
4. Install `neovim`.

### 2.2 Health Check Verification
Add a test case to verify that Neovim is installed and meets the minimum version requirement (0.9+).

**Files to Modify:**
- `tests/health_check.bats`

## 3. Implementation Plan

### Step 1: Update `run_once_before_00_install_packages.sh.tmpl`
```bash
# === Linux (Ubuntu 22.04): Online Install ===
{{- if not (index . "is_offline") }}
if command -v apt-get >/dev/null; then
  echo "Adding Neovim PPA..."
  sudo add-apt-repository -y ppa:neovim-ppa/unstable
  
  echo "Installing core packages via apt..."
  sudo apt-get update -qq
  sudo apt-get install -y zsh tmux git curl wget unzip build-essential fd-find bat fzf tig ripgrep bats neovim
fi
...
```

### Step 2: Add Health Check
```bash
@test "neovim is installed and version is 0.9+" {
  run nvim --version
  [ "$status" -eq 0 ]
  # Check for 0.9 or 0.10 or 0.11 etc.
  [[ "$output" =~ "NVIM v0."([9]|[1-9][0-9]) ]]
}
```

## 4. Verification Strategy

### 4.1 Manual Verification
1. Run `make update`.
2. Verify `nvim --version` shows v0.9.0 or higher.
3. Run `nvim` to ensure it starts and loads the NvChad configuration.

### 4.2 Automated Testing
1. Run `make health` (or `bats tests/health_check.bats`) to confirm the new test passes.
