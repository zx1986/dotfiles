# Design Spec: Flexible & Lightweight Modular Testing Framework

This document outlines the design for a new testing mechanism for `xProfile`. It replaces the heavy, Docker-bound verification with a local-first, multi-OS simulation approach.

## 1. Goals
- **Multi-OS Support**: Verify configuration rendering for macOS and Linux without requiring multiple virtual environments.
- **Lightweight**: Use `chezmoi` template rendering instead of full OS virtualization.
- **Modular**: Separate common assertions from OS-specific logic.
- **Fast**: Execution should be near-instant (sub-second).

## 2. Architecture

### 2.1 The "Simulator" Concept
The framework uses `chezmoi`'s ability to render templates into a custom destination directory. By mocking the `os` variable in a temporary configuration file, we can trick `chezmoi` into rendering files as if it were running on a different operating system.

### 2.2 Directory Structure
```text
tests/
├── run_test.sh          # The core test runner/orchestrator
├── lib_assert.sh        # Shared assertion helper functions
├── suite_common.sh      # Assertions applicable to all OSes
├── suite_linux.sh       # Linux-specific assertions
└── suite_macos.sh       # macOS-specific assertions
```

## 3. Implementation Details

### 3.1 Test Runner (`run_test.sh`)
The runner will:
1. Accept an OS identifier as an argument (e.g., `linux`, `darwin`).
2. Create a temporary directory `TMP_HOME`.
3. Iterate through all files in the source directory:
   - For `.tmpl` files: Use `chezmoi execute-template --os="<OS_ID>" --init --source=. < file.tmpl > TMP_HOME/file`.
   - For regular files: Copy them to `TMP_HOME`.
4. Run the assertion suites against the contents of `TMP_HOME`.

### 3.2 Assertion Suites
Assertions will focus on file existence and file content.
- **Common**: Verify `nvim`, `zprezto`, and `tmux` files exist.
- **Linux**: Verify `.gitconfig` lacks macOS-specific helpers; verify `apt` install commands are present in scripts.
- **macOS**: Verify `.gitconfig` has `osxkeychain`; verify `brew` commands are present in scripts.

### 3.3 Makefile Integration
New targets will be added to the root `Makefile`:
- `make test`: Runs the full suite (linux + darwin).
- `make test-linux`: Runs the linux simulation.
- `make test-macos`: Runs the darwin simulation.

## 4. Documentation Updates
- **README.md**: Update the "Docker Verification" section to "Testing" (or similar), introducing the new `make test` workflow and explaining how to run OS-specific simulations.
- **Internal Docs**: Ensure any references to the old `verify.sh` or Docker-only testing are updated or deprecated.

## 5. Verification Plan
1. **Initial Run**: Execute `make test-macos` on the local Mac and verify it passes.
2. **Linux Run**: Execute `make test-linux` on the local Mac and verify it catches the expected Linux-specific file patterns.
3. **Regression**: Intentionally break a template (e.g., remove an `if` block) and ensure the simulator catches it.
