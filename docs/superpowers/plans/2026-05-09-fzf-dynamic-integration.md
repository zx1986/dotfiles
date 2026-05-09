# Dynamic fzf Shell Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure `fzf` keybindings and completion work automatically across macOS and Linux by dynamically detecting and sourcing integration files.

**Architecture:** Update the macOS installation script to include `fzf`, and modify the Zsh post-setup template to dynamically find and source `fzf` integration files from common package manager locations (`brew`, `apt`).

**Tech Stack:** Shell (Zsh, Bash), chezmoi templates.

---

### Task 1: Update macOS Installation Script

**Files:**
- Modify: `run_once_before_00_install_packages.sh.tmpl`

- [ ] **Step 1: Add fzf to brew install list**

Add `fzf` to the `brew install` command for macOS.

```bash
<<<<
brew install git tig bit-git curl asdf zsh coreutils gemini-cli neovim ripgrep fd gcc
====
brew install git tig bit-git curl asdf zsh coreutils gemini-cli neovim ripgrep fd gcc fzf
>>>>
```

- [ ] **Step 2: Commit changes**

```bash
git add run_once_before_00_install_packages.sh.tmpl
git commit -m "fix: add fzf to macOS brew installation list"
```

### Task 2: Implement Dynamic fzf Detection in Zsh

**Files:**
- Modify: `.chezmoitemplates/zsh_post_setup`

- [ ] **Step 1: Replace static fzf source with dynamic detection**

Replace the old `~/.fzf.zsh` check with logic that searches for integration files in Homebrew and apt locations.

```bash
<<<<
# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
====
# fzf
if command -v fzf >/dev/null; then
  # Completion and key-bindings paths
  local fzf_shell_paths=(
    "/opt/homebrew/opt/fzf/shell"      # Homebrew (Apple Silicon)
    "/usr/local/opt/fzf/shell"         # Homebrew (Intel)
    "/usr/share/doc/fzf/examples"      # Ubuntu/Debian
  )

  # Fallback for manual install
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

  for base in $fzf_shell_paths; do
    if [ -d "$base" ]; then
      [ -f "$base/completion.zsh" ] && source "$base/completion.zsh"
      [ -f "$base/key-bindings.zsh" ] && source "$base/key-bindings.zsh"
      break
    fi
  done
fi
>>>>
```

- [ ] **Step 2: Commit changes**

```bash
git add .chezmoitemplates/zsh_post_setup
git commit -m "feat: implement dynamic fzf detection and sourcing"
```

### Task 3: Update and Run Verification Tests

**Files:**
- Modify: `tests/suite_common.sh`

- [ ] **Step 1: Add test case for fzf integration**

Update `tests/suite_common.sh` to ensure the new `fzf` detection logic is present in the rendered `.zshrc`.

```bash
<<<<
  assert_file_contains "$HOME_DIR/.zshrc" "SPACESHIP_PROMPT_ORDER"
====
  assert_file_contains "$HOME_DIR/.zshrc" "SPACESHIP_PROMPT_ORDER"
  assert_file_contains "$HOME_DIR/.zshrc" "fzf_shell_paths"
>>>>
```

- [ ] **Step 2: Run macOS simulation tests**

Run: `make test-macos`
Expected: All tests PASS, including the new fzf check.

- [ ] **Step 3: Run Linux simulation tests**

Run: `make test-linux`
Expected: All tests PASS, including the new fzf check.

- [ ] **Step 4: Commit test updates**

```bash
git add tests/suite_common.sh
git commit -m "test: add verification for fzf dynamic detection"
```
