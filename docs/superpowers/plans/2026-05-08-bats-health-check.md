# Bats-core Health Check Tool Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a reusable health check tool using Bats-core to verify the dotfiles environment.

**Architecture:** Introduce `bats-core` as a testing dependency, create a suite of environment tests in `tests/health_check.bats`, and add a `make health` target for easy execution.

**Tech Stack:** Bash, Zsh, Bats-core, Makefile

---

### Task 1: Environment Setup

**Files:**
- Modify: `Makefile`

- [x] **Step 1: Add a check for bats in Makefile**

Modify the `Makefile` to include a helper to check for `bats`.

```makefile
BATS := $(shell command -v bats 2> /dev/null)

.PHONY: check-bats
check-bats:
ifndef BATS
	$(error "bats-core not found. Please install it (e.g., 'sudo apt install bats' or 'npm install -g bats')")
endif
```

- [x] **Step 2: Run the check to verify it fails (if bats is missing)**

Run: `make check-bats`
Expected: Error: "bats-core not found. Please install it..."

- [x] **Step 3: Install bats (manual step for the engineer)**

Run: `sudo apt update && sudo apt install -y bats`
(Or whichever method is appropriate for the environment)

- [x] **Step 4: Run the check to verify it passes**

Run: `make check-bats`
Expected: No output (success).

- [x] **Step 5: Commit**

```bash
git add Makefile
git commit -m "chore: add bats-core dependency check to Makefile"
```

---

### Task 2: Implement Zsh Startup Test

**Files:**
- Create: `tests/health_check.bats`

- [x] **Step 1: Create the basic Bats file with Zsh startup test**

```bash
#!/usr/bin/env bats

@test "Zsh starts without errors" {
  run zsh -i -c "exit"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
```

- [x] **Step 2: Run the test to verify it passes (assuming clean environment)**

Run: `bats tests/health_check.bats`
Expected: 1 test, 0 failures

- [x] **Step 3: Commit**

```bash
git add tests/health_check.bats
git commit -m "test: add zsh startup health check"
```

---

### Task 3: Implement Theme & Plugin Tests

**Files:**
- Modify: `tests/health_check.bats`

- [x] **Step 1: Add theme and plugin tests**

Update `tests/health_check.bats` to include checks for Spaceship theme, core aliases, and completions.

```bash
#!/usr/bin/env bats

@test "Zsh starts without errors" {
  run zsh -i -c "exit"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "Spaceship theme is loaded" {
  run zsh -i -c "typeset -f spaceship_prompt > /dev/null && ([[ -n \$SPACESHIP_VERSION ]] || [[ -n \$SPACESHIP_ROOT ]]) && echo 'found'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"found"* ]]
}

@test "Core aliases are available and mapped correctly (g, k)" {
  run zsh -i -c "[[ \"\$(alias g)\" == \"g=git\" ]] && [[ \"\$(alias k)\" == \"k=kubectl\" ]] && echo 'found'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"found"* ]]
}

@test "Zsh completions are available (git, kubectl)" {
  run zsh -i -c "[[ \"\$(whence -w _git)\" == \"_git: function\" ]] && [[ \"\$(whence -w _kubectl)\" == \"_kubectl: function\" ]] && echo 'found'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"found"* ]]
}
```

- [x] **Step 2: Run the tests**

Run: `bats tests/health_check.bats`
Expected: 4 tests, 0 failures

- [x] **Step 3: Commit**

```bash
git add tests/health_check.bats
git commit -m "test: add theme and plugin health checks"
```

---

### Task 4: Final Makefile Integration

**Files:**
- Modify: `Makefile`

- [x] **Step 1: Add the 'health' target**

```makefile
.PHONY: health
health: check-bats
	bats tests/health_check.bats
```

- [x] **Step 2: Run the final command**

Run: `make health`
Expected: Bats output showing 3 passing tests.

- [x] **Step 3: Commit**

```bash
git add Makefile
git commit -m "feat: add make health command"
```
