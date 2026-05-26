# Design Spec: Data-Driven Nerd Fonts Integration for Ubuntu

## 1. Overview
This design integrates Nerd Fonts installation into the Ubuntu setup using a data-driven approach managed by `chezmoi`. It replaces the standalone `fonts.sh` script with a template-based `run_once` script that draws its configuration from `chezmoidata.yaml`.

## 2. Goals
- Automated installation of Nerd Fonts on Ubuntu/Linux.
- Centralized configuration of font selection and version.
- Support for offline mode (skip installation if `is_offline` is true).
- Upgrade to the latest Nerd Fonts version (v3.2.1).

## 3. Architecture

### 3.1 Data Model (`chezmoidata.yaml`)
A new `fonts` object will be added to the data file:

```yaml
fonts:
  version: "v3.2.1"
  selected:
    - JetBrainsMono
    - Meslo
    - Noto
    - SourceCodePro
```

### 3.2 Installation Script (`run_once_after_install_fonts.sh.tmpl`)
This script will be executed by `chezmoi` during the apply phase.

- **Trigger**: Runs whenever the script content or the font list in `chezmoidata.yaml` changes.
- **Constraints**:
    - OS check: `{{ if eq .chezmoi.os "linux" }}`
    - Offline check: `{{ if not (index . "is_offline") }}`
- **Operations**:
    1. Define `fonts_dir` as `${HOME}/.local/share/fonts`.
    2. Create directory if missing.
    3. Loop through `{{ .fonts.selected }}`.
    4. Download `.zip` from GitHub releases using the configured version.
    5. Unzip to `fonts_dir`.
    6. Cleanup temporary files.
    7. Refresh font cache with `fc-cache -fv`.

## 4. Implementation Details

### 4.1 Compatibility Notes
- Nerd Fonts v3.x uses different zip names compared to v2.x (e.g., `JetBrainsMono.zip` vs older naming). We will use the v3 naming convention.
- The script will assume `wget`, `unzip`, and `fontconfig` are available (installed via `run_once_before_00_install_packages.sh.tmpl`).

### 4.2 File Removals
- Once integrated, the legacy `fonts.sh` script will be removed to avoid duplication.

## 5. Testing & Validation
- **Template Rendering**: Verify that `chezmoi execute-template run_once_after_install_fonts.sh.tmpl` produces valid shell code with the expected font URLs.
- **OS Simulation**: Use the project's testing framework to ensure the script is only rendered for Linux.
- **Dry Run**: Run `chezmoi apply -n` to verify the script would be executed.

## 6. Success Criteria
- Fonts are successfully installed to `~/.local/share/fonts` on an Ubuntu system.
- `fc-list` shows the newly installed Nerd Fonts.
- The installation is skipped when `is_offline: true` is set in the environment.
