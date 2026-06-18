# Ubuntu Offline Installation Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align the offline Ubuntu installation bundle with the online environment by including missing core packages, fetching git-delta, and guarding installation scripts.

**Architecture:** We will modify the Dockerfile bundler downloader stage to pull all required packages including git-delta, wrap the antigravity-cli installation step in offline-aware conditional templating, and convert Prezto and Tmux shell scripts to chezmoi templates to check the `is_offline` flag before cloning.

**Tech Stack:** Docker, Chezmoi, Bash, Zsh, Git

## Global Constraints

- Target OS: Ubuntu 22.04 LTS
- Git Delta version: 0.18.2
- Chezmoi override data flag: `is_offline`

---

### Task 1: Update Dockerfile.bundle Package Lists

**Files:**
- Modify: `docker/ubuntu/Dockerfile.bundle`

**Interfaces:**
- Consumes: None
- Produces: Updated `Dockerfile.bundle` for offline downloading

- [ ] **Step 1: Modify Dockerfile.bundle**

Replace the downloader stage in `docker/ubuntu/Dockerfile.bundle` to add the extra packages to `apt-get install -d -y` and manually fetch `git-delta` via `wget`.

```dockerfile
# Stage 1: Download debs in a clean environment
FROM ubuntu:22.04 AS downloader
ENV DEBIAN_FRONTEND=noninteractive
RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
    mkdir -p /offline/debs && \
    apt-get update && \
    apt-get install -y wget && \
    mkdir -p -m 755 /etc/apt/keyrings && \
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -d -y \
    zsh tmux git curl wget unzip build-essential fd-find bat fzf tig ripgrep gh \
    bats tree silversearcher-ag
RUN wget -q https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_amd64.deb -O /offline/debs/git-delta_0.18.2_amd64.deb
RUN cp /var/cache/apt/archives/*.deb /offline/debs/
```

- [ ] **Step 2: Commit changes**

Run:
```bash
git add docker/ubuntu/Dockerfile.bundle
git commit -m "feat(offline): download delta, bats, tree, and ag in Dockerfile.bundle"
```

---

### Task 2: Guard Antigravity CLI Installation

**Files:**
- Modify: `run_once_before_06_install_antigravity.sh.tmpl`

**Interfaces:**
- Consumes: `is_offline` flag from chezmoi
- Produces: Guarded execution flow for antigravity installation

- [ ] **Step 1: Modify run_once_before_06_install_antigravity.sh.tmpl**

Modify the file `run_once_before_06_install_antigravity.sh.tmpl` to look exactly like:

```bash
#!/bin/bash

# Install antigravity-cli (agy)
# Official installer: https://antigravity.google/cli/install.sh

set -e

{{- if not (index . "is_offline") }}
if [ ! -f "$HOME/.local/bin/agy" ]; then
    echo "Installing antigravity-cli..."
    curl -fsSL https://antigravity.google/cli/install.sh | bash
else
    echo "antigravity-cli is already installed."
fi

# Final verification
if [ -f "$HOME/.local/bin/agy" ]; then
    echo "Verification successful: agy found in ~/.local/bin"
else
    echo "Error: agy installation failed."
    exit 1
fi
{{- else }}
if [ -f "$HOME/.local/bin/agy" ]; then
    echo "Offline mode: using pre-installed antigravity-cli from home snapshot."
else
    echo "Offline mode: antigravity-cli not found, skipping."
fi
{{- end }}

# --- Install Antigravity Plugins ---
{{- if not (index . "is_offline") }}
{{- range .antigravity.plugins }}
echo "Installing antigravity plugin: {{ . }}..."
"$HOME/.local/bin/agy" plugin install "{{ . }}" || echo "Warning: Failed to install plugin {{ . }}"
{{- end }}
{{- end }}
```

- [ ] **Step 2: Commit changes**

Run:
```bash
git add run_once_before_06_install_antigravity.sh.tmpl
git commit -m "feat(offline): guard antigravity-cli installer against offline runs"
```

---

### Task 3: Convert Prezto Installer to Template

**Files:**
- Rename: `run_once_before_20_install_prezto.sh` -> `run_once_before_20_install_prezto.sh.tmpl`

**Interfaces:**
- Consumes: `is_offline` flag from chezmoi
- Produces: `run_once_before_20_install_prezto.sh.tmpl`

- [ ] **Step 1: Rename the file**

Run:
```bash
git mv run_once_before_20_install_prezto.sh run_once_before_20_install_prezto.sh.tmpl
```

