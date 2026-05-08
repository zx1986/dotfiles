# Clean Zsh Prompt Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Consolidate prompt information to the left side and clear the right prompt.

**Architecture:** Update Spaceship theme order to include `aws`, remove manual `kube_ps1` rprompt hook, and explicitly clear `RPROMPT`.

**Tech Stack:** Zsh, Chezmoi, Bats-core

---

### Task 1: Update Spaceship Prompt Order

**Files:**
- Modify: `.chezmoitemplates/zsh_pre_setup`

- [ ] **Step 1: Add 'aws' to SPACESHIP_PROMPT_ORDER**

Replace:
```bash
  php            # PHP section
  docker         # Docker section
  kubecontext    # Kubectl context section
```
with:
```bash
  php            # PHP section
  docker         # Docker section
  aws            # AWS section
  kubecontext    # Kubectl context section
```

- [ ] **Step 2: Apply changes and verify visually (if possible)**

Run: `./bin/chezmoi apply --force --source .`

- [ ] **Step 3: Commit**

```bash
git add .chezmoitemplates/zsh_pre_setup
git commit -m "feat: add aws section to spaceship prompt order"
```

---

### Task 2: Remove Manual RPROMPT Modification

**Files:**
- Modify: `.chezmoitemplates/zsh_post_setup`

- [ ] **Step 1: Remove the kube_ps1 rprompt hook**

Remove this block:
```bash
# kube-ps1: show current context in RPROMPT
# The plugin is sourced earlier via omz-kube-ps1.plugin.zsh.
# We register a precmd hook here (after Prezto) so that RPROMPT gets set
# on every prompt draw, overriding whatever Prezto's theme puts there.
if (( $+functions[kube_ps1] )); then
  _kube_ps1_rprompt() {
    RPROMPT="$(kube_ps1)"
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _kube_ps1_rprompt
fi
```

- [ ] **Step 2: Explicitly clear RPROMPT at the end of the file**

Add at the very end of `.chezmoitemplates/zsh_post_setup`:
```bash

# Ensure right prompt is empty for a cleaner look
RPROMPT=""
```

- [ ] **Step 3: Apply changes**

Run: `./bin/chezmoi apply --force --source .`

- [ ] **Step 4: Commit**

```bash
git add .chezmoitemplates/zsh_post_setup
git commit -m "feat: remove manual kube_ps1 rprompt hook and clear RPROMPT"
```

---

### Task 3: Add Verification Test

**Files:**
- Modify: `tests/health_check.bats`

- [ ] **Step 1: Add a test to verify RPROMPT is empty**

Append to `tests/health_check.bats`:
```bash

@test "Right prompt (RPROMPT) is empty" {
  run zsh -i -c "echo \"\$RPROMPT\""
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
```

- [ ] **Step 2: Run all health checks**

Run: `make health`
Expected: 5 tests, 0 failures (including the new RPROMPT check)

- [ ] **Step 3: Commit**

```bash
git add tests/health_check.bats
git commit -m "test: add check to ensure RPROMPT is empty"
```
