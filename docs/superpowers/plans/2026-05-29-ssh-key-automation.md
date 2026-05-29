# SSH Key Automation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Automate Ed25519 SSH key generation for Ubuntu and centralize user identity configuration in chezmoi.

**Architecture:** Centralize user variables in `.chezmoidata.yaml`, update `dot_gitconfig.tmpl` to use them, and add a `run_once` script that generates the SSH key on Ubuntu if it's missing.

**Tech Stack:** chezmoi, bash, git, BATS (testing)

---

### Task 1: Centralize User Configuration

**Files:**
- Modify: `.chezmoidata.yaml`

- [ ] **Step 1: Update `.chezmoidata.yaml` with user info**

Add the `user` block to `.chezmoidata.yaml`.

```yaml
user:
  name: "張旭"
  email: "zx1986@gmail.com"
  username: "zx1986"
```

- [ ] **Step 2: Verify YAML syntax**

Run: `python3 -c 'import yaml, sys; yaml.safe_load(open(".chezmoidata.yaml"))'`
Expected: No output (exit code 0).

- [ ] **Step 3: Commit**

```bash
git add .chezmoidata.yaml
git commit -m "feat: centralize user config in .chezmoidata.yaml"
```

---

### Task 2: Update Git Configuration Template

**Files:**
- Modify: `dot_gitconfig.tmpl`

- [ ] **Step 1: Replace hardcoded values in `dot_gitconfig.tmpl`**

```tmpl
[user]
  name = {{ .user.name }}
  email = {{ .user.email }}
  username = {{ .user.username }}
```

- [ ] **Step 2: Verify template rendering**

Run: `chezmoi execute-template < dot_gitconfig.tmpl | grep -A 3 "\[user\]"`
Expected:
```text
[user]
  name = 張旭
  email = zx1986@gmail.com
  username = zx1986
```

- [ ] **Step 3: Commit**

```bash
git add dot_gitconfig.tmpl
git commit -m "feat: use template variables in dot_gitconfig.tmpl"
```

---

### Task 3: Create SSH Setup Script

**Files:**
- Create: `run_once_before_15_setup_ssh.sh.tmpl`

- [ ] **Step 1: Create the setup script**

```bash
#!/bin/bash

# Only run on Linux/Ubuntu
{{ if eq .chezmoi.os "linux" -}}
SSH_KEY="$HOME/.ssh/id_ed25519"

if [ ! -f "$SSH_KEY" ]; then
  echo "Generating new SSH key for {{ .user.email }}..."
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "{{ .user.email }}" -N "" -f "$SSH_KEY"
  chmod 600 "$SSH_KEY"
  echo "SSH key generated successfully."
else
  echo "SSH key already exists at $SSH_KEY."
fi
{{ end -}}
```

- [ ] **Step 2: Make the script executable and verify template**

Run: `chmod +x run_once_before_15_setup_ssh.sh.tmpl && chezmoi execute-template < run_once_before_15_setup_ssh.sh.tmpl`
Expected: Output showing the bash script with `zx1986@gmail.com` interpolated.

- [ ] **Step 3: Commit**

```bash
git add run_once_before_15_setup_ssh.sh.tmpl
git commit -m "feat: add run_once script for ssh key generation"
```

---

### Task 4: Add Health Check Tests

**Files:**
- Modify: `tests/health_check.bats`

- [ ] **Step 1: Add SSH key and Git config checks to `tests/health_check.bats`**

Add these tests to the end of the file:

```bash
@test "git config has correct user email" {
  run git config --get user.email
  [ "$status" -eq 0 ]
  [ "$output" = "zx1986@gmail.com" ]
}

@test "ssh key id_ed25519 exists" {
  [ -f "$HOME/.ssh/id_ed25519" ]
}

@test "ssh key id_ed25519 has correct permissions" {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    run stat -c "%a" "$HOME/.ssh/id_ed25519"
    [ "$output" = "600" ]
  fi
}
```

- [ ] **Step 2: Run tests**

Run: `./tests/run_test.sh tests/health_check.bats`
Expected: Tests pass (if keys were generated). Note: You might need to run `make update` first to trigger the script.

- [ ] **Step 3: Commit**

```bash
git add tests/health_check.bats
git commit -m "test: add health checks for ssh and git config"
```
