# Update PATH in Zsh Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `~/.local/bin` to `PATH` in `.chezmoitemplates/zsh_pre_setup`.

**Architecture:** Modify the `.chezmoitemplates/zsh_pre_setup` template to include `~/.local/bin` in the `PATH` variable, ensuring it's available for binaries like `antigravity-cli`.

**Tech Stack:** Zsh, Chezmoi

---

### Task 1: Update PATH in Zsh Configuration

**Files:**
- Modify: `.chezmoitemplates/zsh_pre_setup`

- [ ] **Step 1: Add ~/.local/bin to PATH**

Add the following block before other PATH modifications:
```bash
# Add ~/.local/bin to PATH (used by antigravity-cli and others)
PATH="$HOME/.local/bin:$PATH"
```

In `.chezmoitemplates/zsh_pre_setup`:
```bash
<<<<
# Kubernetes
KUBECONFIG_PATH=~/.kube
====
# Add ~/.local/bin to PATH (used by antigravity-cli and others)
PATH="$HOME/.local/bin:$PATH"

# Kubernetes
KUBECONFIG_PATH=~/.kube
>>>>
```

- [ ] **Step 2: Verify template syntax**

Run: `chezmoi execute-template < .chezmoitemplates/zsh_pre_setup > /tmp/zsh_pre_setup_test`
Expected: The file `/tmp/zsh_pre_setup_test` should contain `PATH="/home/kasm-user/.local/bin:$PATH"` (or equivalent home path).

Check with: `grep "local/bin" /tmp/zsh_pre_setup_test`

- [ ] **Step 3: Commit**

```bash
git add .chezmoitemplates/zsh_pre_setup
git commit -m "chore: add ~/.local/bin to PATH in zsh_pre_setup"
```
