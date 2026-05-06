# Task 3 Quality Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve installer robustness and portability for Task 3 (Ubuntu offline support).

**Architecture:**
- Fix Apt cache cleanup in Docker to ensure all debs are available for bundling.
- Use dynamic `SUDO` variable in the installation script.
- Improve path portability for `chezmoi` and home snapshot extraction.
- Add safety checks for globbing in the installation script.

**Tech Stack:** Docker, Bash, Chezmoi

---

### Task 1: Fix Apt Cache Cleanup in Dockerfile

**Files:**
- Modify: `docker/ubuntu/Dockerfile.bundle`

- [x] **Step 1: Disable docker-clean to keep debs**

In `docker/ubuntu/Dockerfile.bundle`, add `RUN rm -f /etc/apt/apt.conf.d/docker-clean` before the `apt-get update` call that downloads debs.

```dockerfile
# 1. Download system packages (.debs) for offline install
RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
    mkdir -p /offline/debs && \
    apt-get update && \
    apt-get install -d -y \
    zsh tmux git curl wget unzip build-essential fd-find bat fzf tig ripgrep \
    && rm -rf /var/lib/apt/lists/*
```

- [x] **Step 2: Verify Dockerfile syntax**
Run `docker build -f docker/ubuntu/Dockerfile.bundle .` (optional, if docker is available) or just check syntax.

### Task 2: Improve Installer Robustness (Sudo, Glob, Portability)

**Files:**
- Modify: `docker/ubuntu/install_offline.sh`

- [x] **Step 1: Implement SUDO variable detection**

Define a `SUDO` variable that checks if `sudo` is available and if the user is not root.

```bash
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        echo "Error: This script must be run as root or with sudo available."
        exit 1
    fi
fi
```

- [x] **Step 2: Add Glob Guard for dpkg**

Wrap `dpkg -i debs/*.deb` in an `if` check to see if any `.deb` files exist.

```bash
# 1. Install debs
echo ">>> Installing system packages (.debs)..."
if ls debs/*.deb >/dev/null 2>&1; then
    ${SUDO} dpkg -i debs/*.deb
else
    echo "No .deb files found in debs/ directory."
fi
```

- [x] **Step 3: Update Neovim installation to use ${SUDO}**

```bash
# 2. Install Neovim
echo ">>> Installing Neovim..."
if [ -f nvim-linux64.tar.gz ]; then
    ${SUDO} tar -C /usr/local -xzf nvim-linux64.tar.gz --strip-components=1
else
...
```

- [x] **Step 4: Improve Chezmoi path portability**

Ensure that the snapshot extraction and `chezmoi init` handle the local user's home directory correctly. Specifically, use `chezmoi init --source "$HOME/xProfile"`.

```bash
# 4. Setup chezmoi binary
echo ">>> Setting up chezmoi..."
mkdir -p "$HOME/bin"
cp chezmoi "$HOME/bin/"
export PATH="$HOME/bin:$PATH"

# 5. Run chezmoi apply in offline mode
echo ">>> Applying dotfiles..."
chezmoi init --source "$HOME/xProfile"
chezmoi apply --override-data '{"is_offline": true}'
```

- [x] **Step 5: Verify install_offline.sh syntax**
Run `bash -n docker/ubuntu/install_offline.sh`

### Task 3: Commit Changes

- [ ] **Step 1: Commit with specific message**

Commit the fixes with message: "fix: improve installer robustness and portability"

---
