# Data-Driven Nerd Fonts Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate Nerd Fonts installation into the Ubuntu setup using a data-driven Chezmoi script, replacing the legacy `fonts.sh`.

**Architecture:** Use `chezmoidata.yaml` to configure font selection and version, and a `run_once_after_install_fonts.sh.tmpl` script to handle the download and installation logic for Ubuntu/Linux.

**Tech Stack:** Chezmoi templates, Bash, Nerd Fonts (v3.2.1), wget, unzip.

---

### Task 1: Update `chezmoidata.yaml`

**Files:**
- Modify: `chezmoidata.yaml`

- [ ] **Step 1: Add font configuration to `chezmoidata.yaml`**

```yaml
fonts:
  version: "v3.2.1"
  selected:
    - JetBrainsMono
    - Meslo
    - Noto
    - SourceCodePro
```

- [ ] **Step 2: Verify YAML syntax**

Run: `python3 -c 'import yaml, sys; yaml.safe_load(sys.stdin)' < chezmoidata.yaml`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add chezmoidata.yaml
git commit -m "feat: add font configuration to chezmoidata.yaml"
```

---

### Task 2: Create `run_once_after_install_fonts.sh.tmpl`

**Files:**
- Create: `run_once_after_install_fonts.sh.tmpl`

- [ ] **Step 1: Write the font installation template**

```bash
#!/bin/bash
# Description: Install Nerd Fonts for Linux (Ubuntu)
# Managed by Chezmoi

{{- if and (eq .chezmoi.os "linux") (not (index . "is_offline")) }}
set -e

fonts_dir="${HOME}/.local/share/fonts"
if [[ ! -d "$fonts_dir" ]]; then
    mkdir -p "$fonts_dir"
fi

version="{{ .fonts.version }}"
declare -a fonts=(
{{- range .fonts.selected }}
    "{{ . }}"
{{- end }}
)

for font in "${fonts[@]}"; do
    zip_file="${font}.zip"
    download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${zip_file}"
    
    # Skip if font directory already exists (basic idempotency)
    if [[ -d "${fonts_dir}/${font}" ]]; then
        echo "Font ${font} already exists in ${fonts_dir}, skipping download."
        continue
    fi

    echo "Downloading ${font} from ${download_url}..."
    if wget -q "$download_url"; then
        unzip -o "$zip_file" -d "$fonts_dir"
        rm "$zip_file"
    else
        echo "Failed to download ${font}"
    fi
done

# Cleanup Windows Compatible files as in original script
find "$fonts_dir" -name '*Windows Compatible*' -delete

# Refresh font cache
if command -v fc-cache >/dev/null; then
    echo "Updating font cache..."
    fc-cache -fv
fi

{{- else }}
# Skipping font installation (OS is not Linux or offline mode is active)
{{- end }}
```

- [ ] **Step 2: Test template rendering for Linux**

Run: `chezmoi execute-template --init --override-data '{"chezmoi": {"os": "linux"}, "is_offline": false}' run_once_after_install_fonts.sh.tmpl`
Expected: Shell script with JetBrainsMono, Meslo, etc. in the list.

- [ ] **Step 3: Test template rendering for macOS (should be empty/skipped)**

Run: `chezmoi execute-template --init --override-data '{"chezmoi": {"os": "darwin"}, "is_offline": false}' run_once_after_install_fonts.sh.tmpl`
Expected: Output showing the "Skipping" comment.

- [ ] **Step 4: Commit**

```bash
git add run_once_after_install_fonts.sh.tmpl
git commit -m "feat: add run_once script for font installation"
```

---

### Task 3: Add Verification Tests

**Files:**
- Modify: `tests/suite_linux.sh`

- [ ] **Step 1: Add font script verification to `tests/suite_linux.sh`**

```bash
echo ">>> Running Linux Suite..."
check "No osxkeychain in .gitconfig" "! grep -q 'osxkeychain' \$TMP_HOME/.gitconfig"
check "APT commands in install script" "grep -q 'apt-get install' \$TMP_HOME/00_install_packages.sh"
# Add this line:
check "Font installation script rendered" "grep -q 'JetBrainsMono' \$TMP_HOME/after_install_fonts.sh"
```

- [ ] **Step 2: Run tests**

Run: `make test-linux`
Expected: All tests PASS, including the new font script check.

- [ ] **Step 3: Commit**

```bash
git add tests/suite_linux.sh
git commit -m "test: add verification for font installation script"
```

---

### Task 4: Cleanup Legacy Script

**Files:**
- Delete: `fonts.sh`

- [ ] **Step 1: Remove `fonts.sh`**

Run: `rm fonts.sh`

- [ ] **Step 2: Commit**

```bash
git add fonts.sh
git commit -m "chore: remove legacy fonts.sh script"
```

---

### Task 5: Final Validation

- [ ] **Step 1: Run all tests**

Run: `make test`
Expected: PASS
