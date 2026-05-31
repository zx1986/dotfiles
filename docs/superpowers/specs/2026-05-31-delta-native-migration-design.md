# Design Doc: Native Delta Migration

## Goal
Migrate `delta` (git-delta) installation from `asdf` to native package managers (Homebrew on macOS and `dpkg` on Ubuntu) to reduce dependency on `asdf` for tools where native packages are preferred.

## Architecture

### macOS
- Use Homebrew to install `git-delta`.
- Also install `less` via Homebrew as recommended by `delta` documentation for better paging support.

### Ubuntu (Linux)
- Download the pinned version `0.18.2` of the `git-delta` `.deb` package from GitHub Releases.
- Install using `sudo dpkg -i`.
- Use `wget` or `curl` for the download.

### Cleanup
- Remove `delta` from `.tool-versions`.
- Remove `asdf plugin add delta` from the installation script.

## Implementation Details

### File: `run_once_before_00_install_packages.sh.tmpl`
- **macOS Section**:
  - Add `git-delta` and `less` to the `brew install` command.
- **Ubuntu Section**:
  - Add logic to download and install the `.deb` package:
    ```bash
    DELTA_VERSION="0.18.2"
    DELTA_DEB="git-delta_${DELTA_VERSION}_amd64.deb"
    DELTA_URL="https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/${DELTA_DEB}"
    
    if ! command -v delta >/dev/null; then
      echo "Installing delta ${DELTA_VERSION} via dpkg..."
      wget -q "${DELTA_URL}" -O "/tmp/${DELTA_DEB}"
      sudo dpkg -i "/tmp/${DELTA_DEB}"
      rm "/tmp/${DELTA_DEB}"
    fi
    ```
- **Common ASDF Section**:
  - Remove `asdf plugin add delta || true`.

### File: `dot_tool-versions`
- Remove `delta 0.18.2`.

## Verification Plan
- **macOS**:
  - Run `brew list git-delta` and `brew list less` to ensure they are installed.
  - Run `delta --version` to verify it works.
- **Ubuntu**:
  - Run `dpkg -l git-delta` to ensure it is installed.
  - Run `delta --version` to verify it works.
- **Generic**:
  - Verify `asdf plugin list` does not contain `delta` (if applicable).
  - Verify `git diff` still uses `delta` as the pager.
