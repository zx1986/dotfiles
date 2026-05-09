# Design Spec: Dynamic fzf Shell Integration

This document outlines the design for improving `fzf` integration in `xProfile`, ensuring that keybindings (Ctrl+R, Ctrl+T) and completion work automatically across macOS and Linux.

## 1. Goals
- **Automatic Detection**: Dynamically find and source `fzf` shell integration files based on the host OS and package manager.
- **Consistency**: Ensure `fzf` is installed on all supported platforms (macOS and Linux).
- **Zero Configuration**: Keybindings should work immediately after installation without manual steps like running `fzf` install scripts.

## 2. Implementation Plan

### 2.1 Package Installation
Update the macOS installation script to include `fzf` in the `brew install` list.

**File**: `run_once_before_00_install_packages.sh.tmpl`
- Add `fzf` to the `brew install` command.

### 2.2 Zsh Shell Integration
Update the Zsh post-setup template to dynamically detect and source `fzf` integration files.

**File**: `.chezmoitemplates/zsh_post_setup`
- Replace `[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh` with a detection block.
- Search paths:
    - **macOS (Silicon)**: `/opt/homebrew/opt/fzf/shell/`
    - **macOS (Intel)**: `/usr/local/opt/fzf/shell/`
    - **Linux (Ubuntu)**: `/usr/share/doc/fzf/examples/` (for key-bindings.zsh) and `/usr/share/zsh/vendor-completions/_fzf` (though apt usually handles completions via site-functions, we'll focus on key-bindings).
- Logic:
    1. Check if `fzf` command exists.
    2. Check for `completion.zsh` and `key-bindings.zsh` in the identified paths.
    3. Source them if found.
    4. Maintain `~/.fzf.zsh` as a fallback.

## 3. Verification Plan
- **macOS**: Run `make test-macos` and verify the rendered `zshrc` contains the new detection logic. Manually verify `Ctrl+R` works in a new shell.
- **Linux**: Run `make test-linux` and verify the paths are correct for Ubuntu.
- **Manual**: Verify that if `fzf` is uninstalled, the shell starts without errors.
