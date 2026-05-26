# Design Spec: Zsh Startup Fix and eza Removal

The user reports "very many error messages" during Zsh startup on Ubuntu 22.04. This is caused by an over-sensitive debug check, missing dependencies, and missing internal functions in bundled Oh My Zsh plugins. Additionally, the user has requested the complete removal of `eza` from the configuration.

## Goals
- Stop verbose xtrace output during Zsh startup.
- Remove all references and configurations for `eza`.
- Fix broken dependencies for `fd` and `bat` on Ubuntu.
- Prevent "command not found" errors for missing async handlers in `omz-git.zsh`.

## Proposed Changes

### 1. Remove `eza` Configuration
- **File:** `dot_aliases`
    - Remove `alias ls='eza'`.
    - Ensure standard `ls` is used.
- **File:** `run_once_before_20_install_prezto.sh`
    - Remove the logic that copies `completions/zsh/_eza` to the Prezto completions directory.
- **File Deletion:** `completions/zsh/_eza`
    - Delete this file as it is no longer needed.

### 2. Fix Ubuntu Tool Names
- **File:** `dot_aliases`
    - Add logic to alias `fdfind` to `fd` if `fd` is missing but `fdfind` exists.
    - Add logic to alias `batcat` to `bat` if `bat` is missing but `batcat` exists.

### 3. Zsh Plugin Robustness
- **File:** `dot_config/zsh/parts/omz-kube-ps1.plugin.zsh`
    - Update the debug check from `[[ -n $DEBUG ]] && set -x` to `[[ "$DEBUG" == "true" ]] && set -x`.
- **File:** `dot_config/zsh/parts/omz-git.zsh`
    - Add a defensive stub at the top:
      ```zsh
      if ! (( $+functions[_omz_register_handler] )); then
        _omz_register_handler() { : }
      fi
      ```

## Verification Plan

### Automated Tests
- Run `make test-linux` to ensure templates still render correctly.
- Add a temporary test case in `tests/run_test.sh` (or a separate script) that simulates the Ubuntu environment and checks if `fd` and `bat` aliases are correctly set.

### Manual Verification
- **Xtrace:** Set `DEBUG=false` and source `omz-kube-ps1.plugin.zsh`. Confirm no xtrace output is produced.
- **eza:** Confirm `ls` is the standard `ls` and no `eza` alias exists.
- **Git Handler:** Source `omz-git.zsh` and confirm no "command not found" error for `_omz_register_handler`.
- **Ubuntu Aliases:** Simulate Ubuntu by ensuring `fdfind` is in path and `fd` is not, then check if `fd` works as an alias.
