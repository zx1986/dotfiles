# Design Spec: Verify `make init` and Zsh Startup

**Goal:** Ensure that the `make init` process correctly provisions the Ubuntu 22.04 environment and that the resulting Zsh configuration starts cleanly without errors.

## 1. Context & Scope
The project uses `chezmoi` to manage dotfiles. `make init` automates the installation of `chezmoi`, applies the configuration, and triggers several `run_once_before_` scripts (e.g., installing packages, Prezto, and themes).

This spec covers:
- Execution of the full `make init` pipeline.
- Verification of the interactive Zsh startup sequence.
- Validation of key environment components (Prezto, Spaceship theme, custom plugins).

## 2. Approach
The verification will be performed directly on the host machine.

### Phase 1: Provisioning (`make init`)
1. Run `make init`.
2. Monitor output for any installation failures (apt, curl, chezmoi).
3. Confirm that `chezmoi` has correctly symlinked/applied files like `.zshrc`.

### Phase 2: Zsh Validation
1. **Error Detection:** Execute `zsh -i -c "exit" 2> zsh_errors.log`.
   - If `zsh_errors.log` is non-empty, the verification fails.
2. **Component Check:**
   - Verify `$ZPREZTODIR` (usually `~/.zprezto`) is populated.
   - Verify the `spaceship` prompt is configured in `.zpreztorc`.
   - Verify aliases and plugins are sourced by checking for a known alias (e.g., from `omz-git.zsh`).

## 3. Success Criteria
- `make init` exit code is `0`.
- No output to `stderr` during an interactive Zsh startup.
- Key Zsh plugins (Git, Kubectl) are loaded and their aliases are available.

## 4. Risks & Mitigations
- **Existing Config:** `chezmoi` might prompt for file conflicts. We will use `--force` or ensure a clean state where possible.
- **Network Issues:** Dependencies (Prezto, plugins) require internet access. We assume the machine has connectivity.
