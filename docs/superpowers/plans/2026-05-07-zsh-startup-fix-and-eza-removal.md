# Zsh Startup Fix and eza Removal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix "many errors" during Zsh startup on Ubuntu 22.04 by fixing plugin logic, adding missing tool aliases, and completely removing `eza`.

**Architecture:** Robust shell-level fixes using conditional logic and defensive stubs in bundled plugins and aliases.

**Tech Stack:** Zsh, Chezmoi, Shell Scripting.

---

### Task 1: Remove eza references

**Files:**
- Modify: `dot_aliases`
- Modify: `run_once_before_20_install_prezto.sh`
- Delete: `completions/zsh/_eza`

- [ ] **Step 1: Remove eza alias from dot_aliases**

```bash
# Before:
unalias ls
alias ls='eza'

# After (just remove those lines):
# (remove lines 5-7)
```

- [ ] **Step 2: Remove eza completion installation logic**

```bash
# File: run_once_before_20_install_prezto.sh
# Remove lines 36-41:
    # eza completion (bundled in repo at completions/zsh/_eza)
    SRC="${CHEZMOI_SOURCE_DIR:-$(cd "$(dirname "$0")" && pwd)}/completions/zsh/_eza"
    if [ -f "$SRC" ]; then
      cp "$SRC" "$COMP_DIR/_eza"
      echo "Installed _eza completion into Prezto"
    fi
```

- [ ] **Step 3: Delete the eza completion file**

Run: `rm completions/zsh/_eza`

- [ ] **Step 4: Verify eza removal**

Run: `grep -r "eza" .`
Expected: No matches in code files (only in README/docs/investigations).

- [ ] **Step 5: Commit**

```bash
git add dot_aliases run_once_before_20_install_prezto.sh
git rm completions/zsh/_eza
git commit -m "feat: remove all eza configurations"
```

---

### Task 2: Fix Ubuntu Tool Names (fd, bat)

**Files:**
- Modify: `dot_aliases`

- [ ] **Step 1: Add conditional aliases for fd and bat**

Modify `dot_aliases` at the end:

```bash
# Before (end of file):
alias jump="ssh -p ${JUMPPORT} ${JUMPSERVER}"

# After:
alias jump="ssh -p ${JUMPPORT} ${JUMPSERVER}"

# Ubuntu tool name compatibility
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
fi
```

- [ ] **Step 2: Verify aliases (Simulated)**

Run: `fdfind() { :; }; batcat() { :; }; unalias fd bat 2>/dev/null; source dot_aliases; alias fd; alias bat`
Expected: `fd='fdfind'` and `bat='batcat'` are defined as aliases.

- [ ] **Step 3: Commit**

```bash
git add dot_aliases
git commit -m "feat: add Ubuntu compatibility aliases for fd and bat"
```

---

### Task 4: Fix xtrace trigger in omz-kube-ps1

**Files:**
- Modify: `dot_config/zsh/parts/omz-kube-ps1.plugin.zsh`

- [ ] **Step 1: Update debug check**

```bash
# File: dot_config/zsh/parts/omz-kube-ps1.plugin.zsh
# Line 21:
# Before:
[[ -n $DEBUG ]] && set -x

# After:
[[ "$DEBUG" == "true" ]] && set -x
```

- [ ] **Step 2: Verify xtrace behavior**

Run: `DEBUG=false zsh -c "source dot_config/zsh/parts/omz-kube-ps1.plugin.zsh" 2>&1 | grep "+ set -x"`
Expected: No output.

- [ ] **Step 3: Commit**

```bash
git add dot_config/zsh/parts/omz-kube-ps1.plugin.zsh
git commit -m "fix: make xtrace trigger explicit in kube-ps1 plugin"
```

---

### Task 5: Add defensive stub for _omz_register_handler

**Files:**
- Modify: `dot_config/zsh/parts/omz-git.zsh`

- [ ] **Step 1: Add stub at the top of the file**

```bash
# File: dot_config/zsh/parts/omz-git.zsh
# Insert after line 1:

if ! (( $+functions[_omz_register_handler] )); then
  _omz_register_handler() {
    : # No-op stub for Oh My Zsh internal function
  }
fi
```

- [ ] **Step 2: Verify no errors on source**

Run: `zsh -c "source dot_config/zsh/parts/omz-git.zsh"`
Expected: Exit code 0, no "command not found" errors.

- [ ] **Step 3: Commit**

```bash
git add dot_config/zsh/parts/omz-git.zsh
git commit -m "fix: add defensive stub for _omz_register_handler in git plugin"
```

---

### Task 6: Final Verification and Cleanup

**Files:**
- Modify: `tests/run_test.sh` (Optional)

- [ ] **Step 1: Run project tests**

Run: `make test-linux`
Expected: All tests PASS.

- [ ] **Step 2: Update Investigation report (Optional)**

Mark the investigation as resolved in `docs/superpowers/investigations/2026-05-06-zsh-startup-errors.md`.

- [ ] **Step 3: Final Commit**

```bash
git commit --allow-empty -m "chore: complete Zsh startup fix and eza removal"
```
