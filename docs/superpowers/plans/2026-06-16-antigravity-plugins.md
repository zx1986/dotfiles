# Migrate Gemini CLI to Antigravity CLI and Plugins Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate dotfiles configuration and scripts from Gemini CLI/extensions to Antigravity CLI/plugins.

**Architecture:** Update chezmoi variables in `.chezmoidata.yaml`, delete the global Gemini install template script, update the Antigravity install script to dynamically install plugins listed in configuration, and update BATS tests to remove Gemini checks.

**Tech Stack:** Chezmoi, Bash, Bats testing framework.

---

### Task 1: Configuration Update

**Files:**
- Modify: `.chezmoidata.yaml`

- [ ] **Step 1: Update .chezmoidata.yaml configuration**

Replace the `gemini` config block with `antigravity` configuration.

Target Content (around line 12):
```yaml
gemini:
  extensions:
    - https://github.com/obra/superpowers
```

Replacement Content:
```yaml
antigravity:
  plugins:
    - https://github.com/obra/superpowers
```

- [ ] **Step 2: Commit the configuration change**

Run:
```bash
git add .chezmoidata.yaml
git commit -m "config: migrate gemini extensions config to antigravity plugins"
```

---

### Task 2: Delete Gemini Installation Script

**Files:**
- Delete: `run_once_before_05_install_gemini.sh.tmpl`

- [ ] **Step 1: Remove the Gemini installation script file**

Run:
```bash
git rm run_once_before_05_install_gemini.sh.tmpl
```

- [ ] **Step 2: Commit the deletion**

Run:
```bash
git commit -m "chore: remove gemini installation script"
```

---

### Task 3: Update Antigravity Installation Script

**Files:**
- Modify: `run_once_before_06_install_antigravity.sh.tmpl`

- [ ] **Step 1: Add plugin installation logic to the script**

Append the plugin installation loop to the end of `run_once_before_06_install_antigravity.sh.tmpl`.

Target Content:
```bash
# Final verification
if [ -f "$HOME/.local/bin/agy" ]; then
    echo "Verification successful: agy found in ~/.local/bin"
else
    echo "Error: agy installation failed."
    exit 1
fi
```

Replacement Content:
```bash
# Final verification
if [ -f "$HOME/.local/bin/agy" ]; then
    echo "Verification successful: agy found in ~/.local/bin"
else
    echo "Error: agy installation failed."
    exit 1
fi

# --- Install Antigravity Plugins ---
{{- range .antigravity.plugins }}
echo "Installing antigravity plugin: {{ . }}..."
"$HOME/.local/bin/agy" plugin install "{{ . }}" || true
{{- end }}
```

- [ ] **Step 2: Run rendering/simulation tests**

Run:
```bash
make test
```
Expected: The tests compile and render templates successfully without chezmoi syntax errors.

- [ ] **Step 3: Commit the installation script change**

Run:
```bash
git add run_once_before_06_install_antigravity.sh.tmpl
git commit -m "feat: add plugin installation to antigravity script"
```

---

### Task 4: Update Health Check Tests

**Files:**
- Modify: `tests/health_check.bats`

- [ ] **Step 1: Remove the gemini-cli health check case**

Delete lines 50-53 from `tests/health_check.bats`.

Target Content:
```bash
@test "gemini-cli is available" {
  run command -v gemini
  [ "$status" -eq 0 ]
}
```

Replacement Content:
*(empty - remove these lines completely)*

- [ ] **Step 2: Run health checks**

Run:
```bash
make health
```
Expected: Health checks run and pass (or fail only on unrelated uninstalled tools, but specifically no failures/errors regarding `gemini`).

- [ ] **Step 3: Commit test update**

Run:
```bash
git add tests/health_check.bats
git commit -m "test: remove gemini-cli health check"
```
