# GitHub CLI Package Installation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add GitHub CLI (`gh`) package installation to both macOS and Ubuntu 22.04 configurations within the chezmoi repository, including offline bundling support.

**Architecture:** Modify the central package installation template (`run_once_before_00_install_packages.sh.tmpl`) to include Homebrew configuration for macOS and official repository/APT configuration for Ubuntu 22.04. Update the Dockerfile bundler (`docker/ubuntu/Dockerfile.bundle`) to pre-cache the package for offline installations. Verify changes via automated test suites.

**Tech Stack:** Chezmoi, Bash, Docker, BATS testing framework.

---

### Task 1: Update Test Suites (TDD Failing Tests)

**Files:**
- Modify: `tests/suite_macos.sh`
- Modify: `tests/suite_linux.sh`
- Modify: `tests/health_check.bats`

- [x] **Step 1: Write failing checks in tests** (Committed)
- [x] **Step 2: Run test suite to verify failure** (Committed)
- [x] **Step 3: Commit the test changes** (Committed)

---

### Task 2: Implement macOS and Ubuntu 22.04 Online Installation in Template

**Files:**
- Modify: `run_once_before_00_install_packages.sh.tmpl`

- [ ] **Step 1: Modify the package installation template**

Edit [run_once_before_00_install_packages.sh.tmpl](file:///home/kasm-user/.local/share/chezmoi/run_once_before_00_install_packages.sh.tmpl).

1. Under the macOS section (around line 18), append `gh` to the end of the `brew install` line:
```bash
brew install git tmux tig bit-git curl asdf zsh coreutils neovim ripgrep fd gcc fzf bats tree the_silver_searcher git-delta less gh
```

2. Under the Linux online section, right after the Neovim PPA setup (around line 38), insert the official repository setup commands:
```bash
  echo "Installing GitHub CLI..."
  (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
      && sudo mkdir -p -m 755 /etc/apt/keyrings \
      && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
      && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
      && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
      && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
      && sudo apt update \
      && sudo apt install gh -y
```

3. Update the Linux core package installation line to append `gh`:
```bash
  sudo apt-get install -y zsh tmux git curl wget unzip build-essential fd-find bat fzf tig ripgrep bats neovim tree silversearcher-ag gh
```

- [ ] **Step 2: Run tests to verify they pass**

Run:
```bash
PATH=/home/kasm-user/Desktop/bin:$PATH make test
```
Expected output: Both test environments run successfully with all tests passing.

- [ ] **Step 3: Run the local health checks**

Run:
```bash
PATH=/home/kasm-user/Desktop/bin:$PATH bats tests/health_check.bats
```
Expected output: The suite completes successfully (and the new `gh CLI is available` test passes).

- [ ] **Step 4: Commit the template changes**

Run:
```bash
git add run_once_before_00_install_packages.sh.tmpl
git commit -m "feat: add github cli installation for macos and ubuntu online"
```

---

### Task 3: Update Offline Dockerfile Bundle

**Files:**
- Modify: `docker/ubuntu/Dockerfile.bundle`

- [ ] **Step 1: Modify Dockerfile.bundle for offline download**

Edit [Dockerfile.bundle](file:///home/kasm-user/.local/share/chezmoi/docker/ubuntu/Dockerfile.bundle). Modify the `downloader` stage to install `wget`, set up the official GitHub repository, update the apt index, and download the `gh` package into the offline cache directory:
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
    zsh tmux git curl wget unzip build-essential fd-find bat fzf tig ripgrep gh
RUN cp /var/cache/apt/archives/*.deb /offline/debs/
```

- [ ] **Step 2: Commit the Dockerfile changes**

Run:
```bash
git add docker/ubuntu/Dockerfile.bundle
git commit -m "feat: add github cli caching to docker bundle for offline installation"
```
