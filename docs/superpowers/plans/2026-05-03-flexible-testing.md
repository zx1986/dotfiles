# Flexible & Lightweight Testing Framework Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Docker-based testing with a local, multi-OS template simulation framework.

**Architecture:** Use `chezmoi execute-template` to render dotfiles into a temporary directory with mocked OS variables (`.chezmoi.os`), then run modular bash assertion suites against the rendered output.

**Tech Stack:** Bash, Chezmoi, Makefile.

---

### Task 1: Setup Test Infrastructure

**Files:**
- Create: `tests/lib_assert.sh`
- Create: `tests/run_test.sh`

- [ ] **Step 1: Create assertion library**
Create `tests/lib_assert.sh` with helper functions for testing.
```bash
#!/bin/bash
PASS=0
FAIL=0

check() {
  local desc="$1"
  local cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    echo "  ✅ $desc"
    PASS=$((PASS+1))
  else
    echo "  ❌ FAIL: $desc"
    FAIL=$((FAIL+1))
  fi
}

report_results() {
  echo ""
  echo "============================================"
  echo " Results: $PASS passed, $FAIL failed"
  echo "============================================"
  [[ $FAIL -eq 0 ]]
}
```

- [ ] **Step 2: Create core test runner**
Create `tests/run_test.sh` to handle OS simulation and orchestration.
```bash
#!/bin/bash
set -e

OS_TYPE=$1 # "linux" or "darwin"
if [[ -z "$OS_TYPE" ]]; then
  echo "Usage: $0 <linux|darwin>"
  exit 1
fi

TMP_HOME=$(mktemp -d -t xprofile-test-XXXXXX)
trap 'rm -rf "$TMP_HOME"' EXIT

echo ">>> Simulating $OS_TYPE environment in $TMP_HOME..."

# Identify templates and regular files
# For simplicity in this dotfiles repo, we'll manually list key files or glob them
FILES=$(find . -maxdepth 1 -name "dot_*" -o -name "run_once_*" | sed 's|./||')

for f in $FILES; do
  TARGET_NAME=$(echo "$f" | sed 's/^dot_//' | sed 's/\.tmpl$//')
  
  if [[ "$f" == *.tmpl ]]; then
    # Render template with mocked OS
    chezmoi execute-template --override-data "{\"chezmoi\": {\"os\": \"$OS_TYPE\"}}" < "$f" > "$TMP_HOME/$TARGET_NAME"
  else
    # Copy regular file
    cp -r "$f" "$TMP_HOME/$TARGET_NAME"
  fi
done

# Export TMP_HOME for suites
export TMP_HOME

# Load assertions
source "$(dirname "$0")/lib_assert.sh"

# Run suites
source "$(dirname "$0")/suite_common.sh"
if [[ "$OS_TYPE" == "linux" ]]; then
  source "$(dirname "$0")/suite_linux.sh"
elif [[ "$OS_TYPE" == "darwin" ]]; then
  source "$(dirname "$0")/suite_macos.sh"
fi

report_results
```

- [ ] **Step 3: Set permissions**
Run: `chmod +x tests/run_test.sh`

- [ ] **Step 4: Commit**
Run: `git add tests/lib_assert.sh tests/run_test.sh && git commit -m "test: add core simulator and assertion library"`

---

### Task 2: Implement Assertion Suites

**Files:**
- Create: `tests/suite_common.sh`
- Create: `tests/suite_linux.sh`
- Create: `tests/suite_macos.sh`

- [ ] **Step 1: Create common suite**
Verify files that should exist on all OSes.
```bash
echo ">>> Running Common Suite..."
check "gitconfig rendered" "[[ -f \$TMP_HOME/gitconfig ]]"
check "gitmessage rendered" "[[ -f \$TMP_HOME/gitmessage ]]"
check "zshrc rendered" "[[ -f \$TMP_HOME/zshrc ]]"
```

- [ ] **Step 2: Create Linux suite**
Verify Linux-specific rendering.
```bash
echo ">>> Running Linux Suite..."
check "No osxkeychain in gitconfig" "! grep -q 'osxkeychain' \$TMP_HOME/gitconfig"
check "APT commands in install script" "grep -q 'apt-get install' \$TMP_HOME/run_once_before_00_install_packages.sh"
```

- [ ] **Step 3: Create macOS suite**
Verify macOS-specific rendering.
```bash
echo ">>> Running macOS Suite..."
check "Has osxkeychain in gitconfig" "grep -q 'osxkeychain' \$TMP_HOME/gitconfig"
check "Brew commands in install script" "grep -q 'brew install' \$TMP_HOME/run_once_before_00_install_packages.sh"
```

- [ ] **Step 4: Commit**
Run: `git add tests/suite_*.sh && git commit -m "test: add modular assertion suites"`

---

### Task 3: Makefile Integration

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Add test targets**
Add `test`, `test-linux`, and `test-macos` to `Makefile`.
```makefile
test: test-macos test-linux ## Run all simulation tests

test-linux: ## Test Linux template rendering
	@bash ./tests/run_test.sh linux

test-macos: ## Test macOS template rendering
	@bash ./tests/run_test.sh darwin
```

- [ ] **Step 2: Verify locally**
Run: `make test`
Expected: All tests pass.

- [ ] **Step 3: Commit**
Run: `git add Makefile && git commit -m "test: integrate simulator with Makefile"`

---

### Task 4: Documentation & Cleanup

**Files:**
- Modify: `README.md`
- Delete: `docker/` (Optional, but user asked for "lightweight")

- [ ] **Step 1: Update README.md**
Replace Docker verification section with the new testing section.
```markdown
## 🧪 Testing

The project uses a lightweight simulation framework to verify template rendering across different OSes without needing Docker.

```sh
make test         # Run all tests (Linux + macOS)
make test-linux   # Test Linux rendering
make test-macos   # Test macOS rendering
```
```

- [ ] **Step 2: Remove old Docker setup**
Run: `rm -rf docker/`

- [ ] **Step 3: Commit**
Run: `git add README.md && git rm -r docker/ && git commit -m "docs: update testing instructions and remove legacy docker setup"`
