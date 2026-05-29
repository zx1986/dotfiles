#!/bin/sh
set -e

# Automated TPM plugin installation
# This script runs after dotfiles are applied to ensure ~/.tmux.conf.local is present.

INSTALLER="$HOME/.tmux/plugins/tpm/bin/install_plugins"

if [ -f "$INSTALLER" ]; then
  echo "Installing Tmux plugins via TPM..."
  # Run the installer. It will read plugins from ~/.tmux.conf.local (via symlink from ~/.tmux.conf)
  "$INSTALLER"
  echo "Tmux plugins installed successfully."
else
  echo "WARN: TPM installer not found at $INSTALLER"
  echo "Ensure 'run_once_before_30_install_oh_my_tmux.sh' has run successfully."
fi
