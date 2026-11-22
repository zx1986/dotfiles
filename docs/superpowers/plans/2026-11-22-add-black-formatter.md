# Add Black Code Formatter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install the `black` Python formatter CLI on macOS (brew) and Ubuntu (pipx), with simulation tests and a live health check.

**Architecture:** Edit the existing `run_once_before_00_install_packages.sh.tmpl`: append `black` to the macOS `brew install` line; on Ubuntu append `pipx` to the apt line and add a guarded `pipx install black` block. Rendering is verified by `tests/run_test.sh` suites; the installed binary by `tests/health_check.bats`.

**Tech Stack:** chezmoi templates (Go text/template), POSIX sh, bash test suites, bats.

**Spec:** `docs/superpowers/specs/2026-11-22-add-black-formatter-design.md`

## Global Constraints

- Platforms: macOS + Ubuntu online install only; offline mode (`is_offline: true`) must NOT install black.
- macOS installs via `brew`; Ubuntu installs `pipx` via apt, then `pipx install black`.
- No version pinning, no Neovim integration, no black config file.
- Do not run `pipx ensurepath` (`~/.local/bin` is already on PATH via `.chezmoitemplates/zsh_pre_setup`).
- Simulation tests: `make test-macos`, `make test-linux` (render-only, no script execution).

---

### Task 1: macOS — install black via brew

**Files:**
- Modify: `run_once_before_00_install_packages.sh.tmpl:18` (the `brew install ...` line)
- Test: `tests/suite_macos.sh`
- Test: `tests/health_check.bats`

**Interfaces:**
- Consumes: nothing
- Produces: rendered `00_install_packages.sh` (darwin) whose `brew install` line contains `black`

- [ ] **Step 1: Write the failing simulation test**

Append to `tests/suite_macos.sh` (after the `gh in brew install list` line):

```sh
check "black in brew install list" "grep -E -q 'brew install.*\bblack\b' \$TMP_HOME/00_install_packages.sh"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `make test-macos`
Expected: `❌ FAIL: black in brew install list`, non-zero exit.

- [ ] **Step 3: Implement**

In `run_once_before_00_install_packages.sh.tmpl`, change:

```sh
brew install git tmux tig bit-git curl asdf zsh coreutils neovim ripgrep fd gcc fzf bats tree the_silver_searcher git-delta less gh
```

to:

```sh
brew install git tmux tig bit-git curl asdf zsh coreutils neovim ripgrep fd gcc fzf bats tree the_silver_searcher git-delta less gh black
```

- [ ] **Step 4: Run test to verify it passes**

Run: `make test-macos`
Expected: `✅ black in brew install list`, `0 failed`.

- [ ] **Step 5: Add live health check**

Append to `tests/health_check.bats` (after the `gh CLI is available` test):

```bash
@test "black is available" {
  run zsh -i -c "command -v black"
  [ "$status" -eq 0 ]
}
```

(Interactive zsh so `~/.local/bin` is on PATH for the Ubuntu pipx install. This test only passes on a machine where black is installed; it is not run by `make test-*`.)

- [ ] **Step 6: Commit**

```bash
git add run_once_before_00_install_packages.sh.tmpl tests/suite_macos.sh tests/health_check.bats
git commit -m "feat: install black formatter via brew on macOS"
```

---

### Task 2: Ubuntu — install black via pipx

**Files:**
- Modify: `run_once_before_00_install_packages.sh.tmpl` — Linux `sudo apt-get install -y zsh tmux ...` line, and the end of the `if command -v apt-get` block (after the delta `fi`)
- Test: `tests/suite_linux.sh`

**Interfaces:**
- Consumes: nothing from Task 1
- Produces: rendered `00_install_packages.sh` (linux) with `pipx` in the apt install line and a `pipx install black` block

- [ ] **Step 1: Write the failing simulation tests**

Append to `tests/suite_linux.sh` (after the `gh in apt install list` line):

```sh
check "pipx in apt install list" "grep -E -q 'apt-get install.*\bpipx\b' \$TMP_HOME/00_install_packages.sh"
check "black installed via pipx" "grep -q 'pipx install black' \$TMP_HOME/00_install_packages.sh"
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `make test-linux`
Expected: both new checks `❌ FAIL`, non-zero exit.

- [ ] **Step 3: Add pipx to apt line**

Change:

```sh
  sudo apt-get install -y zsh tmux git curl wget unzip build-essential fd-find bat fzf tig ripgrep bats neovim tree silversearcher-ag gh
```

to:

```sh
  sudo apt-get install -y zsh tmux git curl wget unzip build-essential fd-find bat fzf tig ripgrep bats neovim tree silversearcher-ag gh pipx
```

- [ ] **Step 4: Add pipx install block**

Directly after the delta block's closing `fi` (still inside `if command -v apt-get >/dev/null; then`, i.e. before that block's own closing `fi`), insert:

```sh

  # --- Install black via pipx ---
  if ! command -v black >/dev/null && [ ! -x "$HOME/.local/bin/black" ]; then
    echo "Installing black via pipx..."
    pipx install black
  fi
```

The result should look like:

```sh
  if ! command -v delta >/dev/null; then
    ...
    rm "/tmp/${DELTA_DEB}"
  fi

  # --- Install black via pipx ---
  if ! command -v black >/dev/null && [ ! -x "$HOME/.local/bin/black" ]; then
    echo "Installing black via pipx..."
    pipx install black
  fi
fi
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `make test-linux && make test-macos`
Expected: both report `0 failed`.

- [ ] **Step 6: Verify offline mode does not install black**

Run:

```bash
chezmoi execute-template --init --source . --override-data-file .chezmoidata.yaml \
  --override-data '{"chezmoi":{"os":"linux"},"is_offline":true}' \
  run_once_before_00_install_packages.sh.tmpl | grep -c 'pipx install black'
```

Expected: `0`.

- [ ] **Step 7: Syntax-check rendered script**

Run:

```bash
chezmoi execute-template --init --source . --override-data-file .chezmoidata.yaml \
  --override-data '{"chezmoi":{"os":"linux"}}' \
  run_once_before_00_install_packages.sh.tmpl | sh -n && echo OK
```

Expected: `OK`.

- [ ] **Step 8: Commit**

```bash
git add run_once_before_00_install_packages.sh.tmpl tests/suite_linux.sh
git commit -m "feat: install black formatter via pipx on Ubuntu"
```
