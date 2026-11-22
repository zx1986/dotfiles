# Add Black Code Formatter — Design Spec

**Date**: 2026-11-22
**Scope**: macOS + Ubuntu (online install only)
**Goal**: Make the `black` Python formatter available as a CLI command on both platforms, at the latest upstream version on each.

---

## Context

- No Python tooling is currently managed by xProfile (no Python in `.tool-versions`, no pipx/uv).
- Packages are installed by `run_once_before_00_install_packages.sh.tmpl` (brew on macOS, apt on Ubuntu).
- Ubuntu 22.04 apt ships `black` 22.1, far behind upstream. Black's stable style changes yearly, so mismatched versions format the same code differently. Using pipx on Ubuntu keeps both platforms on the latest release.
- `~/.local/bin` (pipx's bin dir) is already on PATH via `.chezmoitemplates/zsh_pre_setup`, so `pipx ensurepath` is not needed.

## Out of Scope (YAGNI)

- Neovim / NvChad format-on-save integration
- Global black config file (`~/.config/black`)
- Version pinning
- Offline (`is_offline: true`) installation

---

## Changes

### 1. `run_once_before_00_install_packages.sh.tmpl`

**macOS**: append `black` to the existing `brew install ...` line.

**Ubuntu (online block)**:

- Append `pipx` to the existing `sudo apt-get install -y ...` line.
- Inside the `if command -v apt-get` block, after the delta installation, add:

  ```sh
  # --- Install black via pipx ---
  if ! command -v black >/dev/null && [ ! -x "$HOME/.local/bin/black" ]; then
    echo "Installing black via pipx..."
    pipx install black
  fi
  ```

  The `~/.local/bin/black` check guards against re-install errors when `~/.local/bin` is not yet on PATH during the first run.

**Offline mode**: unchanged — the Ubuntu online block is not rendered, so black is not installed.

**Error handling**: the script uses `set -e`; a failed `pipx install` aborts the chezmoi run like any other apt failure. No extra fallback.

### 2. Tests

- `tests/suite_macos.sh`:
  ```sh
  check "black in brew install list" "grep -E -q 'brew install.*\bblack\b' \$TMP_HOME/00_install_packages.sh"
  ```
- `tests/suite_linux.sh`:
  ```sh
  check "pipx in apt install list" "grep -E -q 'apt-get install.*\bpipx\b' \$TMP_HOME/00_install_packages.sh"
  check "black installed via pipx" "grep -q 'pipx install black' \$TMP_HOME/00_install_packages.sh"
  ```
- `tests/health_check.bats`:
  ```bash
  @test "black is available" {
    run zsh -i -c "command -v black"
    [ "$status" -eq 0 ]
  }
  ```
  (Uses an interactive zsh so `~/.local/bin` is on PATH on Ubuntu.)

---

## Migration Note

The install script is `run_once`, so machines that already ran it will not re-run it automatically. On existing machines, install manually (`brew install black` / `sudo apt-get install -y pipx && pipx install black`) or reset script state with `chezmoi state delete-bucket --bucket=scriptState`.
