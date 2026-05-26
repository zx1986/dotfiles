# Delta Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Switch from `diff-so-fancy` to `delta` for git diff highlighting across macOS and Linux.

**Architecture:** Update installation scripts to include `delta` (via `brew` on macOS and `asdf` on Linux), and configure `.gitconfig` to use `delta` as the default pager.

**Tech Stack:** `git`, `delta`, `asdf`, `homebrew`, `chezmoi`.

---

### Task 1: Update Installation Scripts

**Files:**
- Modify: `run_once_before_00_install_packages.sh.tmpl`
- Modify: `dot_tool-versions`

- [x] **Step 1: Add git-delta to Brew packages (macOS)**
- [x] **Step 2: Add delta plugin to ASDF (Linux/Common)**
- [x] **Step 3: Pin delta version in .tool-versions**

### Task 2: Configure Git to use Delta

**Files:**
- Modify: `dot_gitconfig.tmpl`

- [x] **Step 1: Update pager settings**
- [x] **Step 2: Add delta configuration section**
- [x] **Step 3: Update interactive diff filter**
- [x] **Step 4: Clean up legacy diff-highlight colors**

### Task 3: Verification

- [x] **Step 1: Run chezmoi apply**
  Run: `chezmoi apply` (Note: In this environment, we are editing the source files in `~/dotfiles`)
- [x] **Step 2: Verify delta is installed**
  Run: `delta --version`
  Expected: `delta 0.18.2`
- [x] **Step 3: Verify git configuration**
  Run: `git config --get pager.diff`
  Expected: `delta`
- [x] **Step 4: Visual verification**
  Run: `git diff HEAD` (in a repo with changes)
  Expected: Syntax-highlighted diff with line numbers and side-by-side view (if terminal is wide enough).

