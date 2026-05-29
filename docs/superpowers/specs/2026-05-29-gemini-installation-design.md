# Gemini-CLI and Extensions Installation Design

This document outlines the design for automating the installation of `gemini-cli` and a configurable list of extensions on both macOS and Ubuntu.

## 1. Problem Statement
Currently, `gemini-cli` and the `superpowers` extension are only installed on macOS within a large package installation script. There is no automated setup for Gemini on Ubuntu, and adding new extensions requires modifying script logic.

## 2. Proposed Changes

### 2.1 Centralized Extension Configuration
Define the list of Gemini extensions in `.chezmoidata.yaml`. This allows for easy management and provides a single source of truth for both platforms.

**Files to Modify:**
- `.chezmoidata.yaml`: Add `gemini.extensions` list.

### 2.2 Dedicated Gemini Installation Script
Create a new initialization script that handles the end-to-end setup of Gemini, including dependencies.

**New File:**
- `run_once_before_05_install_gemini.sh.tmpl`

**Logic (Ubuntu):**
1. Check if `node` and `npm` are installed; if not, install them via `apt`.
2. Check if `gemini` is installed; if not, install `gemini-cli` globally via `npm`.
3. Iterate through the `gemini.extensions` list and install each extension.

**Logic (macOS):**
1. Ensure `gemini-cli` is installed (handled by migrating the brew install from the packages script).
2. Iterate through the `gemini.extensions` list and install each extension.

### 2.3 Cleanup of Package Script
Remove Gemini-specific logic from `run_once_before_00_install_packages.sh.tmpl` to maintain clear boundaries between system packages and tool-specific configurations.

## 3. Implementation Plan

### Step 1: Configuration Update
Add the following to `.chezmoidata.yaml`:
```yaml
gemini:
  extensions:
    - https://github.com/obra/superpowers
```

### Step 2: Create Setup Script
Create `run_once_before_05_install_gemini.sh.tmpl`:
```bash
#!/bin/bash

# --- Platform Specific Installation ---
{{ if eq .chezmoi.os "linux" -}}
# Ubuntu: Install Node, NPM, and Gemini-CLI via NPM
if ! command -v npm >/dev/null; then
  echo "Installing nodejs and npm..."
  sudo apt-get update -qq
  sudo apt-get install -y nodejs npm
fi

if ! command -v gemini >/dev/null; then
  echo "Installing gemini-cli globally..."
  sudo npm install -g @google/gemini-cli
fi
{{ end -}}

# --- Common Extension Installation ---
if command -v gemini >/dev/null; then
{{- range .gemini.extensions }}
  echo "Installing gemini extension: {{ . }}..."
  gemini extensions install {{ . }} || true
{{- end }}
fi
```

### Step 3: Cleanup existing script
1. Remove `gemini-cli` from the `brew install` list in `run_once_before_00_install_packages.sh.tmpl`.
2. Remove the manual `superpowers` extension install block from `run_once_before_00_install_packages.sh.tmpl`.

## 4. Verification Strategy

### 4.1 Manual Verification
1. Run `make update`.
2. Verify `gemini --version` returns successfully.
3. Run `gemini extensions list` (or equivalent) to verify extensions are installed.

### 4.2 Automated Testing
1. Add a test case to `tests/health_check.bats` to verify `gemini` is available in the path.
