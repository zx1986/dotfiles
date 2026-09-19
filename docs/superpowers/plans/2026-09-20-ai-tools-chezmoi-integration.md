# AI Tools Chezmoi Integration — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Register AI CLI tools (npm globals, npx skills) into chezmoi's automated installation pipeline, using `run_onchange` for incremental updates.

**Architecture:** Data-driven approach — `.chezmoidata.yaml` declares tool lists, a new `run_onchange_before_07` script installs them via npm/npx. Existing antigravity script (06) is also migrated to `run_onchange`. Test runner is updated to handle `run_onchange_before_*` prefixes.

**Tech Stack:** chezmoi templates (Go text/template), Bash, bats-core, npm/npx

## Global Constraints

- macOS only (Linux deferred — use `{{ if eq .chezmoi.os "darwin" }}` guard)
- Respect `is_offline` flag — skip network installs when `{{ if not (index . "is_offline") }}`
- No version pinning for npm globals — always install latest
- Follow existing project conventions for script structure and test patterns
- All scripts use `#!/bin/bash` and `set -e`

---

### Task 1: Update test runner to handle `run_onchange` prefix

The test runner (`tests/run_test.sh`) only strips `run_once_before_`, `run_once_`, and `run_always_` prefixes. It must also handle `run_onchange_before_` before we rename any scripts.

**Files:**
- Modify: `tests/run_test.sh:33-46`

**Interfaces:**
- Consumes: nothing
- Produces: Test runner that correctly renders `run_onchange_before_*` scripts into `$TMP_HOME/` with stripped prefix names (e.g., `run_onchange_before_06_install_antigravity.sh.tmpl` → `06_install_antigravity.sh`)

- [ ] **Step 1: Write the failing test**

Run the current test suite to establish baseline, then check that the runner's `find` + `sed` pipeline would handle a `run_onchange_before_*` file:

```bash
make test-macos
```

Expected: PASS (baseline). Note that the `find` command on line 33 only matches `run_*`, which already covers `run_onchange_*`. But the `sed` on line 37 does not strip the `run_onchange_before_` prefix.

- [ ] **Step 2: Fix the sed pipeline in `run_test.sh`**

In `tests/run_test.sh`, update line 37 to also strip the `run_onchange_before_` prefix:

```bash
  TARGET_NAME=$(echo "$f" | sed 's/^run_once_before_//' | sed 's/^run_onchange_before_//' | sed 's/^run_once_//' | sed 's/^run_always_//' | sed '.tmpl$//')
```

- [ ] **Step 3: Run tests to verify nothing broke**

```bash
make test-macos
```

Expected: PASS (same as baseline — no `run_onchange` files exist yet)

- [ ] **Step 4: Commit**

```bash
git add tests/run_test.sh
git commit -m "fix: test runner handles run_onchange_before_ script prefix"
```

---

### Task 2: Rename antigravity script to `run_onchange`

Rename the existing `run_once_before_06` to `run_onchange_before_06` so that adding new plugins to `.chezmoidata.yaml` triggers automatic re-installation on `make update`.

**Files:**
- Rename: `run_once_before_06_install_antigravity.sh.tmpl` → `run_onchange_before_06_install_antigravity.sh.tmpl`
- Modify: `tests/suite_common.sh:8-9` (update filename reference in test assertions)

**Interfaces:**
- Consumes: Task 1's updated test runner (handles `run_onchange_before_` prefix)
- Produces: Antigravity install script now re-runs on YAML changes

- [ ] **Step 1: Rename the script file**

```bash
git mv run_once_before_06_install_antigravity.sh.tmpl run_onchange_before_06_install_antigravity.sh.tmpl
```

- [ ] **Step 2: Update test assertion filename reference**

In `tests/suite_common.sh`, update line 8 to reference the new rendered filename. The rendered name stays the same (`06_install_antigravity.sh`) because the test runner strips the prefix. No change needed to the rendered filename assertion.

Verify by checking: after Task 1's sed fix, `run_onchange_before_06_install_antigravity.sh.tmpl` → `06_install_antigravity.sh`. The existing assertion on line 8 checks for `$TMP_HOME/06_install_antigravity.sh` which is still correct.

