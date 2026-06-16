# Design Spec: Migrate Gemini CLI to Antigravity CLI and Plugins Configuration

## 1. Background & Objectives
We are migrating our dotfiles environment from using `gemini-cli` to `antigravity-cli` (`agy`). As part of this transition:
- We will completely remove the installation of `gemini-cli` and its extensions.
- We will retain the installation of `antigravity-cli`.
- We will add support for installing `agy` plugins through Chezmoi templates, driven by a plugins list in `.chezmoidata.yaml`.
- The first required plugin to be installed is `https://github.com/obra/superpowers`.

---

## 2. Proposed Changes

### A. Configuration Updates
Modify `.chezmoidata.yaml` to remove `gemini` configuration and add `antigravity` configuration.

**Before:**
```yaml
gemini:
  extensions:
    - https://github.com/obra/superpowers
```

**After:**
```yaml
antigravity:
  plugins:
    - https://github.com/obra/superpowers
```

### B. Script Deletions
Remove `run_once_before_05_install_gemini.sh.tmpl` completely from the repository to prevent Gemini installation.

### C. Script Updates
Update `run_once_before_06_install_antigravity.sh.tmpl` to handle the plugin installation after `agy` is successfully installed and verified.

**New Logic to Add:**
```bash
# --- Install Antigravity Plugins ---
{{- range .antigravity.plugins }}
echo "Installing antigravity plugin: {{ . }}..."
"$HOME/.local/bin/agy" plugin install "{{ . }}" || true
{{- end }}
```

### D. Testing Updates
Remove the `gemini-cli is available` test case from `tests/health_check.bats` to ensure the health check suite passes without `gemini` present.

---

## 3. Test Plan
- Run `make test` to ensure template rendering tests compile and verify health tests.
- Manually run the modified `run_once_before_06_install_antigravity.sh.tmpl` script to verify that `agy` is installed and the `superpowers` plugin is successfully installed.
- Verify `agy` commands and its plugins list.

---

## 4. Self-Review
1. **Placeholder Scan**: No placeholders (TBD, TODO) are present.
2. **Consistency Check**: All files updated align with removing Gemini and moving configuration keys to `antigravity.plugins`.
3. **Decomposition Check**: The scope is small and focused; a single implementation phase is sufficient.
4. **Ambiguity Check**: The plugin install path is set explicitly to `"$HOME/.local/bin/agy"` to avoid any path resolution issues during chezmoi initialization.
