# Cleanup Dead Prezto Code Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove unused variable `COMP_DIR` and related comment from `run_once_before_20_install_prezto.sh`.

**Architecture:** Surgical removal of dead code at the end of the script.

**Tech Stack:** Shell script, Git

---

### Task 1: Remove dead code

**Files:**
- Modify: `run_once_before_20_install_prezto.sh`

- [ ] **Step 1: Remove dead COMP_DIR definition and comment**

Replace:
```bash
  # Install extra completions into Prezto
  COMP_DIR="$HOME/.zprezto/modules/completion/external/src"
fi
```
with:
```bash
fi
```

- [ ] **Step 2: Verify the file content**

Run: `cat run_once_before_20_install_prezto.sh`
Expected: The last few lines should just be the closing `fi` of the main block.

- [ ] **Step 3: Commit the cleanup**

Run:
```bash
git add run_once_before_20_install_prezto.sh
git commit -m "chore: remove dead COMP_DIR variable from prezto install script"
```
