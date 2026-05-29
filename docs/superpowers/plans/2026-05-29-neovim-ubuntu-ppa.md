# Neovim Ubuntu PPA Installation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install Neovim v0.9+ on Ubuntu systems using the `neovim-ppa/unstable` repository to ensure compatibility with NvChad v2.5.

**Architecture:** Update the Linux package installation script to add the Neovim PPA and include `neovim` in the package list. Add a BATS health check to verify the installed version.

**Tech Stack:** chezmoi, bash, apt, BATS (testing)

---

### Task 1: Update Linux Package Installation Script

**Files:**
- Modify: `run_once_before_00_install_packages.sh.tmpl`

- [ ] **Step 1: Add Neovim PPA and package to Ubuntu install block**

Modify `run_once_before_00_install_packages.sh.tmpl` to add the PPA before updating apt and installing packages.

```bash
# === Linux (Ubuntu 22.04): Online Install ===

{{- if not (index . "is_offline") }}
if command -v apt-get >/dev/null; then
  echo "Adding Neovim PPA..."
  sudo add-apt-repository -y ppa:neovim-ppa/unstable

  echo "Installing core packages via apt..."
  sudo apt-get update -qq
  # Added packages for parity with macOS and to pass verification
  sudo apt-get install -y zsh tmux git curl wget unzip build-essential fd-find bat fzf tig ripgrep bats neovim
fi
```

- [ ] **Step 2: Verify template rendering**

Run: `chezmoi execute-template < run_once_before_00_install_packages.sh.tmpl | grep -A 10 "Adding Neovim PPA"`
Expected: Output showing the bash commands to add the PPA and install `neovim`.

- [ ] **Step 3: Commit**

```bash
git add run_once_before_00_install_packages.sh.tmpl
git commit -m "feat: add neovim ppa and package to linux setup"
```

---

### Task 2: Add Neovim Health Check

**Files:**
- Modify: `tests/health_check.bats`

- [ ] **Step 1: Add Neovim version check to `tests/health_check.bats`**

Add this test to the end of the file:

```bash
@test "neovim is installed and version is 0.9+" {
  run nvim --version
  [ "$status" -eq 0 ]
  # Check for 0.9 or 0.10 or 0.11 etc.
  [[ "$output" =~ "NVIM v0."([9]|[1-9][0-9]) ]]
}
```

- [ ] **Step 2: Run tests**

Run: `make update && make health`
Expected: Neovim is installed via the PPA and all 10 tests pass (including the version check).

- [ ] **Step 3: Commit**

```bash
git add tests/health_check.bats
git commit -m "test: add health check for neovim version"
```
