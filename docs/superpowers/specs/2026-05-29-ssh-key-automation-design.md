# SSH Key Automation Design

This document outlines the design for automating SSH key generation and centralized user configuration in the `xProfile` dotfiles project, specifically for Ubuntu.

## 1. Problem Statement
Currently, the user's email is hardcoded in `dot_gitconfig.tmpl`. When initializing a new Ubuntu environment, the user has to manually generate SSH keys and add them to the SSH agent to connect to GitHub.

## 2. Proposed Changes

### 2.1 Centralized User Identity
Move hardcoded user information from `dot_gitconfig.tmpl` to `.chezmoidata.yaml`. This allows other scripts (like the SSH setup script) to access these variables.

**Files to Modify:**
- `.chezmoidata.yaml`: Add `user` section.
- `dot_gitconfig.tmpl`: Use template variables.

### 2.2 Automated SSH Key Generation
Create a new initialization script that generates an Ed25519 SSH key if one does not already exist.

**New File:**
- `run_once_before_15_setup_ssh.sh.tmpl`

**Logic:**
1. Check if the operating system is Linux.
2. Check if `~/.ssh/id_ed25519` already exists.
3. If it doesn't exist:
    - Create `~/.ssh` directory with `700` permissions.
    - Run `ssh-keygen -t ed25519 -C "{{ .user.email }}" -N "" -f ~/.ssh/id_ed25519`.
    - Ensure the private key has `600` permissions.

### 2.3 SSH Agent Integration
Leverage the existing Prezto `ssh` module configuration in `dot_zpreztorc`.

**Current Configuration (No changes needed):**
```zsh
zstyle ':prezto:load' pmodule \
  ...
  'ssh' \
  ...
```
The Prezto `ssh` module will automatically:
- Start `ssh-agent`.
- Add the default keys (including `id_ed25519`) to the agent.

## 3. Implementation Plan

### Step 1: Configuration Update
1. Update `.chezmoidata.yaml`:
   ```yaml
   user:
     name: "張旭"
     email: "zx1986@gmail.com"
     username: "zx1986"
   ```
2. Update `dot_gitconfig.tmpl`:
   ```tmpl
   [user]
     name = {{ .user.name }}
     email = {{ .user.email }}
     username = {{ .user.username }}
   ```

### Step 2: Setup Script Creation
1. Create `run_once_before_15_setup_ssh.sh.tmpl`:
   ```bash
   #!/bin/bash
   {{ if eq .chezmoi.os "linux" -}}
   if [ ! -f ~/.ssh/id_ed25519 ]; then
     echo "Generating new SSH key for {{ .user.email }}..."
     mkdir -p ~/.ssh
     chmod 700 ~/.ssh
     ssh-keygen -t ed25519 -C "{{ .user.email }}" -N "" -f ~/.ssh/id_ed25519
     chmod 600 ~/.ssh/id_ed25519
   else
     echo "SSH key already exists."
   fi
   {{ end -}}
   ```

## 4. Verification Strategy

### 4.1 Manual Verification
1. Run `make update` (or `chezmoi apply`).
2. Verify that `.gitconfig` has the correct email.
3. Verify that `~/.ssh/id_ed25519` and `~/.ssh/id_ed25519.pub` exist.
4. Start a new Zsh session and run `ssh-add -l` to ensure the key is loaded.

### 4.2 Automated Testing
1. Add a test case to `tests/health_check.bats` (if applicable) to check for the existence of the SSH key and correct Git configuration.
