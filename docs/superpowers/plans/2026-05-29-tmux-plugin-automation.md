# Tmux Plugin Automation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Automate tmux plugin installation via TPM during initialization to ensure a ready-to-use environment.

**Architecture:** Create a `run_once_after` script that calls TPM's internal headless installer. Add a health check to verify plugin installation.

**Tech Stack:** tmux, TPM, bash, BATS (testing)

---

### Task 1: Create Tmux Plugin Installation Script

**Files:**
- Create: `run_once_after_30_install_tmux_plugins.sh`

- [ ] **Step 1: Create the setup script**

```bash
#!/bin/sh

# Automated TPM plugin installation
# This script runs after dotfiles are applied to ensure ~/.tmux.conf.local is present.

INSTALLER="$HOME/.tmux/plugins/tpm/bin/install_plugins"

if [ -f "$INSTALLER" ]; then
  echo "Installing Tmux plugins via TPM..."
  # Run the installer. It will read plugins from ~/.tmux.conf.local (via symlink from ~/.tmux.conf)
  "$INSTALLER"
  echo "Tmux plugins installed successfully."
else
  echo "WARN: TPM installer not found at $INSTALLER"
  echo "Ensure 'run_once_before_30_install_oh_my_tmux.sh' has run successfully."
fi
```

- [ ] **Step 2: Make the script executable**

Run: `chmod +x run_once_after_30_install_tmux_plugins.sh`
Expected: File is executable.

- [ ] **Step 3: Commit**

```bash
git add run_once_after_30_install_tmux_plugins.sh
git commit -m "feat: add run_once_after script for tmux plugin installation"
```

---

### Task 2: Add Tmux Plugin Health Check

**Files:**
- Modify: `tests/health_check.bats`

- [ ] **Step 1: Add plugin existence check to `tests/health_check.bats`**

Add this test to the end of the file:

```bash
@test "tmux plugins are installed" {
  # Check for at least one default plugin from dot_tmux.conf.local
  [ -d "$HOME/.tmux/plugins/tmux-sensible" ]
}
```

- [ ] **Step 2: Run tests**

Run: `make update && make health`
Expected: TPM installer runs during `make update`, and all 13 tests pass.

- [ ] **Step 3: Commit**

```bash
git add tests/health_check.bats
git commit -m "test: add health check for tmux plugins"
```
