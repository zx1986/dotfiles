# Design Spec: antigravity-cli Integration

Integrate the `antigravity-cli` (successor to Gemini CLI) into the xProfile dotfiles environment.

## Goals
- Install `antigravity-cli` autonomously during the `chezmoi apply` process.
- Ensure the `agy` binary is available in the user's `PATH`.
- Maintain the existing Gemini CLI installation (install alongside).

## Architecture

### 1. Installation Mechanism
- **File:** `run_once_before_06_install_antigravity.sh.tmpl`
- **Type:** Chezmoi "run_once" script.
- **Logic:**
  - Check if `agy` is already installed in `~/.local/bin/agy`.
  - If not, or if forced, run: `curl -fsSL https://antigravity.google/cli/install.sh | bash`.
  - Handle both macOS and Linux (the installer script is cross-platform).

### 2. Environment Configuration
- **File:** `.chezmoitemplates/zsh_pre_setup`
- **Change:** Add `$HOME/.local/bin` to the `PATH` environment variable.
- **Implementation:**
  ```bash
  PATH="$HOME/.local/bin:$PATH"
  ```
  This will be placed before the ASDF and KREW path exports to maintain a consistent priority.

## Testing & Verification

### Manual Verification
- Run `make update` (which triggers `chezmoi apply`).
- Verify the installation script runs successfully.
- Open a new terminal and run `agy --version` to confirm it's in the `PATH`.

### Automated Verification
- The installation script should exit with a non-zero code if the `curl` command fails.
- A basic check `[ -f "$HOME/.local/bin/agy" ]` will be performed at the end of the installation script.

## Alternatives Considered
- **Direct binary management via chezmoi:** Declined. The official installer handles updates and platform-specific dependencies better.
- **Replacing Gemini CLI:** Declined per user request to "install alongside".
