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
