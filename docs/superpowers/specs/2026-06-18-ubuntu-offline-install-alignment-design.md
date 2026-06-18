# Design Spec: Ubuntu Offline Installation Alignment

## Overview

This specification details the alignment of the offline Ubuntu installation bundle with the latest online environment status to ensure parity in package availability, shell customization templates, and tools. This alignment guarantees that all tests in `tests/health_check.bats` pass in an offline-installed environment.

## Context

* **Repository**: xProfile (Chezmoi-managed dotfiles)
* **Goal**: Enable an exact, offline-ready mirror of the Ubuntu online configuration.
* **Target OS**: Ubuntu 22.04 LTS (Docker-based bundling)

---

## Requirements

1. **Package Parity**: The offline installer must include:
   * `tree`
   * `bats`
   * `silversearcher-ag` (providing the `ag` command)
   * `git-delta` (v0.18.2)
2. **Offline-safe Scripts**:
   * Wrap the `antigravity-cli (agy)` installer in `is_offline` checks to avoid online curl requests.
   * Convert `run_once_before_20_install_prezto.sh` and `run_once_before_30_install_oh_my_tmux.sh` to chezmoi templates (`.tmpl`) and guard all network-related `git clone` steps.

---

## Proposed Changes

### 1. `docker/ubuntu/Dockerfile.bundle`

We will modify the downloader stage to fetch the additional core packages and manually download the `git-delta` deb package:

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

### 2. `run_once_before_06_install_antigravity.sh.tmpl`

Wrap the installer curl request in `{{- if not (index . "is_offline") }}`:

```bash
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
```

### 3. Rename `run_once_before_20_install_prezto.sh` to `run_once_before_20_install_prezto.sh.tmpl`

Introduce `{{- if not (index . "is_offline") }}` wrapper:

```bash
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
```

### 4. Rename `run_once_before_30_install_oh_my_tmux.sh` to `run_once_before_30_install_oh_my_tmux.sh.tmpl`

Introduce `{{- if not (index . "is_offline") }}` wrapper:

```bash
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

---

## Verification Plan

1. **Verify template rendering (simulation)**:
   * Run `make test-linux` to verify chezmoi successfully compiles all templates on simulated environments.
2. **Build and test offline bundle locally**:
   * Run `make bundle-offline` to build the docker-based installer package.
   * Run the docker bundle and execute tests inside it to ensure all health checks (including `tree`, `ag`, and `delta`) pass.
