#!/bin/bash
set -e

echo ">>> Starting Offline Installation..."

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        echo "Error: This script must be run as root or with sudo available."
        exit 1
    fi
fi

# 1. Install debs
echo ">>> Installing system packages (.debs)..."
if ls debs/*.deb >/dev/null 2>&1; then
    ${SUDO} dpkg -i debs/*.deb
else
    echo "No .deb files found in debs/ directory."
fi

# 2. Install Neovim
echo ">>> Installing Neovim..."
if [ -f nvim-linux64.tar.gz ]; then
    ${SUDO} tar -C /usr/local -xzf nvim-linux64.tar.gz --strip-components=1
else
    echo "Warning: nvim-linux64.tar.gz not found, skipping Neovim extraction."
fi

# 3. Extract home snapshot
echo ">>> Extracting home snapshot..."
tar -xzf home_snapshot.tar.gz -C "$HOME"

# 4. Setup chezmoi binary
echo ">>> Setting up chezmoi..."
mkdir -p "$HOME/bin"
cp chezmoi "$HOME/bin/"
export PATH="$HOME/bin:$PATH"

# 5. Run chezmoi apply in offline mode
echo ">>> Applying dotfiles..."
chezmoi apply --source "$HOME/xProfile" --override-data '{"is_offline": true}'

echo ">>> Offline Installation Complete!"
