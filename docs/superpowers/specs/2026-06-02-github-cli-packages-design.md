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
Append `gh` to the `brew install` list.

### 2.2 Ubuntu 22.04 Online Package Installation
Modify the Linux-specific online section of the package installation script to register the official GitHub CLI APT repository and keyring, and install the `gh` package.

**Files to Modify:**
- `run_once_before_00_install_packages.sh.tmpl`

**Logic:**
1. Create `/etc/apt/keyrings`.
2. Download the official GPG key (`githubcli-archive-keyring.gpg`).
3. Add the GitHub CLI source list entry.
4. Run `apt-get update` and install `gh`.

### 2.3 Ubuntu 22.04 Offline Package Bundling
Modify the offline bundler to download and cache the `gh` package from the official repository during the bundle build process.

**Files to Modify:**
- `docker/ubuntu/Dockerfile.bundle`

**Logic:**
Add the GitHub CLI repository configuration steps to the `downloader` stage so that the `gh` deb package is downloaded to `/offline/debs`.

### 2.4 Testing and Verification Checks
Add checks to verify that `gh` is included in the package manager scripts and is available on the sandbox system.

**Files to Modify:**
- `tests/suite_linux.sh`
- `tests/suite_macos.sh`
- `tests/health_check.bats`

## 3. Implementation Plan

### Step 1: Update macOS and Linux installation script
Modify `run_once_before_00_install_packages.sh.tmpl` to add the repository setup and the package.

### Step 2: Update Dockerfile.bundle
Modify `docker/ubuntu/Dockerfile.bundle` to add the GPG key, repository list, and add `gh` to the downloaded packages list.

### Step 3: Add test verifications
Add assertions to `tests/suite_macos.sh`, `tests/suite_linux.sh`, and `tests/health_check.bats`.

## 4. Verification Strategy

### 4.1 Manual Verification
1. Run `./tests/run_test.sh linux` and `./tests/run_test.sh darwin` and confirm the tests pass.
2. Verify that `gh --version` runs and outputs the correct CLI version.

### 4.2 Automated Testing
1. Run `bats tests/health_check.bats` to confirm the health check verifies `gh` is available.
