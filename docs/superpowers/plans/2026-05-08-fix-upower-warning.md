# Fix UPower Warning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resolve UPower warnings by removing the `battery` section from the prompt.

**Architecture:** Update `SPACESHIP_PROMPT_ORDER` in the pre-setup template and verify with health checks.

**Tech Stack:** Zsh, Chezmoi, Bats-core

---

### Task 1: Remove Battery Section

**Files:**
- Modify: `.chezmoitemplates/zsh_pre_setup`

- [ ] **Step 1: Remove battery from SPACESHIP_PROMPT_ORDER**

Remove the line `  battery        # Battery level and status` from `.chezmoitemplates/zsh_pre_setup`.

```bash
<<<<
  line_sep       # Line break
  battery        # Battery level and status
  jobs           # Background jobs indicator
====
  line_sep       # Line break
  jobs           # Background jobs indicator
>>>>
```

- [ ] **Step 2: Apply changes via chezmoi**

Run: `./bin/chezmoi apply --force --source .`

- [ ] **Step 3: Verify zsh starts without errors**

Run: `zsh -i -c "exit" 2>&1`
Expected: Empty output (no UPower warnings).

- [ ] **Step 4: Run health checks**

Run: `make health`
Expected: 5 tests, 0 failures.

- [ ] **Step 5: Commit**

```bash
git add .chezmoitemplates/zsh_pre_setup
git commit -m "fix: remove battery section from prompt to resolve upower warnings"
```
