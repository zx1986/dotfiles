# GitHub CLI Package Installation Design

This document outlines the design for installing the GitHub CLI (`gh`) on both macOS and Ubuntu 22.04 systems using the chezmoi pattern, including support for offline installation mode.

## 1. Problem Statement
The current chezmoi dotfile repository installs system-level developer utilities (like `git`, `tmux`, `ripgrep`, etc.) but lacks the GitHub CLI (`gh`). Additionally, the setup needs to support Ubuntu 22.04 both online (via official GitHub APT repository) and offline (pre-cached `.deb` bundles), and macOS (via Homebrew).

## 2. Proposed Changes

### 2.1 macOS Package Installation
Modify the macOS Homebrew package installation list to include `gh`.

**Files to Modify:**
- `run_once_before_00_install_packages.sh.tmpl`

**Logic:**
Append `gh` to the end of the `brew install` command list.

### 2.2 Ubuntu 22.04 Online Package Installation
Modify the Linux-specific online section of the package installation script to register the official GitHub CLI APT repository and keyring, and install the `gh` package.

**Files to Modify:**
- `run_once_before_00_install_packages.sh.tmpl`

**Logic:**
1. Check if `wget` is available (if not, update and install `wget`).
2. Create `/etc/apt/keyrings`.
3. Download the official GPG key (`githubcli-archive-keyring.gpg`) using `wget` directly to stdout and pipe it via `sudo tee` into `/etc/apt/keyrings/githubcli-archive-keyring.gpg`.
4. Ensure correct permissions on the keyring file.
5. Create `/etc/apt/sources.list.d`.
6. Add the GitHub CLI source list entry.
7. Run `apt-get update` and install `gh` using `sudo apt install gh -y`.
8. Also append `gh` to the core packages to install in the main `apt-get install` command to satisfy template check expectations.

### 2.3 Ubuntu 22.04 Offline Package Bundling
Modify the offline bundler to download and cache the `gh` package from the official repository during the bundle build process.

**Files to Modify:**
- `docker/ubuntu/Dockerfile.bundle`

**Logic:**
Add the GitHub CLI repository configuration steps to the `downloader` stage using `wget` and direct `tee` pipes so that the `gh` deb package is downloaded to `/offline/debs/` along with the core system utility packages.

### 2.4 Testing and Verification Checks
The verification checks verify that `gh` is included in the package manager scripts and is available on the sandbox system.

**Checked Files:**
- `tests/suite_linux.sh`
- `tests/suite_macos.sh`
- `tests/health_check.bats`

## 3. Implementation Plan

### Step 1: Update macOS and Linux installation script
Modify `run_once_before_00_install_packages.sh.tmpl` to add the repository setup and the package.

### Step 2: Update Dockerfile.bundle
Modify `docker/ubuntu/Dockerfile.bundle` to add the PPA repository setup and add `gh` to the downloaded packages list.

### Step 3: Run and Verify Test Suites
Run `./tests/run_test.sh linux` and `./tests/run_test.sh darwin` to confirm all assertions pass.

## 4. Verification Strategy

### 4.1 Manual Verification
1. Run `PATH=/home/kasm-user/Desktop/bin:$PATH make test` to run the simulated chezmoi dry-run rendering and verification suite.
2. Confirm the tests pass.

### 4.2 Automated Testing
1. Run `PATH=/home/kasm-user/Desktop/bin:$PATH bats tests/health_check.bats` to confirm the health check verifies `gh` is available.
