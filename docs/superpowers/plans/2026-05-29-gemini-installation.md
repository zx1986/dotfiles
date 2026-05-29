# Gemini-CLI Installation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Automate Gemini-CLI and extensions installation for both macOS and Ubuntu, centralizing configuration in `.chezmoidata.yaml`.

**Architecture:** Define extensions in `.chezmoidata.yaml`, create a dedicated `run_once` script for Gemini setup (including Node.js/npm on Ubuntu), and clean up the existing package installation script.

**Tech Stack:** chezmoi, bash, npm, Homebrew, BATS (testing)

---

### Task 1: Centralize Gemini Configuration

**Files:**
- Modify: `.chezmoidata.yaml`

- [ ] **Step 1: Add Gemini extensions list to `.chezmoidata.yaml`**

Add the `gemini` block to the end of the file.

```yaml
gemini:
  extensions:
    - https://github.com/obra/superpowers
```

- [ ] **Step 2: Verify YAML syntax**

Run: `python3 -c 'import yaml, sys; yaml.safe_load(open(".chezmoidata.yaml"))'`
Expected: No output (exit code 0).

- [ ] **Step 3: Commit**

```bash
git add .chezmoidata.yaml
git commit -m "feat: centralize gemini extensions in .chezmoidata.yaml"
```

---

### Task 2: Create Dedicated Gemini Setup Script

**Files:**
- Create: `run_once_before_05_install_gemini.sh.tmpl`

- [ ] **Step 1: Create the setup script with cross-platform logic**

```bash
#!/bin/bash

# --- Platform Specific Installation ---
{{ if eq .chezmoi.os "linux" -}}
# Ubuntu: Install Node, NPM, and Gemini-CLI via NPM
if ! command -v npm >/dev/null; then
  echo "Installing nodejs and npm..."
  sudo apt-get update -qq
  sudo apt-get install -y nodejs npm
fi

if ! command -v gemini >/dev/null; then
  echo "Installing gemini-cli globally..."
  sudo npm install -g @google/gemini-cli
fi
{{ end -}}

# --- Common Extension Installation ---
if command -v gemini >/dev/null; then
{{- range .gemini.extensions }}
  echo "Installing gemini extension: {{ . }}..."
  gemini extensions install {{ . }} || true
{{- end }}
fi
```

- [ ] **Step 2: Make the script executable and verify template**

Run: `chmod +x run_once_before_05_install_gemini.sh.tmpl && chezmoi execute-template < run_once_before_05_install_gemini.sh.tmpl`
Expected: Output showing the bash script logic, with the extension URL interpolated if running on Linux or macOS.

- [ ] **Step 3: Commit**

```bash
git add run_once_before_05_install_gemini.sh.tmpl
git commit -m "feat: add dedicated gemini installation script"
```

---

### Task 3: Cleanup Package Installation Script

**Files:**
- Modify: `run_once_before_00_install_packages.sh.tmpl`

- [ ] **Step 1: Remove Gemini from macOS brew list and extension block**

Modify `run_once_before_00_install_packages.sh.tmpl`.

Remove `gemini-cli` from the `brew install` line.
Old: `brew install git tig bit-git curl asdf zsh coreutils gemini-cli neovim ripgrep fd gcc fzf bats`
New: `brew install git tig bit-git curl asdf zsh coreutils neovim ripgrep fd gcc fzf bats`

Remove this entire block:
```bash
# Install gemini-cli superpowers extension
if command -v gemini >/dev/null; then
  echo "Installing gemini-cli superpowers extension..."
  gemini extensions install https://github.com/obra/superpowers || true
fi
```

- [ ] **Step 2: Verify script integrity**

Run: `chezmoi execute-template < run_once_before_00_install_packages.sh.tmpl`
Expected: Output showing the remaining package installation logic without Gemini references.

- [ ] **Step 3: Commit**

```bash
git add run_once_before_00_install_packages.sh.tmpl
git commit -m "refactor: move gemini installation to dedicated script"
```

---

### Task 4: Add Gemini Health Check

**Files:**
- Modify: `tests/health_check.bats`

- [ ] **Step 1: Add Gemini availability check to `tests/health_check.bats`**

Add this test to the end of the file:

```bash
@test "gemini-cli is available" {
  run command -v gemini
  [ "$status" -eq 0 ]
}
```

- [ ] **Step 2: Run tests**

Run: `./tests/run_test.sh tests/health_check.bats`
Expected: Tests pass (if gemini-cli is already in path from current session or after `make update`).

- [ ] **Step 3: Commit**

```bash
git add tests/health_check.bats
git commit -m "test: add health check for gemini-cli"
```
