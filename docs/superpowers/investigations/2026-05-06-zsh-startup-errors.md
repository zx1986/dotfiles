# Investigation: Zsh Startup Errors on Ubuntu 22.04

## Symptoms
User reports "very many error messages" after entering zsh following initialization.

## Root Cause Analysis
1.  **Xtrace Trigger:** The file `dot_config/zsh/parts/omz-kube-ps1.plugin.zsh` contains the line `[[ -n $DEBUG ]] && set -x`. In the current environment, `DEBUG` is set to `false`. Since `"false"` is a non-empty string, `[[ -n $DEBUG ]]` evaluates to true, triggering `set -x` (xtrace). This prints every command executed during zsh startup to stderr, which appears as "many errors" to the user.
2.  **Missing Dependencies:**
    -   `eza`: The alias `ls=eza` is set in `.aliases`, but `eza` is not installed by the current `apt-get` list in `run_once_before_00_install_packages.sh.tmpl`.
    -   `fd` vs `fdfind`: On Ubuntu, the `fd-find` package installs the binary as `fdfind`. The config expects `fd`.
    -   `bat` vs `batcat`: On Ubuntu, the `bat` package installs the binary as `batcat`. The config expects `bat`.
3.  **Missing Functions:** `omz-git.zsh` calls `_omz_register_handler`, which is not defined in the bundled files, causing actual "command not found" errors when async git prompt is enabled.

## Reproduction Steps
1.  Initialize the environment.
2.  Ensure `DEBUG` is set to any non-empty string (e.g., `export DEBUG=false`).
3.  Start `zsh`.
4.  Observe the massive amount of trace output.

## Proposed Fixes
1.  Change the debug check to `[[ "$DEBUG" == "true" ]] && set -x`.
2.  Fix Ubuntu package naming/aliasing for `fd` and `bat`.
3.  Install `eza` or fallback to `ls`.
4.  Define or stub `_omz_register_handler`.

## Resolution
The following changes were implemented to resolve the Zsh startup errors and missing dependencies:
1.  **Xtrace Fix:** Updated `dot_config/zsh/parts/omz-kube-ps1.plugin.zsh` to use `[[ "$DEBUG" == "true" ]]` for the debug check. This prevents `set -x` from triggering when `DEBUG` is set to `false`.
2.  **Eza Removal:** Replaced `eza` with standard `ls` and `dircolors` across the configuration. The `ls` alias now uses standard options, and the `zstyle` completion settings use standard `ls` colors.
3.  **Missing Dependencies:**
    -   Removed `eza` from the installation script.
    -   Added `fd-find` and `bat` to the Ubuntu package list.
    -   Added symlinks for `fd` and `bat` in `run_once_before_00_install_packages.sh.tmpl` to ensure they are available under the expected names.
4.  **Zsh Function Fix:** Stubbed `_omz_register_handler` in `dot_config/zsh/parts/omz-git.zsh` to prevent "command not found" errors.
5.  **Cleanup:** Removed dead Prezto-related code and legacy eza-specific logic from `dot_zshrc.tmpl` and other parts of the configuration to improve maintainability.

The fixes have been verified using the Linux simulation test suite (`make test-linux`).
