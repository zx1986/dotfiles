#!/bin/sh
set -e

# Install Oh My Tmux
if [ ! -d "$HOME/.tmux/.git" ]; then
  if command -v git >/dev/null; then
    echo "Installing Oh My Tmux from GitHub..."
    git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
  else
    echo "WARN: Cannot install Oh My Tmux (no git)"
  fi
fi

# Install TPM (Tmux Plugin Manager)
if [ -d "$HOME/.tmux" ] && [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  if command -v git >/dev/null; then
    echo "Installing TPM from GitHub..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  else
    echo "WARN: Cannot install TPM (no git)"
  fi
fi
