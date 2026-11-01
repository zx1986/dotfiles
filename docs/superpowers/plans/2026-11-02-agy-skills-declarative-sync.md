# Antigravity Skills Declarative Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Manage `~/.gemini/config/skills.json` via chezmoi to mount `~/.agents/skills` in Antigravity CLI (`agy`), remove `mattpocock/skills` from `antigravity.plugins`, and declaratively synchronize the 27 curated `npx skills` packages (including pruning unlisted skills) via `.chezmoidata.yaml` and `run_onchange_before_07_install_ai_tools.sh.tmpl`.

**Architecture:**
1. Track `dot_gemini/config/skills.json` as a static chezmoi dotfile pointing `agy` to `~/.agents/skills`.
2. Update `.chezmoidata.yaml` so `antigravity.plugins` contains only full plugins (`obra/superpowers`, `DietrichGebert/ponytail`) and `ai_tools.npx_skills` defines structured `{ repo, skills }` items.
3. Update `run_onchange_before_07_install_ai_tools.sh.tmpl` to batch-install missing skills per repo with `npx -y skills add <repo> -g -a antigravity-cli -s ... -y` and prune any directory in `~/.agents/skills/` not declared in `.chezmoidata.yaml` via `npx -y skills remove -g -s ... -y`.

**Tech Stack:** chezmoi templates (Go `text/template`), Bash 3.2+ (`/bin/bash` on macOS), `npx skills`, Bats (`health_check.bats`), shell test runner (`tests/run_test.sh`).

## Global Constraints

- Scripts use `#!/bin/bash` and run under macOS `/bin/bash` (Bash 3.2); do not use Bash 4+ features like `declare -A`.
- Do not track runtime or tool-managed files under `~/.gemini/` (`GEMINI.md`, `mcp_config.json`, `config.json`, `antigravity-cli/settings.json`, `antigravity-cli/auth.json`).
- Respect `is_offline` and Darwin OS guards in `run_onchange_before_07_install_ai_tools.sh.tmpl`.
- Ignore `.codegraph/` in both `.gitignore` and `.chezmoiignore`.

---

### Task 1: Ignore `.codegraph/` and Mount `~/.agents/skills` via `dot_gemini/config/skills.json`

**Files:**
- Modify: `.gitignore:1-7`
- Modify: `.chezmoiignore:1-14`
- Create: `dot_gemini/config/skills.json`
- Modify: `tests/suite_common.sh:1-20`

**Interfaces:**
- Produces: `$TMP_HOME/.gemini/config/skills.json` rendered during `make test` (`tests/run_test.sh`), containing `{"entries": [{"path": "~/.agents/skills"}]}`.

- [ ] **Step 1: Write the failing test in `tests/suite_common.sh`**

Add assertions to `tests/suite_common.sh` checking that `.gemini/config/skills.json` is rendered and mounts `~/.agents/skills`, and that `.codegraph` is not copied to `$TMP_HOME`:

