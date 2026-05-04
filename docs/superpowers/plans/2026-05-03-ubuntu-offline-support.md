# Ubuntu Offline Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a Docker-based bundling system and an offline installation script to support Ubuntu 22.04 environments without internet access.

**Architecture:** Use a dedicated Dockerfile to "warm up" the environment (downloading debs, git repos, and Neovim plugins), then package the rendered state into a non-tracked tarball.

**Tech Stack:** Docker, Bash, Chezmoi, Makefile.

---

### Task 1: Project Preparation

**Files:**
- Modify: `.gitignore`
- Modify: `Makefile`

- [ ] **Step 1: Update .gitignore**
Exclude the `dist/` directory and any generated tarballs.
```text
dist/
*.tar.gz
```

- [ ] **Step 2: Add placeholder targets to Makefile**
Add `bundle-offline` and `clean-offline` to the `Makefile`.
```makefile
bundle-offline: ## Generate an offline installation bundle for Ubuntu
	@echo "Bundling offline support..."

clean-offline: ## Remove generated offline bundles
	rm -rf dist/
```

- [ ] **Step 3: Commit**
```bash
git add .gitignore Makefile
git commit -m "chore: prepare workspace for offline support"
```

---

### Task 2: Implement the Docker Bundler

**Files:**
- Create: `docker/ubuntu/Dockerfile.bundle`

- [ ] **Step 1: Create the Dockerfile**
This Dockerfile will capture all dependencies.
```dockerfile
FROM ubuntu:22.04

# Avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install basic tools needed for bundling
RUN apt-get update && apt-get install -y \
    curl git zsh tmux unzip build-essential sudo

# 1. Download system packages (.debs) for offline install
RUN mkdir -p /offline/debs && \
    apt-get update && \
    apt-get install -d -y \
    zsh tmux git curl wget unzip build-essential fd-find bat fzf tig ripgrep

# 2. Setup chezmoi
RUN sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b /usr/local/bin

# 3. Clone xProfile and apply
RUN useradd -m -s /usr/bin/zsh user && \
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER user
WORKDIR /home/user
COPY --chown=user:user . ./xProfile
RUN /usr/local/bin/chezmoi init --apply --source ./xProfile

# 4. Warm up Neovim (Lazy & Mason)
RUN nvim --headless "+Lazy! sync" +qa && \
    nvim --headless "+MasonInstall lua-language-server" +qa

# 5. Create final bundle structure
USER root
RUN mkdir -p /dist && \
    cp /usr/local/bin/chezmoi /offline/chezmoi && \
    cp -r /var/cache/apt/archives/*.deb /offline/debs/ && \
    tar -czf /offline/home_snapshot.tar.gz -C /home/user .
```

- [ ] **Step 2: Update Makefile to run Docker build**
```makefile
bundle-offline:
	mkdir -p dist/
	docker build -t xprofile-bundler -f docker/ubuntu/Dockerfile.bundle .
	docker run --rm -v $(PWD)/dist:/output xprofile-bundler sh -c "cp -r /offline/* /output/ && tar -czf /output/xProfile-offline.tar.gz -C /offline ."
```

- [ ] **Step 3: Commit**
```bash
git add docker/ubuntu/Dockerfile.bundle Makefile
git commit -m "feat: add docker-based bundler for offline support"
```

---

### Task 3: Create Offline Installation Script

**Files:**
- Create: `docker/ubuntu/install_offline.sh`

- [ ] **Step 1: Create the installer script**
This script will be packaged into the bundle.
```bash
#!/bin/bash
set -e

echo ">>> Starting Offline Installation..."

# 1. Install debs
sudo dpkg -i debs/*.deb

# 2. Extract home snapshot
echo ">>> Extracting home snapshot..."
tar -xzf home_snapshot.tar.gz -C "$HOME"

# 3. Setup chezmoi binary
mkdir -p "$HOME/bin"
cp chezmoi "$HOME/bin/"
export PATH="$HOME/bin:$PATH"

# 4. Run chezmoi apply in offline mode
# We will use the --override-data to set is_offline=true
echo ">>> Applying dotfiles..."
chezmoi apply --override-data '{"is_offline": true}'

echo ">>> Offline Installation Complete!"
```

- [ ] **Step 2: Update Dockerfile to include installer**
Modify `docker/ubuntu/Dockerfile.bundle` to copy the installer into `/offline`.
```dockerfile
COPY docker/ubuntu/install_offline.sh /offline/install.sh
RUN chmod +x /offline/install.sh
```

- [ ] **Step 3: Commit**
```bash
git add docker/ubuntu/install_offline.sh docker/ubuntu/Dockerfile.bundle
git commit -m "feat: add offline installation script"
```

---

### Task 4: Template Adaptations

**Files:**
- Modify: `run_once_before_00_install_packages.sh.tmpl`

- [ ] **Step 1: Respect is_offline flag**
Modify the install script template to skip `asdf` and other internet-dependent steps when `is_offline` is true.
```bash
{{- if not .is_offline }}
# --- Existing install logic (apt, asdf, etc.) ---
{{- else }}
echo "Offline mode detected. Skipping internet-dependent installations (asdf, etc.)."
{{- end }}
```

- [ ] **Step 2: Commit**
```bash
git add run_once_before_00_install_packages.sh.tmpl
git commit -m "feat: update templates to respect offline mode"
```

---

### Task 5: Final Verification

- [ ] **Step 1: Run bundling**
Run: `make bundle-offline`
Expected: `dist/xProfile-offline.tar.gz` exists and is ~200MB-500MB.

- [ ] **Step 2: Simulate offline install**
Create a test container with NO network access and run the installer.
```bash
docker run --rm -it --network none -v $(PWD)/dist:/bundle ubuntu:22.04 bash
# Inside container:
# cd /bundle && ./install.sh
```

- [ ] **Step 3: Final cleanup**
Run: `make clean-offline`
Verify `dist/` is gone.

- [ ] **Step 4: Commit**
```bash
git commit -m "test: verify offline bundling and installation"
```