No file changes needed in `suite_common.sh` for this step.

- [ ] **Step 3: Run tests to verify**

```bash
make test-macos
make test-linux
```

Expected: PASS — the rendered filename is unchanged, just the chezmoi trigger behavior changes.

- [ ] **Step 4: Commit**

```bash
git add run_onchange_before_06_install_antigravity.sh.tmpl
git commit -m "refactor: migrate antigravity install script to run_onchange

Allows 'make update' to automatically install newly added plugins
when .chezmoidata.yaml changes, instead of requiring a fresh 'make init'."
```

---

### Task 3: Update `.chezmoidata.yaml`

Add the `ai_tools` section and remove `Egonex-AI/Understand-Anything` from antigravity plugins.

**Files:**
- Modify: `.chezmoidata.yaml:11-17` (antigravity plugins list + new ai_tools section)
- Modify: `tests/suite_common.sh:9` (remove Understand-Anything test assertion)

**Interfaces:**
- Consumes: nothing
- Produces: `ai_tools.npm_globals` list (`["@colbymchenry/codegraph", "neovim"]`) and `ai_tools.npx_skills` list (`["tt-a1i/archify"]`) available to chezmoi templates

- [ ] **Step 1: Update `.chezmoidata.yaml`**

Replace the `antigravity` section and add `ai_tools`:

```yaml
antigravity:
  plugins:
    - https://github.com/obra/superpowers
    - https://github.com/DietrichGebert/ponytail
    - https://github.com/mattpocock/skills

ai_tools:
  npm_globals:
    - "@colbymchenry/codegraph"
    - neovim
  npx_skills:
    - "tt-a1i/archify"
```

- [ ] **Step 2: Update test assertion — remove Understand-Anything check**

In `tests/suite_common.sh`, remove line 9:

```
check "antigravity installation script installs Egonex-AI/Understand-Anything" "grep -q 'Understand-Anything' \$TMP_HOME/06_install_antigravity.sh"
```

- [ ] **Step 3: Run tests to verify**

```bash
make test-macos
make test-linux
```

Expected: PASS — the antigravity script no longer references Understand-Anything, and the test no longer checks for it.

- [ ] **Step 4: Commit**

```bash
git add .chezmoidata.yaml tests/suite_common.sh
git commit -m "feat: add ai_tools config and remove Understand-Anything plugin

Adds npm_globals and npx_skills lists under ai_tools in chezmoidata.
Removes Egonex-AI/Understand-Anything from antigravity plugins."
```

---

### Task 4: Create the AI tools install script

Create `run_onchange_before_07_install_ai_tools.sh.tmpl` that reads from `.chezmoidata.yaml` and installs npm globals and npx skills.

**Files:**
- Create: `run_onchange_before_07_install_ai_tools.sh.tmpl`

**Interfaces:**
- Consumes: `.chezmoidata.yaml` fields: `.ai_tools.npm_globals`, `.ai_tools.npx_skills`, `.chezmoi.os`, `.is_offline`
- Produces: Executable chezmoi script that installs codegraph + neovim via npm and archify via npx skills

- [ ] **Step 1: Write the template rendering test**

In `tests/suite_common.sh`, add assertions at the end of the file:

```bash
check "ai_tools installation script rendered" "[[ -f \$TMP_HOME/07_install_ai_tools.sh ]]"
check "ai_tools script installs codegraph" "grep -q '@colbymchenry/codegraph' \$TMP_HOME/07_install_ai_tools.sh"
check "ai_tools script installs neovim npm" "grep -q 'neovim' \$TMP_HOME/07_install_ai_tools.sh"
check "ai_tools script installs archify" "grep -q 'tt-a1i/archify' \$TMP_HOME/07_install_ai_tools.sh"
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
make test-macos
```

Expected: FAIL — `07_install_ai_tools.sh` does not exist yet.

- [ ] **Step 3: Create `run_onchange_before_07_install_ai_tools.sh.tmpl`**

