# Native Delta Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate `delta` (git-delta) installation from `asdf` to native package managers (Homebrew on macOS and `dpkg` on Ubuntu).

**Architecture:** Update `run_once_before_00_install_packages.sh.tmpl` to install `git-delta` and `less` via Homebrew on macOS, and install `delta` 0.18.2 via `dpkg` on Ubuntu. Remove `asdf` configuration for `delta`.

**Tech Stack:** `chezmoi`, `bash`, `git-delta`, `homebrew`, `dpkg`.

---

### Task 1: Cleanup ASDF Configuration

**Files:**
- Modify: `dot_tool-versions`
- Modify: `run_once_before_00_install_packages.sh.tmpl`

- [x] **Step 1: Remove delta from .tool-versions**

Remove the line `delta 0.18.2` from `dot_tool-versions`.

- [x] **Step 2: Remove delta asdf plugin from installation script**

In `run_once_before_00_install_packages.sh.tmpl`, remove the line:
```bash
  asdf plugin add delta || true
```

- [x] **Step 3: Commit**

```bash
git add dot_tool-versions run_once_before_00_install_packages.sh.tmpl
git commit -m "refactor: remove delta from asdf configuration"
```

---

### Task 2: Implement macOS Native Installation

**Files:**
- Modify: `run_once_before_00_install_packages.sh.tmpl`

- [x] **Step 1: Add git-delta and less to Homebrew list**

In `run_once_before_00_install_packages.sh.tmpl`, update the `brew install` line in the macOS section:

```bash
# Old:
brew install git tmux tig bit-git curl asdf zsh coreutils neovim ripgrep fd gcc fzf bats tree the_silver_searcher

# New:
brew install git tmux tig bit-git curl asdf zsh coreutils neovim ripgrep fd gcc fzf bats tree the_silver_searcher git-delta less
```

- [x] **Step 2: Commit**

```bash
git add run_once_before_00_install_packages.sh.tmpl
git commit -m "feat(macos): install git-delta and less via homebrew"
```

---

### Task 3: Implement Ubuntu Native Installation

**Files:**
- Modify: `run_once_before_00_install_packages.sh.tmpl`

- [x] **Step 1: Add dpkg installation logic for Ubuntu**

In `run_once_before_00_install_packages.sh.tmpl`, find the Ubuntu online install section (under `sudo apt-get install ...`) and add the following logic:

```bash
# ... after apt-get install -y zsh tmux ...

# --- Install delta via dpkg ---
DELTA_VERSION="0.18.2"
DELTA_DEB="git-delta_${DELTA_VERSION}_amd64.deb"
DELTA_URL="https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/${DELTA_DEB}"

if ! command -v delta >/dev/null; then
  echo "Installing delta ${DELTA_VERSION} via dpkg..."
  wget -q "${DELTA_URL}" -O "/tmp/${DELTA_DEB}"
  sudo dpkg -i "/tmp/${DELTA_DEB}"
  rm "/tmp/${DELTA_DEB}"
fi
```

- [x] **Step 2: Commit**

```bash
git add run_once_before_00_install_packages.sh.tmpl
git commit -m "feat(ubuntu): install git-delta via dpkg"
```

---

### Task 4: Verification

- [x] **Step 1: Add health check for delta**

Update `tests/health_check.bats` to include a check for `delta`.

```bash
@test "delta is available and version is 0.18+" {
  run delta --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ "delta 0.18." ]]
}
```

- [x] **Step 2: Verify on macOS**

Run:
```bash
brew list git-delta
brew list less
delta --version
```
Expected: `delta 0.18.2` or newer, and packages listed.

- [x] **Step 3: Verify on Ubuntu (if applicable/simulation)**

Run:
```bash
dpkg -l git-delta
delta --version
```
Expected: `delta 0.18.2`.

- [x] **Step 4: Verify asdf cleanup**

Run:
```bash
asdf plugin list | grep delta
```
Expected: (Empty or delta not listed).

- [x] **Step 5: Verify git integration**

Run:
```bash
git config --get pager.diff
git config --get interactive.diffFilter
```
Expected: `delta` and `delta --color-only`.

