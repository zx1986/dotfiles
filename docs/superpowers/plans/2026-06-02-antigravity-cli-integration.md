# antigravity-cli Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install `antigravity-cli` and ensure its binary (`agy`) is in the `PATH`.

**Architecture:** Use a chezmoi `run_once` script for installation and update `.chezmoitemplates/zsh_pre_setup` for `PATH` management.

**Tech Stack:** Shell script, Chezmoi templates.

---

### Task 1: Update PATH in Zsh Configuration

**Files:**
- Modify: `.chezmoitemplates/zsh_pre_setup`

- [ ] **Step 1: Add ~/.local/bin to PATH**

Update the template to include the local bin directory.

```bash
# Add ~/.local/bin to PATH (used by antigravity-cli and others)
PATH="$HOME/.local/bin:$PATH"
```

Place it before other PATH modifications.

- [ ] **Step 2: Verify template syntax**

Run: `chezmoi execute-template < .chezmoitemplates/zsh_pre_setup > /tmp/zsh_pre_setup_test`
Expected: Output contains `PATH="/home/kasm-user/.local/bin:$PATH"` (or appropriate home dir).

- [ ] **Step 3: Commit**

```bash
git add .chezmoitemplates/zsh_pre_setup
git commit -m "chore: add ~/.local/bin to PATH in zsh_pre_setup"
```

---

### Task 2: Create Installation Script

**Files:**
- Create: `run_once_before_06_install_antigravity.sh.tmpl`

- [ ] **Step 1: Write the installation script**

```bash
#!/bin/bash

# Install antigravity-cli (agy)
# Official installer: https://antigravity.google/cli/install.sh

set -e

if [ ! -f "$HOME/.local/bin/agy" ]; then
    echo "Installing antigravity-cli..."
    curl -fsSL https://antigravity.google/cli/install.sh | bash
else
    echo "antigravity-cli is already installed."
fi

# Final verification
if [ -f "$HOME/.local/bin/agy" ]; then
    echo "Verification successful: agy found in ~/.local/bin"
else
    echo "Error: agy installation failed."
    exit 1
fi
```

- [ ] **Step 2: Set executable permissions (chezmoi will handle this via script name, but we ensure local state)**

Run: `chmod +x run_once_before_06_install_antigravity.sh.tmpl`

- [ ] **Step 3: Commit**

```bash
git add run_once_before_06_install_antigravity.sh.tmpl
git commit -m "feat: add antigravity-cli installation script"
```

---

### Task 3: Apply and Verify

- [ ] **Step 1: Run chezmoi apply**

Run: `chezmoi apply`
Expected: The new installation script should execute.

- [ ] **Step 2: Verify binary exists**

Run: `ls -l ~/.local/bin/agy`
Expected: File exists and is executable.

- [ ] **Step 3: Verify PATH integration**

Run: `zsh -c 'source ~/.zshrc && which agy'`
Expected: `/home/kasm-user/.local/bin/agy`
