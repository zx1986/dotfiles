# Task 4: Delta Verification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify the migration of `delta` to native package managers and add an automated health check.

**Architecture:** Update existing BATS test suite and perform manual validation of package status and git configuration.

**Tech Stack:** BATS (Bash Automated Testing System), Git, Homebrew (macOS).

---

### Task 1: Add Health Check for Delta

**Files:**
- Modify: `tests/health_check.bats`

- [ ] **Step 1: Add the delta health check test case**

Add the following test case to the end of `tests/health_check.bats`:

```bash
@test "delta is available and version is 0.18+" {
  run delta --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ "delta 0.18." ]]
}
```

- [ ] **Step 2: Run health check to verify it passes**

Run: `./tests/run_test.sh tests/health_check.bats`
Expected: All tests pass, including the new delta check.

- [ ] **Step 3: Commit health check update**

```bash
git add tests/health_check.bats
git commit -m "test: add health check for delta 0.18+"
```

### Task 2: Manual Verifications (macOS)

- [ ] **Step 1: Verify brew packages**

Run: `brew list git-delta && brew list less`
Expected: `git-delta` and `less` are listed.

- [ ] **Step 2: Verify delta version**

Run: `delta --version`
Expected: `delta 0.18.2` or newer.

- [ ] **Step 3: Verify asdf cleanup**

Run: `asdf plugin list | grep delta`
Expected: No output (delta plugin should be removed).

- [ ] **Step 4: Verify git integration**

Run: `git config --get pager.diff && git config --get interactive.diffFilter`
Expected:
`pager.diff` -> `delta`
`interactive.diffFilter` -> `delta --color-only`

### Task 3: Final Verification and Report

- [ ] **Step 1: Run all health checks**

Run: `./tests/run_test.sh tests/health_check.bats`
Expected: All tests pass.

- [ ] **Step 2: Final Report**
Summarize the findings.
