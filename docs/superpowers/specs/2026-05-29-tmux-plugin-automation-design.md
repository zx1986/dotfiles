# Tmux Plugin Automation Design

This document outlines the design for automating the installation of tmux plugins via TPM (Tmux Plugin Manager) during the `xProfile` initialization process.

## 1. Problem Statement
Currently, `Oh My Tmux` and `TPM` are installed during the `run_once_before` phase, but the actual plugins (defined in `.tmux.conf.local`) are not installed until the user manually triggers the installation within a tmux session. This creates a manual step and a "broken" experience during the first tmux launch.

## 2. Proposed Changes

### 2.1 Automated Plugin Installation
Create a new `run_once_after` script that executes the TPM installation binary. This script must run *after* the dotfiles have been applied to ensure the plugin list is available in the target configuration files.

**New File:**
- `run_once_after_30_install_tmux_plugins.sh`

**Logic:**
1. Check if the TPM installation script exists at `~/.tmux/plugins/tpm/bin/install_plugins`.
2. If it exists, execute it.
3. This will download and install all plugins defined in `~/.tmux.conf.local` headlessly.

## 3. Implementation Plan

### Step 1: Create Setup Script
Create `run_once_after_30_install_tmux_plugins.sh`:
```bash
#!/bin/sh

# Automated TPM plugin installation
# This script runs after dotfiles are applied to ensure ~/.tmux.conf.local is present.

if [ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
  echo "Installing Tmux plugins via TPM..."
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
  echo "Tmux plugins installed successfully."
else
  echo "WARN: TPM installer not found at ~/.tmux/plugins/tpm/bin/install_plugins"
fi
```

## 4. Verification Strategy

### 4.1 Manual Verification
1. Run `make update` (or `chezmoi apply`).
2. Verify that the output shows "Installing Tmux plugins via TPM...".
3. Check the `~/.tmux/plugins/` directory to ensure plugins like `nord-tmux` or `tmux-sensible` are present.
4. Launch `tmux` and verify that plugins (e.g., themes) are active.

### 4.2 Automated Testing
1. Add a test case to `tests/health_check.bats` to verify that at least one expected plugin directory exists (e.g., `~/.tmux/plugins/tmux-sensible`).