- [ ] **Step 2: Update content of the template**

Update `run_once_before_20_install_prezto.sh.tmpl` to look exactly like:

```bash
#!/bin/sh
set -e

# Install Prezto
if [ ! -d "$HOME/.zprezto" ]; then
  {{- if not (index . "is_offline") }}
  if command -v git >/dev/null; then
    echo "Installing Prezto from GitHub..."
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$HOME/.zprezto"
  else
    echo "WARN: Cannot install Prezto (no git)"
  fi
  {{- else }}
  echo "Offline mode: skipping Prezto clone."
  {{- end }}
fi

# Install Prezto Contrib (belak/prezto-contrib)
if [ -d "$HOME/.zprezto" ] && [ ! -d "$HOME/.zprezto/contrib" ]; then
  {{- if not (index . "is_offline") }}
  if command -v git >/dev/null; then
    echo "Installing Prezto Contrib from GitHub..."
    git clone --recursive https://github.com/belak/prezto-contrib "$HOME/.zprezto/contrib"
  else
    echo "WARN: Cannot install Prezto Contrib (no git)"
  fi
  {{- end }}
fi

# Create Prezto symlinks
if [ -d "$HOME/.zprezto" ]; then
  for rcfile in "$HOME"/.zprezto/runcoms/z*; do
    target="$HOME/.$(basename "$rcfile")"
    if [ ! -e "$target" ] && [ "$(basename "$rcfile")" != "zshrc" ] && [ "$(basename "$rcfile")" != "zpreztorc" ]; then
      ln -sf "$rcfile" "$target"
    fi
  done
fi
```

- [ ] **Step 3: Commit changes**

Run:
```bash
git add run_once_before_20_install_prezto.sh.tmpl
git commit -m "feat(offline): convert prezto installer to template with offline guard"
```

---

### Task 4: Convert Oh My Tmux Installer to Template

**Files:**
- Rename: `run_once_before_30_install_oh_my_tmux.sh` -> `run_once_before_30_install_oh_my_tmux.sh.tmpl`

**Interfaces:**
- Consumes: `is_offline` flag from chezmoi
- Produces: `run_once_before_30_install_oh_my_tmux.sh.tmpl`

- [ ] **Step 1: Rename the file**

Run:
```bash
git mv run_once_before_30_install_oh_my_tmux.sh run_once_before_30_install_oh_my_tmux.sh.tmpl
```

- [ ] **Step 2: Update content of the template**

Update `run_once_before_30_install_oh_my_tmux.sh.tmpl` to look exactly like:

```bash
#!/bin/sh
set -e

# Install Oh My Tmux
if [ ! -d "$HOME/.tmux/.git" ]; then
  {{- if not (index . "is_offline") }}
  if command -v git >/dev/null; then
    echo "Installing Oh My Tmux from GitHub..."
    git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
  else
    echo "WARN: Cannot install Oh My Tmux (no git)"
  fi
  {{- else }}
  echo "Offline mode: skipping Oh My Tmux clone."
  {{- end }}
fi

# Install TPM (Tmux Plugin Manager)
if [ -d "$HOME/.tmux" ] && [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  {{- if not (index . "is_offline") }}
  if command -v git >/dev/null; then
    echo "Installing TPM from GitHub..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  else
    echo "WARN: Cannot install TPM (no git)"
  fi
  {{- end }}
fi
```

- [ ] **Step 3: Commit changes**

Run:
```bash
git add run_once_before_30_install_oh_my_tmux.sh.tmpl
git commit -m "feat(offline): convert tmux installer to template with offline guard"
```

---

### Task 5: Verification & Testing

**Files:**
- Create: None (Run test suites/commands)

**Interfaces:**
- Consumes: All updated templates and files
- Produces: Successfully verified templates and offline bundle

- [ ] **Step 1: Run local template simulation tests**

Run:
```bash
make test-linux
```
Expected: All template rendering tests pass without compilation issues.

- [ ] **Step 2: Build the offline installation bundle**

Run:
```bash
make bundle-offline
```
Expected: Docker builds the bundle successfully and generates `dist/xProfile-offline.tar.gz`.

- [ ] **Step 3: Verify contents inside the offline bundle**

We will verify that the tarball contains all the required packages:
Run:
```bash
tar -tf dist/xProfile-offline.tar.gz | grep debs/ | grep -E "(git-delta|tree|bats|silversearcher-ag)"
```
Expected: Output showing the `.deb` files for `git-delta`, `tree`, `bats`, and `silversearcher-ag`.
