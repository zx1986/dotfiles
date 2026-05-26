# Design Spec: Bats-core Health Check Tool

**Goal:** Provide a reusable, automated health check for the dotfiles environment to ensure Zsh starts cleanly and core components (theme, plugins, aliases) are functional.

## 1. Context & Scope
The project currently has a custom testing framework in `tests/`. This new tool will use `bats-core` to provide more structured and readable output for environment-wide health checks.

**Scope:**
- Zsh interactive startup (stderr check).
- Spaceship theme loading.
- Key plugins (Git, Kubectl) and their aliases.
- Reusable `make health` command.

## 2. Approach
We will introduce `bats-core` as a testing dependency and implement a suite of tests that run against the *current* user environment (unlike the existing simulation tests).

### Dependency: Bats-core
- If `bats` is not found, the tool should ideally install it or provide instructions.
- Recommendation: Install via `npm install -g bats` or download to `bin/`.

### Test Suite: `tests/health_check.bats`
- **Test 1: Zsh Startup**
  - Execute `zsh -i -c "exit"`.
  - Assert that no error messages are printed to stderr.
- **Test 2: Theme Loading**
  - Check if `spaceship_setup` (or equivalent theme function) is defined.
  - Verify `$SPACESHIP_VERSION` or `$SPACESHIP_ROOT`.
- **Test 3: Plugins & Aliases**
  - Check if `g` is an alias for `git`.
  - Check if `k` is an alias for `kubectl`.
  - Verify that `_git` or `_kubectl` completions are reachable.

## 3. Architecture
- `tests/health_check.bats`: The Bats test file.
- `Makefile`: Add a `health` target that checks for `bats` and runs the tests.

## 4. Success Criteria
- `make health` runs successfully and reports all tests passing.
- Failures are clearly reported with specific component names.

## 5. Risks & Mitigations
- **Dependency:** `bats` is not a standard system tool. We'll handle this by providing a clear path to installation.
- **Interactive Shells:** Running `zsh -i` in a script can sometimes behave differently. we'll use a clean environment or specific flags if needed.
