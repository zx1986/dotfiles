#!/bin/bash
set -e

echo ">>> Starting Offline Installation..."

# 1. Install debs
echo ">>> Installing system packages (.debs)..."
sudo dpkg -i debs/*.deb

# 2. Install Neovim
echo ">>> Installing Neovim..."
if [ -f nvim-linux64.tar.gz ]; then
    sudo tar -C /usr/local -xzf nvim-linux64.tar.gz --strip-components=1
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
# We will use the --override-data to set is_offline=true
echo ">>> Applying dotfiles..."
# Ensure we are in the home directory or wherever chezmoi expects to find its source if it was extracted there
# Usually, the home snapshot includes .local/share/chezmoi
chezmoi apply --override-data '{"is_offline": true}'

echo ">>> Offline Installation Complete!"
