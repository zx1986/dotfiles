# Robust fzf Shell Integration Design

This document outlines the design for making `fzf` shell integration (keybindings and completion) robust across all environments, specifically addressing systems where package managers do not provide or have removed the integration scripts.

## 1. Problem Statement
The `fzf` package on Ubuntu and other Linux distributions often places shell integration scripts in "documentation" or "example" directories (e.g., `/usr/share/doc/fzf/examples/`). On minimal system installations, these directories are frequently purged to save space, causing `Ctrl+R` and `Ctrl+T` to fail even though `fzf` is installed.

## 2. Proposed Changes

### 2.1 Dynamic Detection with Self-Healing
Update the Zsh configuration to search for integration files in common system paths. If not found, the configuration will automatically download the necessary files from the official `junegunn/fzf` repository.

**Files to Modify:**
- `.chezmoitemplates/zsh_post_setup`

**Logic:**
1. Check if the `fzf` command exists in the path.
2. Search for `key-bindings.zsh` in:
    - macOS Homebrew (Silicon & Intel)
    - Linux Apt examples
    - Local cache path: `~/.config/fzf/`
3. If found, source both `completion.zsh` and `key-bindings.zsh`.
4. If **not found**:
    - Create `~/.config/fzf/` directory.
    - Download `completion.zsh` and `key-bindings.zsh` from GitHub via `curl`.
    - Source the downloaded files.

### 2.2 Fallback Removal
Remove the existing fallback check for `~/.fzf.zsh` as the new self-healing logic provides a more reliable and managed local path (`~/.config/fzf/`).

## 3. Implementation Plan

### Step 1: Update Zsh Post-Setup Template
Replace the current `fzf` block in `.chezmoitemplates/zsh_post_setup` with the new detection and download logic.

```zsh
# fzf
if command -v fzf >/dev/null; then
  # Dynamic detection for brew/apt installs
  () {
    local fzf_shell_paths=(
      "/opt/homebrew/opt/fzf/shell"      # Homebrew (Apple Silicon)
      "/usr/local/opt/fzf/shell"         # Homebrew (Intel)
      "/usr/share/doc/fzf/examples"      # Ubuntu/Debian
      "$HOME/.config/fzf"                # Local cache
    )

    local found=false
    for base in $fzf_shell_paths; do
      if [ -f "$base/key-bindings.zsh" ]; then
        [ -f "$base/completion.zsh" ] && source "$base/completion.zsh"
        source "$base/key-bindings.zsh"
        found=true; break
      fi
    done

    # Self-heal: Download if missing
    if [ "$found" = false ]; then
      local local_path="$HOME/.config/fzf"
      mkdir -p "$local_path"
      # Only download if internet is available (handled by curl failure or explicit check)
      {{- if not (index . "is_offline") }}
      echo "fzf integration files missing. Downloading to $local_path..."
      curl -sSL -o "$local_path/completion.zsh" https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh
      curl -sSL -o "$local_path/key-bindings.zsh" https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh
      [ -f "$local_path/completion.zsh" ] && source "$local_path/completion.zsh"
      [ -f "$local_path/key-bindings.zsh" ] && source "$local_path/key-bindings.zsh"
      {{- end }}
    fi
  }
fi
```

## 4. Verification Strategy

### 4.1 Manual Verification
1. Run `make update`.
2. Start a new Zsh session.
3. Verify `~/.config/fzf/` contains the downloaded files.
4. Press `Ctrl+R` and verify history search appears.

### 4.2 Automated Testing
1. Add a test case to `tests/health_check.bats` to verify that `key-bindings.zsh` has been sourced (e.g., by checking if the `fzf-history-widget` function is defined).