```bash
check "agy skills.json rendered" "[[ -f \$TMP_HOME/.gemini/config/skills.json ]]"
check "agy skills.json mounts ~/.agents/skills" "grep -q '~/.agents/skills' \$TMP_HOME/.gemini/config/skills.json"
check ".codegraph directory is ignored by chezmoi" "[[ ! -d \$TMP_HOME/.codegraph ]]"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `make test`
Expected: FAIL on `agy skills.json rendered` (`$TMP_HOME/.gemini/config/skills.json` does not exist yet).

- [ ] **Step 3: Update `.gitignore`, `.chezmoiignore`, and create `dot_gemini/config/skills.json`**

Update `.gitignore`:
```gitignore
tmuxinator/*
offline-packages/*

dist/
*.tar.gz

.env
.codegraph/
```

Update `.chezmoiignore`:
```gitignore
.chezmoidata.yaml
README.md
README-Template.md
Makefile
docs/
dist/
docker/
completions/
scripts/
offline-packages/
tests/
.gitignore
.env
.env.example
.codegraph/
```

Create `dot_gemini/config/skills.json`:
```json
{
  "entries": [
    { "path": "~/.agents/skills" }
  ]
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `make test`
Expected: PASS on both Linux and macOS simulation suites.

- [ ] **Step 5: Commit**

```bash
git add .gitignore .chezmoiignore dot_gemini/config/skills.json tests/suite_common.sh
git commit -m "feat: manage ~/.gemini/config/skills.json and ignore .codegraph"
```

---

### Task 2: Declarative `npx_skills` Sync and Plugin Separation

**Files:**
- Modify: `.chezmoidata.yaml:11-23`
- Modify: `run_onchange_before_07_install_ai_tools.sh.tmpl:1-43`
- Modify: `tests/suite_common.sh:7-22`

**Interfaces:**
- Consumes: `.antigravity.plugins` and `.ai_tools.npx_skills` (`repo` string, `skills` string slice) from `.chezmoidata.yaml`.
- Produces: Rendered `$TMP_HOME/06_install_antigravity.sh` and `$TMP_HOME/07_install_ai_tools.sh`.

- [ ] **Step 1: Write the failing tests in `tests/suite_common.sh`**

Replace lines 8-19 of `tests/suite_common.sh` with the updated assertions for `06_install_antigravity.sh` and `07_install_ai_tools.sh`:

```bash
check "antigravity installation script rendered" "[[ -f \$TMP_HOME/06_install_antigravity.sh ]]"
check "antigravity installation script installs superpowers" "grep -q 'obra/superpowers' \$TMP_HOME/06_install_antigravity.sh"
check "antigravity installation script installs ponytail" "grep -q 'DietrichGebert/ponytail' \$TMP_HOME/06_install_antigravity.sh"
check "antigravity installation script does not install mattpocock/skills as plugin" "! grep -q 'mattpocock/skills' \$TMP_HOME/06_install_antigravity.sh"
check "ai_tools installation script rendered" "[[ -f \$TMP_HOME/07_install_ai_tools.sh ]]"
if [[ "$OS_TYPE" == "darwin" ]]; then
  check "ai_tools script installs codegraph" "grep -q '@colbymchenry/codegraph' \$TMP_HOME/07_install_ai_tools.sh"
  check "ai_tools script installs neovim npm" "grep -q 'neovim' \$TMP_HOME/07_install_ai_tools.sh"
  check "ai_tools script syncs mattpocock/skills via npx skills" "grep -q 'npx -y skills add \"mattpocock/skills\" -g -a antigravity-cli -s' \$TMP_HOME/07_install_ai_tools.sh"
  check "ai_tools script syncs vercel-labs/skills via npx skills" "grep -q 'npx -y skills add \"vercel-labs/skills\" -g -a antigravity-cli -s' \$TMP_HOME/07_install_ai_tools.sh"
  check "ai_tools script prunes unlisted skills" "grep -q 'npx -y skills remove -g -s' \$TMP_HOME/07_install_ai_tools.sh"
else
  check "ai_tools script renders Linux placeholder" "grep -q 'Linux support not yet implemented' \$TMP_HOME/07_install_ai_tools.sh"
fi
```

- [ ] **Step 2: Run test to verify it fails**

Run: `make test`
Expected: FAIL on `antigravity installation script does not install mattpocock/skills as plugin` and `ai_tools script syncs mattpocock/skills via npx skills`.

- [ ] **Step 3: Update `.chezmoidata.yaml` and `run_onchange_before_07_install_ai_tools.sh.tmpl`**

Update `.chezmoidata.yaml`:
```yaml
is_offline: false
fonts:
  version: "v3.2.1"
  selected:
    - JetBrainsMono
user:
  name: "張旭"
  email: "zx1986@gmail.com"
  username: "zx1986"

antigravity:
  plugins:
    - https://github.com/obra/superpowers
    - https://github.com/DietrichGebert/ponytail

ai_tools:
  npm_globals:
    - "@colbymchenry/codegraph"
    - neovim
  npx_skills:
    - repo: "mattpocock/skills"
      skills:
        - ask-matt
        - code-review
        - codebase-design
        - diagnosing-bugs
        - domain-modeling
        - git-guardrails-claude-code
        - grill-me
        - grill-with-docs
        - grilling
        - handoff
        - implement
        - improve-codebase-architecture
        - migrate-to-shoehorn
        - prototype
        - research
        - resolving-merge-conflicts
        - scaffold-exercises
        - setup-matt-pocock-skills
        - setup-pre-commit
        - tdd
        - teach
        - to-spec
        - to-tickets
        - triage
        - wayfinder
        - writing-great-skills
    - repo: "vercel-labs/skills"
      skills:
        - find-skills
```

Update `run_onchange_before_07_install_ai_tools.sh.tmpl`:
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
  if ! npm list -g --depth=0 "{{ . }}" >/dev/null 2>&1; then
    echo "  Installing {{ . }}..."
    npm install -g "{{ . }}"
  else
    echo "  {{ . }} already installed."
  fi
  {{- end }}
else
  echo "Warning: npm not found, skipping npm global packages."
fi

# --- npx skills (declarative sync) ---
if command -v npx >/dev/null 2>&1; then
  echo "Syncing npx skills..."
  SKILLS_DIR="$HOME/.agents/skills"
  mkdir -p "$SKILLS_DIR"

  {{- range .ai_tools.npx_skills }}
  missing_skills=()
  {{- range .skills }}
  if [ ! -d "$SKILLS_DIR/{{ . }}" ]; then
    missing_skills+=("{{ . }}")
  fi
  {{- end }}
  if [ ${#missing_skills[@]} -gt 0 ]; then
    echo "  Installing missing skills from {{ .repo }}: ${missing_skills[*]}..."
    npx -y skills add "{{ .repo }}" -g -a antigravity-cli -s "${missing_skills[@]}" -y || echo "Warning: Failed to install skills from {{ .repo }}"
  else
    echo "  All skills from {{ .repo }} already installed."
  fi
  {{- end }}

  # Prune skills not declared in .chezmoidata.yaml
  declared_skills=" {{- range .ai_tools.npx_skills }}{{- range .skills }}{{ . }} {{ end }}{{- end }}"
  extra_skills=()
  for dir in "$SKILLS_DIR"/*; do
    [ -d "$dir" ] || continue
    skill_name=$(basename "$dir")
    case "$declared_skills" in
      *" $skill_name "*) ;;
      *) extra_skills+=("$skill_name") ;;
    esac
  done
  if [ ${#extra_skills[@]} -gt 0 ]; then
    echo "  Removing unlisted skills: ${extra_skills[*]}..."
    npx -y skills remove -g -s "${extra_skills[@]}" -y || echo "Warning: Failed to remove unlisted skills"
  fi
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

- [ ] **Step 4: Run test to verify it passes**

Run: `make test`
Expected: PASS on both Linux and macOS simulation suites, with valid syntax on generated `07_install_ai_tools.sh` (`bash -n`).

- [ ] **Step 5: Commit**

```bash
git add .chezmoidata.yaml run_onchange_before_07_install_ai_tools.sh.tmpl tests/suite_common.sh
git commit -m "feat: declaratively sync npx skills and remove mattpocock plugin"
```

---

### Task 3: Add Bats Health Checks for `skills.json` and `~/.agents/skills`

**Files:**
- Modify: `tests/health_check.bats:99-103`

**Interfaces:**
- Consumes: `$HOME/.gemini/config/skills.json` and `$HOME/.agents/skills/` on the live system.

- [ ] **Step 1: Add health check assertions to `tests/health_check.bats`**

Append two tests to `tests/health_check.bats`:

```bash
@test "antigravity skills.json mounts ~/.agents/skills" {
  [ -f "$HOME/.gemini/config/skills.json" ]
  run grep -q "~/.agents/skills" "$HOME/.gemini/config/skills.json"
  [ "$status" -eq 0 ]
}

@test "curated agent skills are installed in ~/.agents/skills" {
  [ -d "$HOME/.agents/skills/tdd" ]
  [ -d "$HOME/.agents/skills/find-skills" ]
}
```

- [ ] **Step 2: Run Bats health checks and simulation tests**

Run: `bats tests/health_check.bats && make test`
Expected: All Bats tests pass (`18/18` passing) and `make test` passes (`0 failed`).

- [ ] **Step 3: Commit**

```bash
git add tests/health_check.bats
git commit -m "test: add health checks for agy skills.json and ~/.agents/skills"
```