```bash
#!/bin/bash
set -e

{{ if eq .chezmoi.os "darwin" -}}
{{- if not (index . "is_offline") }}
# === AI Tools Installation (macOS) ===
# Data-driven from .chezmoidata.yaml ai_tools section.
# This script re-runs whenever the tool lists change (run_onchange).

# --- npm global packages ---
if command -v npm >/dev/null 2>&1; then
  echo "Installing npm global packages..."
  {{- range .ai_tools.npm_globals }}
  if ! npm list -g "{{ . }}" >/dev/null 2>&1; then
    echo "  Installing {{ . }}..."
    npm install -g "{{ . }}"
  else
    echo "  {{ . }} already installed."
  fi
  {{- end }}
else
  echo "Warning: npm not found, skipping npm global packages."
fi

# --- npx skills ---
if command -v npx >/dev/null 2>&1; then
  echo "Installing npx skills..."
  {{- range .ai_tools.npx_skills }}
  echo "  Installing skill {{ . }}..."
  npx -y skills add "{{ . }}" -g --yes || echo "Warning: Failed to install skill {{ . }}"
  {{- end }}
else
  echo "Warning: npx not found, skipping npx skills."
fi

echo "AI tools installation complete."
{{- else }}
echo "Offline mode: skipping AI tools installation."
{{- end }}
{{ else -}}
echo "AI tools installation: Linux support not yet implemented."
{{ end -}}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
make test-macos
```

Expected: PASS — all four new assertions should pass.

- [ ] **Step 5: Also run Linux tests to verify no breakage**

```bash
make test-linux
```

Expected: PASS — the script renders with the "Linux support not yet implemented" message.

- [ ] **Step 6: Commit**

```bash
git add run_onchange_before_07_install_ai_tools.sh.tmpl tests/suite_common.sh
git commit -m "feat: add AI tools install script managed by chezmoi

Installs npm globals (@colbymchenry/codegraph, neovim) and
npx skills (tt-a1i/archify) on macOS. Uses run_onchange to
automatically re-run when tool lists change in .chezmoidata.yaml."
```

---

### Task 5: Add health checks for AI tools

Add bats test cases to verify that codegraph CLI is installed and functional.

**Files:**
- Modify: `tests/health_check.bats` (append new test cases)

**Interfaces:**
- Consumes: codegraph CLI installed by Task 4
- Produces: Health check verification for `codegraph` binary

- [ ] **Step 1: Add codegraph health check**

Append to `tests/health_check.bats`:

```bash
@test "codegraph is available" {
  run command -v codegraph
  [ "$status" -eq 0 ]
}
```

Note: We do NOT add an archify health check because `npx skills add -g` installs it as an agent skill file, not as a CLI binary in PATH. Its presence is verified by the template rendering test in Task 4.

- [ ] **Step 2: Run health check to verify**

```bash
make health
```

Expected: PASS — codegraph is already installed on this machine at `/opt/homebrew/bin/codegraph` (via the existing manual `npm install -g`).

- [ ] **Step 3: Commit**

```bash
git add tests/health_check.bats
git commit -m "test: add codegraph health check"
```

---

### Task 6: Final verification

Run the full test suite and verify end-to-end.

**Files:** none (verification only)

**Interfaces:**
- Consumes: All previous tasks
- Produces: Confidence that everything works

- [ ] **Step 1: Run all template rendering tests**

```bash
make test
```

Expected: All tests PASS for both macOS and Linux.

- [ ] **Step 2: Run health checks**

```bash
make health
```

Expected: All tests PASS, including the new codegraph check.

- [ ] **Step 3: Dry-run chezmoi apply to verify template rendering**

```bash
chezmoi apply --source "$(pwd)" --dry-run --verbose 2>&1 | grep -E '(onchange|07_install)'
```

Expected: Shows the new `run_onchange_before_07` script is recognized by chezmoi.

- [ ] **Step 4: Verify `.chezmoidata.yaml` is correct**

```bash
chezmoi execute-template --source . --init '{{ .ai_tools.npm_globals | join ", " }}'
```

Expected: `@colbymchenry/codegraph, neovim`

- [ ] **Step 5: Commit any remaining changes and verify clean state**

```bash
git status
git log --oneline -5
```

Expected: Clean working tree with all tasks committed.
