# Design Spec: Ubuntu Offline Support for xProfile

This document outlines the design for providing offline installation support for Ubuntu environments using a Docker-based "Bundler" approach.

## 1. Goals
- **Self-Contained**: Provide all necessary system packages (`.deb`) and application data (Git repos, binaries) in a single bundle.
- **High Fidelity**: Neovim should have LSP and Tree-sitter functionality working out-of-the-box in offline mode.
- **Lightweight (Scoped)**: Exclude `asdf` and its runtimes (Golang, Terraform, etc.) to keep bundle size manageable.
- **Non-Intrusive**: Generated bundles must NOT be tracked by Git.

## 2. Architecture

### 2.1 The Bundler (Docker)
A dedicated `docker/ubuntu/Dockerfile.bundle` will be used to create the environment and capture dependencies.
- **Package Capture**: Uses `apt-get install --download-only` to fetch system dependencies into a local directory.
- **Environment Warm-up**: Executes Neovim in headless mode to trigger `lazy.nvim` and `mason.nvim` downloads (LSPs and Tree-sitter parsers).
- **Git Pre-cloning**: Clones all external frameworks (Prezto, Oh My Tmux, etc.) into the expected locations.

### 2.2 The Bundle Structure (`dist/xProfile-offline.tar.gz`)
The generated bundle will contain:
- `install.sh`: Orchestration script for the offline machine.
- `debs/`: Collection of `.deb` files for `git`, `zsh`, `tmux`, `ripgrep`, etc.
- `bin/`: Pre-downloaded `chezmoi` binary.
- `home_snapshot.tar.gz`: A compressed archive of the pre-configured `$HOME` directory (containing `.zprezto`, `.tmux`, `.local/share/nvim`, etc.).

## 3. Implementation Details

### 3.1 Docker Build Process
The Dockerfile will perform the following:
1. `apt-get update && apt-get install -d -y ...` to download debs.
2. Download `chezmoi` binary to `/usr/local/bin`.
3. Clone `xProfile` into the container.
4. Run `chezmoi apply --source /path/to/xProfile`.
5. Warm up Neovim:
   ```bash
   nvim --headless "+Lazy! sync" +qa
   nvim --headless "+MasonInstall lua-language-server ..." +qa
   ```
6. Package everything from `/home/user` and the downloaded debs into the final artifact.

### 3.2 Offline Installation Script (`install.sh`)
The installer running on the target machine will:
1. Install system packages: `sudo dpkg -i debs/*.deb`.
2. Extract `home_snapshot.tar.gz` to the current user's `$HOME`.
3. Run `chezmoi apply` in offline mode (mocking variables if necessary to skip network steps).

### 3.3 Makefile & Git Integration
- New target: `make bundle-offline` to run the Docker build and extract the artifact to `dist/`.
- New target: `make clean-offline` to remove `dist/`.
- Update `.gitignore`: Add `dist/` and `*.tar.gz`.

## 4. Verification Plan
1. **Build Verification**: Run `make bundle-offline` on a networked machine and ensure `dist/xProfile-offline.tar.gz` is generated.
2. **Offline Simulation**:
   - Start a clean Ubuntu Docker container with NO internet access.
   - Copy the bundle into the container.
   - Run `install.sh`.
   - Verify `zsh`, `tmux`, and `nvim` (with LSP) work correctly.
